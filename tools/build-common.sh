#!/bin/bash
export PLATFORM_TYPE=""
export PKG_CONFIG_PATH=$(which pkg-config)

if [[ -z ${PKG_CONFIG_PATH} ]]; then
  echo "PKG_CONFIG_PATH not defined"
  exit 1
fi

function get_cpu_count() {
    if [ "$(uname)" == "Darwin" ]; then
        echo $(sysctl -n hw.physicalcpu)
    else
        echo $(nproc)
    fi
}

export bold_color="\033[1;m"
export warn_color="\033[33m"
export error_color="\033[31m"
export reset_color="\033[0m"
export ncols=80

function init_log_color() {
    true
}

function log_info() {
    printf "$warn_color$@$reset_color\n"
}

function log_warning() {
    printf "$warn_color$bold_color$@$reset_color\n"
}

function log_error() {
    printf "$error_color$bold_color$@$reset_color\n"
}

# init_log_color
# log_info "info"
# log_warning "warning"
# log_error "error"
