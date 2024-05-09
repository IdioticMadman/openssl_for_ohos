#!/bin/bash
set -u

source ./build-ohos-common.sh

if [ -z ${version+x} ]; then 
  version="1.1.1t"
fi

init_log_color

TOOLS_ROOT=$(pwd)

SOURCE="$0"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
pwd_path="$(cd -P "$(dirname "$SOURCE")" && pwd)"

echo pwd_path=${pwd_path}
echo TOOLS_ROOT=${TOOLS_ROOT}

# openssl-1.1.0f has a configure bug
# openssl-1.1.1d has fix configure bug
LIB_VERSION="OpenSSL_$(echo $version | sed 's/\./_/g')"
LIB_NAME="openssl-$version"
LIB_DEST_DIR="${pwd_path}/../output/ohos/openssl-universal"

echo "https://www.openssl.org/source/${LIB_NAME}.tar.gz"

# https://github.com/openssl/openssl/archive/OpenSSL_1_1_1d.tar.gz
# https://github.com/openssl/openssl/archive/OpenSSL_1_1_1f.tar.gz
rm -rf "${LIB_DEST_DIR}" "${LIB_NAME}"
[ -f "${LIB_NAME}.tar.gz" ] || curl https://www.openssl.org/source/${LIB_NAME}.tar.gz >${LIB_NAME}.tar.gz



function configure_make() {

    ARCH=$1

    log_info "configure $ARCH start..."

    if [ -d "${LIB_NAME}" ]; then
        rm -fr "${LIB_NAME}"
    fi
    tar xfz "${LIB_NAME}.tar.gz"
    pushd .
    cd "${LIB_NAME}"

    PREFIX_DIR="${pwd_path}/../output/ohos/openssl-${ARCH}"
    if [ -d "${PREFIX_DIR}" ]; then
        rm -fr "${PREFIX_DIR}"
    fi
    mkdir -p "${PREFIX_DIR}"

    OUTPUT_ROOT=${TOOLS_ROOT}/../output/ohos/openssl-${ARCH}
    mkdir -p ${OUTPUT_ROOT}/log
    set_common_ohos_toolchain
    set_toolchain_with_arch "openssl" "${ARCH}"
    set_ohos_cpu_feature "openssl" "${ARCH}"

    ohos_printf_global_params "$ARCH" "$PREFIX_DIR" "$OUTPUT_ROOT"
   
    local build_host=$(get_build_host_internal "$ARCH")

    if [ -z "${build_host}" ] ; then
        log_error "$ARCH not support" && exit 1
    fi
    ./Configure $build_host --prefix="${PREFIX_DIR}"

    log_info "make $ARCH start..."

    make clean >"${OUTPUT_ROOT}/log/${ARCH}.log"
    # ABr: do *not* generate soname; see https://stackoverflow.com/a/33869277
    make SHLIB_EXT='.so' CALC_VERSIONS="SHLIB_COMPAT=; SHLIB_SOVER=" MAKE="make -e" all >>"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1
    the_rc=$?
    if [ $the_rc -eq 0 ] ; then
        make SHLIB_EXT='.so' install_sw >>"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1
        make install_ssldirs >>"${OUTPUT_ROOT}/log/${ARCH}.log" 2>&1
    fi

    popd
}

log_info "${PLATFORM_TYPE} ${LIB_NAME} start..."

for ((i = 0; i < ${#ARCHS[@]}; i++)); do
    if [[ $# -eq 0 || "$1" == "${ARCHS[i]}" ]]; then
        configure_make "${ARCHS[i]}"
    fi
done

log_info "${PLATFORM_TYPE} ${LIB_NAME} end..."
