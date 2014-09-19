#!/bin/bash

set -x
BASE=/root/kernel
KERNEL="3.17-rc5"
REV=3

function prepare() {
        apt-get install curl patch bc make gcc ncurses-dev lzop u-boot-tools bzip2

#        #wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.15.tar.xz
#        #wget http://www.lenhof.eu.org/utilite/imx6q-cm-fx6.dts.v2.patch

#        rm -r $KernelDir
#        mkdir -pv $KernelDir

#        rm -r $INSTALL_MOD_PATH
#        mkdir -pv $INSTALL_MOD_PATH

#        rm -r $INSTALL_PATH
#        mkdir -pv $INSTALL_PATH

#        cd $KernelDir
#        curl ftp://www.kernel.org/pub/linux/kernel/v3.x/linux-3.15.tar.xz | tar -xJv --strip-components=1 -f -
#        patch -p0 < <(curl http://www.lenhof.eu.org/utilite/imx6q-cm-fx6.dts.v2.patch)
#        make imx_v6_v7_defconfig
#        curl -o ./config_lenhof http://www.lenhof.eu.org/utilite/config_debian-wheezy_v2
}

function getKernel(){
    cd $BASE
    url=https://www.kernel.org/pub/linux/kernel/v3.x/testing/linux-${KERNEL}.tar.xz
    curl $url | tar xJv
    cd $KERNELdir
    make imx_v6_v7_defconfig
}

function getDTS(){
    dtsfiles="
imx6q-cm-fx6.dts
imx6q-cm-fx6.dtsi
imx6q.dtsi
imx6q-sbc-fx6.dts
imx6q-sbc-fx6m.dts
imx6q-sb-fx6.dtsi
imx6q-sb-fx6m.dts
imx6q-sb-fx6m.dtsi
imx6q-sb-fx6x.dtsi
"
     cd dts/cm
     rm ./*
     for dts in $dtsfiles; do
	echo "https://raw.githubusercontent.com/utilite-computer/linux-kernel/utilite/devel/arch/arm/boot/dts/$dts"
     done | wget -v -i -
}

function getPkgUmiddelb(){
    echo "Go see https://github.com/umiddelb/armhf/wiki/Installing-Ubuntu-14.04-on-the-utilite-computer-from-scatch#download-a-prebuilt-archive-with-kernels-included"
    echo "Go see https://www.dropbox.com/sh/1ln93hvod4tki5s/AABMO2SGv8PJ2dTaQRV4DmROa?dl=0j" 
}

function patch(){
    cp -v dts/cm/* $KERNELdir/archarm/boot/dts/

    #Get out pu_dummy and some more! 
    #Insert johnbock's mac fix (http://www.utilite-computer.com/forum/viewtopic.php?f=66&t=1986)
    #see diff in dts/loeki/
    #imx6q-sbc-fx6m.dtb is the new dtb!
    cp -v dts/loeki/* $KERNELdir/archarm/boot/dts/

    #Fix Makefile in arch/arm/boot/dts:
}

function compile(){
    cd $KERNELdir
    make clean
    make -j 4 zImage  
    make -j 4 uImage  
    make -j 4 modules 
    #make modules_install
    #make imx6q-cm-fx6.dtb
    make imx6q-sbc-fx6m.dtb
}

function install(){
    cd $KERNELdir
    make modules_install

    #With appended DTB:
    cat arch/arm/boot/zImage arch/arm/boot/dts/imx6q-sbc-fx6m.dtb > /tmp/zImage-${KVER}
    mkimage -A arm -O linux -T kernel -C none -a 0x10008000 -e 0x10008000 -n Linux-${KVER} -d /tmp/zImage-${KVER} /boot/aImage-${KVER}
    rm /tmp/zImage-${KVER}

    #Without appended DTB:
    mkimage -A arm -O linux -T kernel -C none -a 0x10008000 -e 0x10008000 -n Linux-${KVER} -d arch/arm/boot/zImage /boot/uImage-${KVER}
    cp arch/arm/boot/dts/imx6q-sbc-fx6m.dtb /boot/

}

function config(){
   echo HOI

}

IFS='
'

KERNELdir="linux-$KERNEL"
[[ $KERNEL =~ rc ]] && KERNEL=${KERNEL/-/.0-}

KVER="${KERNEL}-l${REV}"
cd $BASE

$1
