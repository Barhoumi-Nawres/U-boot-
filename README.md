
# U-Boot on ARM Vexpress Cortex-A9

This project explains how to **build, configure, and run U-Boot** on the **Vexpress Cortex-A9 board** using QEMU, and how to boot a Linux kernel with a minimal BusyBox root filesystem.

---
## 🖥️ Board Information

 CPU: ARMv7 Processor

 Machine: V2P-CA9

## 📌 Objective

- Understand how **U-Boot bootloader** works.  
- U-Boot loads the **kernel** and the **Device Tree (DTB)** into RAM.  
- Then the **Linux kernel** starts running.

---

## 🔧 Building U-Boot

### 1. Install U-Boot

Clone and checkout version `v2023.01`:

```bash
git clone https://github.com/u-boot/u-boot.git
cd u-boot
git checkout v2023.01
```

### 2.configure u-boot to support the  ARM Vexpress Cortex A9 board (vexpress_ca9x4_defconfig)

```bash

make vexpress_ca9x4_defconfig
```

The configuration will be writen to .config

### 3. Cross-Compilation Setup:
```bash

<arch>-<vendor>-<os>-<clib><abi><hf>
```

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


On Ubuntu, install toolchain:

```bash

sudo apt install gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf 
```
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
### 4. Build U-Boot:

```bash
make -j 4 (4 cores)
```

## 🖥️ Testing U-Boot with QEMU:
Install QEMU:
```bash

sudo apt install qemu-system-arm
```
Run:
```bash

$ qemu-system-arm -M vexpress-a9 -m 128M -nographic -kernel u-boot
```

Here the “kernel” is actually the U-Boot binary.

## 💾 SD Card Setup:


1. Create SD image:
   ```bash
dd if=/dev/zero of=sd.img bs=1M count=128
```

2. Partition the image:
   ```bash
cfdisk sd.img
```
3. Attach loop device:
create the block device for sd.img by the following command :
   ```bash
sudo losetup -f --show --partscan sd.img
output :/dev/loop16
```
to get more information about the block device :
sudo fdisk -l /dev/loop16.

4. Format partitions:
   ```bash
mkfs.vfat /dev/loop16p1
mkfs.ext4 /dev/loop16p2
```
## 🐧 Building the Linux Kernel:

1.Install Linux stable sources.

2.configure linux for vexpress machine :(ARM).

make vexpress_defconfig (after compiling we will found DTB(hardware description ) for vexpress machine 

linux has a variable by it we can control the architecture (environment variable :ARCH)

so we need to ser the arch because the linux by default take the architecture :x86.

and then set cross_compile as an environment variable .
   ```bash
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
```



after compiling the kernel :
Kernel: arch/arm/boot/zImage is ready


Copy the kernel and dtb to the boot partition :


=> fatls mmc 0:1
        0   text
            nawres/
   262144   uboot.env
  5859128   zImage
    14329   vexpress-v2p-ca9.dtb

4 file(s), 1 dir(s)

=> 


### 🚀 Booting Linux with U-Boot:

--load the kernel and dtb into RAM : 
*Load the dtb :
   ```bash
fatload mmc 0:1 0x60000000 vexpress-v2p-ca9.dtb
```


*load the kernel :
   ```bash
fatload mmc 0:1 0x60100000 zImage
```

set the boot arguments :
   ```bash
setenv bootargs 'console=ttyAMA0,115200 root=/dev/mmcblk0p2 rw'
```


*set boot command :
   ```bash
bootz 0x60100000 - 0x60000000
```

● Save the environment
$ saveenv
● Exit with Ctrl+A+X
● Rerun the qemu-system-arm command with no interaction


#### ⚠️ Example Output:
   ```bash
5859128 bytes read in 728 ms (7.7 MiB/s)
14329 bytes read in 10 ms (1.4 MiB/s)
Kernel image @ 0x62008000 [ 0x000000 - 0x596738 ]
## Flattened Device Tree blob at 60000000
   Booting using the fdt blob at 0x60000000
Working FDT set to 60000000
   Loading Device Tree to 66b16000, end 66b1c7f8 ... OK
Working FDT set to 66b16000

Starting kernel ...

```
👉 Kernel panic may occur if root filesystem is missing.





### 📦 BusyBox Root Filesystem:
Configure BusyBox: 
run the command :
 ```bash
make menuconfig
```
 
Go to Settings : 

    (arm-linux-gnueabihf-) Cross compiler prefix

    (../busybox-rootfs) Destination path for 'make install'




The contenu of two partitions:

 ```bash
=> fatls mmc 0:1
        0   text
            nawres/
   262144   uboot.env
  5859128   zImage
    14329   vexpress-v2p-ca9.dtb

4 file(s), 1 dir(s)

=> ext4ls mmc 0:2
<DIR>       4096 .
<DIR>       4096 ..
<DIR>      16384 lost+found
<DIR>       4096 bin
<SYM>         11 linuxrc
<DIR>       4096 sbin
<DIR>       4096 usr

```

#### Bootscript :

The bootscript is an script that is automatically executed when the boot loader starts, and before
the OS auto boot process.
The bootscript allows the user to execute a set of predefined U-Boot commands automatically.

1.First, you need the u-boot-tools installed in your Linux machine:

 ```bash
sudo apt install u-boot-tools
```


That package provide to us the tool mkimage to convert a text file (.cmd, .txt) file to a bootscript file for U-Boot(boot.scr).

2.create a boot.cmd (text file contains all the  u-boot command :

3.Now we can convert the text file to bootscript with mkimage.

 ```bash

mkimage -T script -n "Bootscript" -C none -d <input_file> <output_file>
```







