#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Terminal Styling (safe for Linux / SSH)
# =========================================================
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
CYAN="\033[36m"

if [[ ! -t 1 || "${TERM:-}" == "dumb" ]]; then
  RESET=""; BOLD=""; DIM=""
  BLUE=""; GREEN=""; YELLOW=""; RED=""; CYAN=""
fi

# =========================================================
# Configuration
# =========================================================
ITERATIONS="${FLOW_ITERATIONS:-100000}"
SALT_SIZE="${FLOW_SALT_BYTES:-8}"
DEFAULT_BASE_DIR="./files"

# 0 = unlimited retries
MAX_ATTEMPTS="${FLOW_MAX_ATTEMPTS:-0}"

# Priority:
# 1) first CLI arg
# 2) FLOW_SECRETS_BASE env var
# 3) user prompt
# 4) default
BASE_DIR="${1:-${FLOW_SECRETS_BASE:-}}"

# =========================================================
# UI helpers
# =========================================================
header() {
  clear || true
  printf "\n"
  printf "${CYAN}${BOLD}============================================================${RESET}\n"
  printf "${CYAN}${BOLD}   Flow Manager - Secure Password Encryption Utility        ${RESET}\n"
  printf "${CYAN}${BOLD}============================================================${RESET}\n\n"
  printf "${DIM}Base directory: %s${RESET}\n" "$BASE_DIR"
  printf "${DIM}PBKDF2 iterations: %s | Salt bytes: %s | Max attempts: %s${RESET}\n" \
    "$ITERATIONS" "$SALT_SIZE" "$MAX_ATTEMPTS"
}

section() {
  printf "\n${BLUE}${BOLD}%s${RESET}\n" "$1"
  printf "${DIM}------------------------------------------------------------${RESET}\n"
}

success() {
  printf "${GREEN}[OK]${RESET} %s\n" "$1"
}

warn() {
  printf "${YELLOW}[WARN]${RESET} %s\n" "$1" > /dev/tty
}

fail() {
  printf "${RED}[ERROR]${RESET} %s\n\n" "$1" >&2
  exit 1
}

# =========================================================
# Prompt helpers
# =========================================================
prompt_secret() {
  local label="$1"
  local value=""
  printf "${YELLOW}  %s:${RESET} " "$label" > /dev/tty
  IFS= read -r -s value < /dev/tty || fail "Failed to read secret input"
  printf "\n" > /dev/tty
  printf "%s" "$value"
}

prompt_text() {
  local label="$1"
  local value=""
  printf "${YELLOW}  %s:${RESET} " "$label" > /dev/tty
  IFS= read -r value < /dev/tty || true

  # Trim leading/trailing whitespace
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  printf "%s" "$value"
}

prompt_action_retry_skip_abort() {
  local label="$1"
  local answer=""
  while true; do
    printf "${YELLOW}  %s [r=retry, s=skip, a=abort] (default: r):${RESET} " "$label" > /dev/tty
    IFS= read -r answer < /dev/tty || answer="r"
    answer="${answer,,}"
    answer="${answer#"${answer%%[![:space:]]*}"}"
    answer="${answer%"${answer##*[![:space:]]}"}"
    [[ -z "$answer" ]] && answer="r"

    case "$answer" in
      r|retry) printf "retry"; return 0 ;;
      s|skip)  printf "skip"; return 0 ;;
      a|abort) printf "abort"; return 0 ;;
      *) warn "Invalid selection. Please choose r, s, or a." ;;
    esac
  done
}

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fail "Required command not found: $cmd"
}

# =========================================================
# Temp file cleanup
# =========================================================
TMP_FILES=()

register_tmp_file() {
  TMP_FILES+=("$1")
}

cleanup_tmp_files() {
  local f
  for f in "${TMP_FILES[@]:-}"; do
    [[ -n "$f" && -f "$f" ]] && rm -f -- "$f" || true
  done
}

trap 'cleanup_tmp_files' EXIT

# =========================================================
# Core helpers
# =========================================================
resolve_base_dir() {
  if [[ -z "$BASE_DIR" ]]; then
    section "Base Directory Selection"
    local input_dir=""
    input_dir=$(prompt_text "Enter base directory [default: $DEFAULT_BASE_DIR]")
    BASE_DIR="${input_dir:-$DEFAULT_BASE_DIR}"
  fi

  [[ -n "$BASE_DIR" ]] || fail "Base directory is empty"
  mkdir -p "$BASE_DIR" || fail "Cannot create/access base directory: $BASE_DIR"
  chmod 755 "$BASE_DIR" || fail "Cannot chmod 755 on base directory: $BASE_DIR"
  success "Using base directory: $BASE_DIR"
}

atomic_write_file() {
  local target="$1"
  local content="$2"

  local dir
  dir="$(dirname "$target")"
  mkdir -p "$dir" || fail "Cannot create directory for $target"
  chmod 755 "$dir" || fail "Cannot chmod 755 on directory for $target"

  local tmp
  tmp="$(mktemp "${dir}/.tmp.secret.XXXXXX")" || fail "Cannot create temp file in $dir"
  register_tmp_file "$tmp"

  printf "%s" "$content" > "$tmp" || fail "Cannot write temp file for $target"
  chmod 764 "$tmp" || fail "Cannot chmod 764 on temp file for $target"

  mv -f "$tmp" "$target" || fail "Cannot move temp file into place for $target"
  chmod 764 "$target" || fail "Cannot chmod 764 on $target"
}

write_empty_secret_file() {
  local file="$1"
  atomic_write_file "$file" ""
  [[ -f "$file" ]] || fail "File not created: $file"
  success "Wrote empty file: $file"
}

MASTER_KEY=""

validate_master_key() {
  section "Master Key Validation"

  local mk1 mk2
  local attempts=0

  while true; do
    if [[ "$MAX_ATTEMPTS" -gt 0 ]]; then
      attempts=$((attempts + 1))
      if [[ "$attempts" -gt "$MAX_ATTEMPTS" ]]; then
        fail "Maximum attempts reached for MASTER encryption key"
      fi
      printf "${DIM}Attempt %s/%s${RESET}\n" "$attempts" "$MAX_ATTEMPTS" > /dev/tty
    fi

    mk1=$(prompt_secret "Enter MASTER encryption key")
    mk2=$(prompt_secret "Confirm MASTER encryption key")

    if [[ -z "$mk1" ]]; then
      warn "Master key cannot be empty."
      continue
    fi

    if [[ "$mk1" != "$mk2" ]]; then
      warn "Master keys do not match."
      continue
    fi

    MASTER_KEY="$mk1"
    success "Master key validated"
    break
  done
}

# mode:
#   encrypted (default) -> store SALT:CIPHERTEXT
#   plain               -> store raw user input
# return codes:
#   0 = success
#   2 = skipped by user
encrypt_and_store() {
  local label="$1"
  local file="$2"
  local mode="${3:-encrypted}"

  printf "\n${BOLD}Enter password for %s${RESET}\n" "$label"

  local password confirm
  local salt=""
  local ciphertext=""
  local attempts=0
  local action="retry"

  while true; do
    if [[ "$MAX_ATTEMPTS" -gt 0 ]]; then
      attempts=$((attempts + 1))
      if [[ "$attempts" -gt "$MAX_ATTEMPTS" ]]; then
        warn "Max attempts reached for $label. Skipping."
        return 2
      fi
      printf "${DIM}Attempt %s/%s${RESET}\n" "$attempts" "$MAX_ATTEMPTS" > /dev/tty
    fi

    password=$(prompt_secret "Password")

    # Empty means create empty file and move on.
    if [[ -z "$password" ]]; then
      write_empty_secret_file "$file"
      success "$label left empty"
      return 0
    fi

    confirm=$(prompt_secret "Confirm password")
    if [[ "$password" != "$confirm" ]]; then
      warn "Passwords do not match for $label."
      action="$(prompt_action_retry_skip_abort "Choose next action")"
      case "$action" in
        retry) continue ;;
        skip)
          warn "Skipped $label"
          return 2
          ;;
        abort)
          fail "Aborted by user while processing $label"
          ;;
      esac
    fi

    break
  done

  if [[ "$mode" == "plain" ]]; then
    atomic_write_file "$file" "$password"
    [[ -s "$file" ]] || fail "Plain file write failed: $file"
    success "Password stored in plain text for $label -> $file"
    return 0
  fi

  salt=$(openssl rand -hex "$SALT_SIZE") || fail "Failed to generate salt for $label"

  if ! ciphertext=$(
    printf "%s" "$password" | openssl enc -aes-256-cbc \
      -pbkdf2 \
      -iter "$ITERATIONS" \
      -S "$salt" \
      -pass pass:"$MASTER_KEY" \
      -base64
  ); then
    fail "Encryption failed for $label"
  fi

  [[ -n "$ciphertext" ]] || fail "Encryption produced empty output for $label"

  atomic_write_file "$file" "${salt}:${ciphertext}"$'\n'
  [[ -s "$file" ]] || fail "Encrypted file write failed: $file"

  success "Password encrypted and stored securely for $label -> $file"
  return 0
}

# =========================================================
# Main
# =========================================================
require_command "openssl"
require_command "mktemp"

resolve_base_dir
header
validate_master_key

section "Encrypting Application Passwords"

processed=0
skipped=0

process_secret() {
  local label="$1"
  local file="$2"
  local mode="${3:-encrypted}"

  if encrypt_and_store "$label" "$file" "$mode"; then
    processed=$((processed + 1))
  else
    rc=$?
    if [[ "$rc" -eq 2 ]]; then
      skipped=$((skipped + 1))
    else
      fail "Unexpected error while processing $label"
    fi
  fi
}

process_secret "FM_GOVERNANCE_CA_PASSWORD" \
  "$BASE_DIR/flowmanager/configs/fm-governance-ca-password"

process_secret "FM_DATABASE_USER_PASSWORD" \
  "$BASE_DIR/flowmanager/configs/fm-database-user-password"

process_secret "FM_HTTPS_KEYSTORE_PASSWORD" \
  "$BASE_DIR/flowmanager/configs/fm-https-keystore-password"

process_secret "FM_USER_INITIAL_PASSWORD" \
  "$BASE_DIR/flowmanager/configs/fm-user-initial-password"

process_secret "FM_HTTPS_CLIENT_KEYSTORE_PASSWORD" \
  "$BASE_DIR/flowmanager/configs/fm-https-client-keystore-password"

process_secret "FM_CFTPLUGIN_PRIVATEKEY_PASSWORD" \
  "$BASE_DIR/flowmanager/configs/fm-cftplugin-privatekey-password"

process_secret "FM_CORE_PRIVATEKEY_PASSWORD" \
  "$BASE_DIR/flowmanager/configs/fm-core-privatekey-password"

process_secret "ST_FM_PLUGIN_DATABASE_USER_PASSWORD" \
  "$BASE_DIR/st-fm-plugin/st-fm-plugin-database-user-password"

# MONGO is plain text by requirement (no encryption)
process_secret "MONGO_APP_PASSWORD" \
  "$BASE_DIR/mongo/config/mongo-app-pass" \
  "plain"

process_secret "MONITORING_PLUGIN_DB_USER_PASSWORD" \
  "$BASE_DIR/monitoring-fm-plugin/monitoring-plugin-db-user-password"

section "Summary"
success "Completed: $processed"
warn "Skipped:   $skipped"

printf "\n${GREEN}${BOLD}All secrets processing finished.${RESET}\n\n"