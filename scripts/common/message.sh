#!/bin/bash

# Common status message
function grey_message() {
    echo $(tput bold)$(tput setaf 0) $@ $(tput sgr 0)
}

function message() {
    echo $(tput bold)$(tput setaf 9) $@ $(tput sgr 0)
}

function info_message() {
    echo $(tput bold)$(tput setaf 4) $@ $(tput sgr 0)
}

function warn_message() {
    echo $(tput bold)$(tput setaf 2) $@ $(tput sgr 0)
}

function error_message()  {
    echo $(tput bold)$(tput setaf 1) $@ $(tput sgr 0)
}
