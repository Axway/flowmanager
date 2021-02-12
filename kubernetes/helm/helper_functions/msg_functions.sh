#!/bin/bash
# set -x

RED="\e[31;1m%s\n"
YELLOW="\e[33;1m%s\n"
GREEN="\e[32;1m%s\n"

###########################################
# Screen function
###########################################
function msg_info() {
    printf ${YELLOW} "[INFOS]"
    printf ${YELLOW} "[INFOS] ===================================================="
    printf ${YELLOW} "[INFOS]  DATE : $(date +"%Y-%m-%d_%H:%M:%S")"
    printf ${YELLOW} "[INFOS]  $1"
    printf ${YELLOW} "[INFOS] ===================================================="
}

function msg_error() {
    printf ${RED} "[ WARN ]"
    printf ${RED} "[ WARN ] ===================================================="
    printf ${RED} "[ WARN ]  DATE : $(date +"%Y-%m-%d_%H:%M:%S")"
    printf ${RED} "[ WARN ]  $1"
    printf ${RED} "[ WARN ] ===================================================="
}

function msg_output() {
    printf ${GREEN} "[ OUT ]"
    printf ${GREEN} "[ OUT ] ===================================================="
    printf ${GREEN} "[ OUT ]  DATE : $(date +"%Y-%m-%d_%H:%M:%S")"
    printf ${GREEN} "[ OUT ]  $1"
    printf ${GREEN} "[ OUT ] ===================================================="
}