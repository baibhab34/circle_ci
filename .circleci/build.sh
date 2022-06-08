#!/bin/bash
echo "Cloning dependencies"
git clone https://github.com/ArrowOS-Devices/android_kernel_realme_sdm660 -b wip --depth=1 kernel
cd kernel
git clone --depth=1 https://gitlab.com/arrowos-project/android_prebuilts_clang_host_linux-x86_clang-r437112b clang
git clone --depth=1 https://github.com/KudProject/arm-linux-androideabi-4.9 gcc32
git clone --depth=1 https://github.com/KudProject/aarch64-linux-android-4.9 gcc
git clone https://gitlab.com/Baibhab34/AnyKernel3.git -b rmx1801 --depth=1 AnyKernel
echo "Done"
KERNEL_DIR=$(pwd)
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb"
TANGGAL=$(date +"%Y%m%d-%H")
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PATH="${KERNEL_DIR}/clang/bin:${KERNEL_DIR}/gcc/bin:${KERNEL_DIR}/gcc32/bin:${PATH}"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64
export KBUILD_BUILD_USER="baibhab"
export KBUILD_BUILD_HOST=circleci

# Compile plox
function compile() {
    make -j$(nproc) O=out ARCH=arm64 RMX1801_defconfig
    make -j$(nproc) O=out \
                    ARCH=arm64 \
                    CC=clang \
                    CLANG_TRIPLE=aarch64-linux-gnu- \
                    CROSS_COMPILE=aarch64-linux-android- \
                    CROSS_COMPILE_ARM32=arm-linux-androideabi-

    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 Avalanche-RMX1801-EAS-${TANGGAL}.zip *
    curl https://bashupload.com/Avalanche-RMX1801-EAS-${TANGGAL}.zip --data-binary @Avalanche-RMX1801-EAS-${TANGGAL}.zip
    cd ..
}
compile
zipping
