#READONLY
#setenv baudrate 115200
#setenv stderr serial
#setenv stdin serial
#setenv stdout serial
#
#ONLY IN SPI
#setenv autoload no
#setenv bootscr boot.scr
#setenv ethaddr 00:01:c0:14:0d:54
#setenv loadaddr 0x10800000
#setenv console tymxc3
#setenv serial myserial
#setenv mmcdev 2
#setenv video_dvi mxcfb0:dev=dvi,1280x800M-24@50,if=RGB24
#setenv video_hdmi mxcfb0:dev=hdmi,1920x1080M-24@50,if=RGB24
#
##USEFUL SETTINGS
#setenv bootdelay 5
#setenv init 'mmc dev ${mmcdev}; sata init'
#
##AND THESE
#ethact FEC
#nandargs setenv bootargs console=${console},${baudrate} root=${nandroot} rootfstype=${nandrootfstype} ${video}
#nandboot echo Booting from nand ...; run nandargs; nand read ${loadaddr} 0 400000 && bootm ${loadaddr}
#nandroot /dev/mtdblock4 rw
#nandrootfstype ubifs
#run_eboot echo Starting EBOOT ...; mmc dev ${mmcdev} && mmc rescan && mmc read 10042000 a 400 && go 10042000

