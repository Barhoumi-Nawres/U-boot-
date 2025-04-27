lab about u-boot bootloader :
the initial reason of bootloader is that load the kernel and device tree blob and throw it :

steps :
***************U-BOOT:
-configure u-boot to support the architcture .
-u-boot compilation (we need to specify the cross_compile prefix )
NOTE:
Toolchain prefix : <arch>-<vendor>-<os>-<clib><abi><hf>
and before install the package.
-configura u-boot (using make menuconfig)
-compile it (make command )
-test it (set the architecture and memory space of it in the emulated machine )


*******SD card Setup :
-create empty sd image using DD command :
-create 2 partitions on the empty image 
  (command cfdisk sd.img) one for boot and other for rootfs .

-create loop device for the new image 
sudo losetup -f --show --partscan sd.img 

nawres@nawres:~/bootlinux$ sudo fdisk -l /dev/loop17
Disk /dev/loop17: 1 GiB, 1073741824 bytes, 2097152 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xcd1af785

Device        Boot  Start    End Sectors Size Id Type
/dev/loop17p1        2048 133119  131072  64M  6 FAT16
/dev/loop17p2      133120 262143  129024  63M 83 Linux




-format the two partitions .
-create mount point for the partitions .


************************** kernel   :
-install kernel source 
-make the configuration 
export ARCH=arm 
export CROSS_COMPILE=arm-linux-gnueabihf-
make vexpress_defconfig 


make menuconfig to add some support to the kernel .
and then compile it with (make )

the output :we will get (the kernel image and dtb (device tree blob ).

************
now we have ,kernel bootloader and devicetree 
nawres@nawres:~/bootlinux$ ls files/
u-boot  vexpress-v2p-ca9.dtb  zImage

copy the kernel and dtb to the boot partition :


Partition Map for MMC device 0  --   Partition Type: DOS

Part	Start Sector	Num Sectors	UUID		Type
  1	2048      	131072    	cd1af785-01	06
  2	133120    	129024    	cd1af785-02	83
=> fatls mmc 0:1
   262144   uboot.env
        0   nawres
        0   test.file
  5859128   zImage
    14329   vexpress-v2p-ca9.dtb

5 file(s), 0 dir(s)

=> 


*******************load the kernel and dtb and boot :

steps :

-set the boot arguments :

setenv bootargs 'console=ttyAMA0,115200 root=/dev/mmcblk0p2 rw'
-set the load kernel command :
setenv loadkernel 'fatload mmc 0:1 0x62008000 zImage'

-set the load dtb command :
setenv loaddtb 'fatload mmc 0:1 0x60000000 vexpress-v2p-ca9.dtb'

-set the boot command :
setenv bootcmd 'run loadkernel; run loaddtb; bootz 0x62008000 - 0x60000000'

-save the environment :

saveenv 


then exit and rerun the QEMU-system-arm .





