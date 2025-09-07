
# U-boot-
understand of u-boot bootloader 

the objectif of u-boot :

U-Boot loads the kernel and the device tree into RAM and then the kernel starts running

##Configuring and building U-boot 
1-install u-boot and checkout to the version v2023.01.
2-configure u-boot to support the  ARM Vexpress Cortex A9 board (vexpress_ca9x4_defconfig)

by command: 

make vexpress_ca9x4_defconfig

the configuration will be writen to .config


to define cross-compile :
<arch>-<vendor>-<os>-<clib><abi><hf>

example:

arm-linux-gnueabi

ABI:application binary interface (
definition of the name of systemcall ,numero ,arguments,register (where they are exist).

we need the ABI in the userspace to be compatible with the ABI in the kernel space .

abi in arm =eabi 
hf :hardware float :the CPU contains FPU  or not 
(FPU:float pointing Unit ).

if exist create =hf ,if not don't create anything .


this is prefix:

to define :CROSS_COMPILE=prefix-


in the makefile we have this variable :

CC=$(CROSS_COMPILE)gcc


on ubuntu we can install this package :

sudo apt install gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf 

(compiler+binutils)=toolchain


so now we need to compile u-boot for arm :

export CROSS_COMPILE=arm-linux-guneabihf-

to check the environment varaiable 
echo $CROSS_COMPILE

make menuconfig:

uboot has an evironment we can manipulate it uboot.env (change boot process for example ).

we will configure u-boot ,to be able to enrigister his environment in FAT partition .(this is the boot partition ).


the modification that we did in the menuconfig they will be store in .config file.
-we set the name of the block device :mmc 
-device and partition for where to store the environment :(0:1) (partition 1 or 2).

and then compile u-boot:
make -j 4 (4 cores):

install qemu-arm to test u-boot:

sudo apt install qemu-system-arm

$ qemu-system-arm -M vexpress-a9 -m 128M -nographic -kernel u-boot

the kernel is not linux is u-boot binary :(for qemu).



##SD card setup :
create SD empty image :
dd if=/dev/zero of=sd.img bs=1M count=128


create 2 partitions on the empty image :
cfdisk sd.img

u-boot detect there are two partition :

=> mmc part

Partition Map for MMC device 0  --   Partition Type: DOS

Part	Start Sector	Num Sectors	UUID		Type
  1	2048      	131072    	c8b317df-01	06
  2	133120    	129024    	c8b317df-02	83
=> <INTERRUPT>


create the block device for sd.img by the following command :

sudo losetup -f --show --partscan sd.img

output :/dev/loop16

to get more information about the block device :
sudo fdisk -l /dev/loop16.

we need to format the partition :
using mkfs :




##linux kernel:
install linux stable version :

configure linux for vexpress machine :(ARM).

make vexpress_defconfig (after compiling we will found DTB(hardware description ) for vexpress machine 

linux has a variable by it we can control the architecture (environment variable :ARCH)

so we need to ser the arch because the linux by default take the architecture :x86.


and then set cross_compile as an environment variable .

after compiling the kernel :
Kernel: arch/arm/boot/zImage is ready


cp the kernel and dtb to the boot partition :


=> fatls mmc 0:1
        0   text
            nawres/
   262144   uboot.env
  5859128   zImage
    14329   vexpress-v2p-ca9.dtb

4 file(s), 1 dir(s)

=> 


now we need to load them :


##boot :
--load the kernel and dtb into RAM : 
*Load the dtb :
fatload mmc 0:1 0x60000000 vexpress-v2p-ca9.dtb

*load the kernel :

fatload mmc 0:1 0x60100000 zImage

set the boot arguments :

setenv bootargs 'console=ttyAMA0,115200 root=/dev/mmcblk0p2 rw'

*set boot command :
bootz 0x60100000 - 0x60000000

● Save the environment
$ saveenv
● Exit with Ctrl+A+X
● Rerun the qemu-system-arm command with no interaction




the result :
5859128 bytes read in 728 ms (7.7 MiB/s)
14329 bytes read in 10 ms (1.4 MiB/s)
Kernel image @ 0x62008000 [ 0x000000 - 0x596738 ]
## Flattened Device Tree blob at 60000000
   Booting using the fdt blob at 0x60000000
Working FDT set to 60000000
   Loading Device Tree to 66b16000, end 66b1c7f8 ... OK
Working FDT set to 66b16000

Starting kernel ...

......
at the end we found kernel panic because we don't the root partition .



###INformation about the board :

CPU: ARMv7 Processor
Machine model: V2P-CA9




##busybox configuration :

Go to Settings : 

    (arm-linux-gnueabihf-) Cross compiler prefix

    (../busybox-rootfs) Destination path for 'make install'


the contenu of two partitions:

=> fatls mmc 0:1
        0   text
            nawres/
   262144   uboot.env
  5859128   zImage
    14329   vexpress-v2p-ca9.dtb

4 file(s), 1 dir(s)

=> fatls mmc 0:2
=> 
=> ext4ls mmc 0:2
<DIR>       4096 .
<DIR>       4096 ..
<DIR>      16384 lost+found
<DIR>       4096 bin
<SYM>         11 linuxrc
<DIR>       4096 sbin
<DIR>       4096 usr



