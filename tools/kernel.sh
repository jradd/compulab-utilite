#!/bin/bash

set -x
BASE=/home/theloeki/cmtools
KERNEL="3.17-rc7"
REV=4

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
    curl -k $KERNELurl | tar xJv -f - || exit 1
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
    mkdir ${KERNELdir}/clog/
    cp -v dts/cm/* ${KERNELdir}/arch/arm/boot/dts/

    #Get out pu_dummy and some more! 
    #Insert johnbock's mac fix (http://www.utilite-computer.com/forum/viewtopic.php?f=66&t=1986)
    #see diff in dts/loeki/
    #imx6q-sbc-fx6m.dtb is the new dtb!
    cp -v dts/loeki/* ${KERNELdir}/arch/arm/boot/dts/

    #Fix Makefile in arch/arm/boot/dts:
    sed -i 's|imx6q-cm-fx6.dtb|imx6q-sbc-fx6m.dtb|g' ${KERNELdir}/arch/arm/boot/dts/Makefile
}

function compile(){
    if [[ ! -d ${KERNELdir}/clog/ ]]; then 
	echo "Patch first"
	exit 1
    fi
    cd $KERNELdir
    export V=1
    export V=99
    rm -f ${KERNELdir}/clog/*
    make clean
    make -j4 zImage 2>&1 | tee $KERNELdir/clog/zImage.log 
    make -j4 uImage 2>&1 | tee $KERNELdir/clog/uImage.log 
    make modules 2>&1 | tee $KERNELdir/clog/modules.log 
    #make modules_install
    #make imx6q-cm-fx6.dtb
    make imx6q-sbc-fx6m.dtb
}

function install(){
    cd $KERNELdir

    sudo make modules_install

    #With appended DTB:
    cat arch/arm/boot/zImage arch/arm/boot/dts/imx6q-sbc-fx6m.dtb > /tmp/zImage-${KERNELver}
    sudo mkimage -A arm -O linux -T kernel -C none -a 0x10008000 -e 0x10008000 -n Linux-${KERNELver} -d /tmp/zImage-${KERNELver} /boot/aImage-${KERNELver}
    rm /tmp/zImage-${KERNELver}

    #Without appended DTB:
    sudo mkimage -A arm -O linux -T kernel -C none -a 0x10008000 -e 0x10008000 -n Linux-${KERNELver} -d arch/arm/boot/zImage /boot/uImage-${KERNELver}
    sudo cp arch/arm/boot/dts/imx6q-sbc-fx6m.dtb /boot/

}

function config(){
   echo HOI

}

IFS='
'

KERNELdir="linux-$KERNEL"
if [[ $KERNEL =~ rc ]]; then
	KERNELurl=https://www.kernel.org/pub/linux/kernel/v3.x/testing/linux-${KERNEL}.tar.xz
	KERNEL=${KERNEL/-/.0-}
else
	KERNELurl=https://www.kernel.org/pub/linux/kernel/v3.x/linux-${KERNEL}.tar.xz
fi

KERNELver="${KERNEL}-l${REV}"
#Useless for now
#KVER="${KERNEL}-l${REV}"
cd $BASE

$1
