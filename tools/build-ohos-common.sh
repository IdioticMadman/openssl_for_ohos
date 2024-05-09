source ./build-common.sh

if [ -z ${arch+x} ]; then 
  arch=("armeabi-v7a" "arm64-v8a" "x86-64")
fi

export PLATFORM_TYPE="OHOS"
export ARCHS=(${arch[@]})

# for test
# export ARCHS=("x86_64")
# export ABIS=("x86_64")

if [[ -z ${OHOS_SDK_ROOT} ]]; then
  echo "OHOS_SDK_ROOT not defined"
  exit 1
fi

OHOS_NATIVE_DIR=${OHOS_SDK_ROOT}/base/native

OHOS_LLMV_BIN_DIR=${OHOS_SDK_ROOT}/base/native/llvm/bin

OHOS_BASE_FLAGS="--sysroot=$OHOS_NATIVE_DIR/sysroot -fdata-sections -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -fno-addrsig -Wa,--noexecstack -fPIC"

function get_build_host_internal() {
  local arch=$1
  case ${arch} in
  armeabi-v7a)
    echo "linux-generic32"
    ;;
  arm64-v8a)
    echo "linux-aarch64"
    ;;
  x86-64)
    echo "linux-x86_64-clang"
    ;;
  esac
}

function get_clang_target_host() {
  local arch=$1
  case ${arch} in
  armeabi-v7a)
    echo "arm-linux-ohos"
    ;;
  arm64-v8a)
    echo "aarch64-linux-ohos"
    ;;
  x86-64)
    echo "x86_64-linux-ohos"
    ;;
  esac
}

function set_common_ohos_toolchain() {
  export AS=${OHOS_LLMV_BIN_DIR}/llvm-as
  export LD=${OHOS_LLMV_BIN_DIR}/ld.lld
  export STRIP=${OHOS_LLMV_BIN_DIR}/llvm-strip
  export RANLIB=${OHOS_LLMV_BIN_DIR}/llvm-ranlib
  export OBJDUMP=${OHOS_LLMV_BIN_DIR}/llvm-objdump
  export OBJCOPY=${OHOS_LLMV_BIN_DIR}/llvm-objcopy
  export NM=${OHOS_LLMV_BIN_DIR}/llvm-nm
  export AR=${OHOS_LLMV_BIN_DIR}/llvm-ar
}


function set_toolchain_with_arch() {
  local name=$1
  local arch=$2
  local target=$(get_clang_target_host "$arch")
  export CC="${OHOS_LLMV_BIN_DIR}/clang --target=$target"
  export CXX="${OHOS_LLMV_BIN_DIR}/clang++ --target=$target" 
}


function set_ohos_cpu_feature() {
  local name=$1
  local arch=$2
  case ${arch} in
  armeabi-v7a)
    export CFLAGS="$OHOS_BASE_FLAGS -march=armv7-a"
    export CXXFLAGS="$OHOS_BASE_FLAGS -march=armv7-a"
    export LDFLAGS="--rtlib=compiler-rt -fuse-ld=lld -march=armv7-a"
    ;;
  arm64-v8a)
    export CFLAGS="$OHOS_BASE_FLAGS -march=armv8-a"
    export CXXFLAGS="$OHOS_BASE_FLAGS"
    export LDFLAGS="--rtlib=compiler-rt -fuse-ld=lld -march=armv8-a"
    ;;
  x86-64)
    export CFLAGS="$OHOS_BASE_FLAGS -march=x86-64"
    export CXXFLAGS="$OHOS_BASE_FLAGS"
    export LDFLAGS="--rtlib=compiler-rt -fuse-ld=lld -march=x86-64"
    ;;
  esac
}

function ohos_printf_global_params() {
  local arch=$1
  local in_dir=$2
  local out_dir=$3
  echo -e "arch =           $arch"
  echo -e "PLATFORM_TYPE =  $PLATFORM_TYPE"
  echo -e "in_dir =         $in_dir"
  echo -e "out_dir =        $out_dir"
  echo -e "AR =             $AR"
  echo -e "CC =             $CC"
  echo -e "CXX =            $CXX"
  echo -e "AS =             $AS"
  echo -e "LD =             $LD"
  echo -e "RANLIB =         $RANLIB"
  echo -e "STRIP =          $STRIP"
  echo -e "CFLAGS =         $CFLAGS"
  echo -e "CXXFLAGS =       $CXXFLAGS"
  echo -e "LDFLAGS =        $LDFLAGS"
}
