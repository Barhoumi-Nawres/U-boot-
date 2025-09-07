#!/bin/bash

SDIMG=sd.img
UBOOT_SRC=u-boot/u-boot
UBOOT_DES=files/u-boot
BOOT_MNT=boot


do_losetup(){
    # 1.create a loop device 

    loop_dev=$(sudo losetup -f --show --partscan ${SDIMG})
    echo "loop device created :${loop_dev}"
}

do_mount-boot(){
    # 2.mount sd.img 
    loop_dev_p1=${loop_dev}p1
    echo "mounting ${loop_dev_p1} to ${BOOT_MNT}"
    sudo mount ${loop_dev_p1} ${BOOT_MNT}
}

do_update(){
    # 3.update u-boot

    rm ${UBOOT_DES}
    cp ${UBOOT_SRC} ${UBOOT_DES}
}


do_umount(){
    #4.umount 
    sudo umount ${BOOT_MNT}

}

do_detach(){
    #5.detach loop device 
    echo "detaching : ${loop_dev}"
    sudo losetup -d ${loop_dev}
}