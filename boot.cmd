setenv bootargs 'console=ttyAMA0,115200 root=/dev/mmcblk0p2 rw'
setenv loadkernel "fatload mmc 0:1 0x60100000 zImage"
setenv loaddtb "fatload mmc 0:1 0x60000000 vexpress-v2p-ca9.dtb"
setenv boot "bootz 0x60100000 - 0x60000000"
setenv bootcmd "run loadkernel; run loaddtb; run boot"
