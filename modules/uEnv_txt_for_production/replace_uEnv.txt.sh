#!/bin/bash
uEnv=/boot/uboot/uEnv.txt
cat << _EOF_ > $uEnv
##Video: Uncomment to override:
##see: https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/fb/modedb.txt
#kms_force_mode=video=HDMI-A-1:1024x768@60e
optargs=consoleblank=0
optargs=splash plymouth.ignore-serial-consoles \${optargs}
##Enable systemd
systemd=quiet init=/lib/systemd/systemd

##BeagleBone Cape Overrides

##BeagleBone Black:
##Disable HDMI/eMMC
#cape_disable=capemgr.disable_partno=BB-BONELT-HDMI,BB-BONELT-HDMIN,BB-BONE-EMMC-2G

##Disable HDMI
cape_disable=capemgr.disable_partno=BB-BONELT-HDMI,BB-BONELT-HDMIN
#cape_disable=capemgr.disable_partno=BB-BONELT-HDMIN

##Audio Cape (needs HDMI Audio disabled)
#cape_disable=capemgr.disable_partno=BB-BONELT-HDMI
#cape_enable=capemgr.enable_partno=BB-BONE-AUDI-02

##Example
#cape_disable=capemgr.disable_partno=
#cape_enable=capemgr.enable_partno=

##WIP: v3.14+ capes..
#cape=ttyO1
#cape=

##note: the eMMC flasher script relies on the next line
_EOF_


UUID=$(lsblk -no UUID /dev/mmcblk1p2)
if [ $? -eq 1 ]
then
	echo "/dev/mmcblk1 is not a valid block device"
	UUID=$(lsblk -no UUID /dev/mmcblk0p2)
#	echo "UUID for /dev/mmcblk0p2 is $UUID"
	if [ $? -eq 1 ]
	then
#		echo $?
 # 	  echo "UUID for /dev/mmcblk0p2 is $UUID"
		echo "Cann't find a booting root!"
		exit 0
	fi
fi

echo "Root fs Block device found at $UUID"

#exit

cat << _EOF_ >> $uEnv
mmcroot=UUID=${UUID} ro
mmcrootfstype=ext4 rootwait fixrtc

##These are needed to be compliant with Angstrom's 2013.06.20 u-boot.
console=ttyO0,115200n8

kernel_file=zImage
initrd_file=initrd.img

loadaddr=0x82000000
initrd_addr=0x88080000
fdtaddr=0x88000000

initrd_high=0xffffffff
fdt_high=0xffffffff

loadkernel=load mmc \${mmcdev}:\${mmcpart} \${loadaddr} \${kernel_file}
loadinitrd=load mmc \${mmcdev}:\${mmcpart} \${initrd_addr} \${initrd_file}; setenv initrd_size \${filesize}
loadfdt=load mmc \${mmcdev}:\${mmcpart} \${fdtaddr} /dtbs/\${fdtfile}

loadfiles=run loadkernel; run loadinitrd; run loadfdt
mmcargs=setenv bootargs console=tty0 console=\${console} \${optargs} \${cape_disable} \${cape_enable} \${kms_force_mode} root=\${mmcroot} rootfstype=\${mmcrootfstype} \${systemd}

uenvcmdmmc=run loadfiles; run mmcargs; bootz \${loadaddr} \${initrd_addr}:\${initrd_size} \${fdtaddr}

usb_kernel_file=vmlinuz
loadusbkernel=load usb 0:1 \${loadaddr} /boot/\${usb_kernel_file}
loadusbinitrd=load usb 0:1 \${initrd_addr} /boot/\${initrd_file}; setenv initrd_size \${filesize}
loadusbfdt=load usb 0:1 \${fdtaddr} /boot/dtbs/3.8.13-bone69/\${fdtfile}

loadusbfiles=run loadusbkernel; run loadusbinitrd; run loadusbfdt
usbroot=/dev/sda1 ro rootwait
usbargs=setenv bootargs console=tty0 console=\${console} \${optargs} \${cape_disable} \${cape_enable} \${kms_force_mode} root=\${usbroot} rootfstype=\${mmcrootfstype} 
uenvcmdusb=run loadusbfiles; run usbargs; bootz \${loadaddr} \${initrd_addr}:\${initrd_size} \${fdtaddr}

#uenvcmd=usb start; if test -e usb 0:1 /boot/${usb_kernel_file}; then run uenvcmdusb; else run uenvcmdmmc; fi
#uenvcmd= if gpio input 72; then usb start; if test -e usb 0:1 /boot/\${usb_kernel_file}; then echo "USB loaded";  run uenvcmdusb; else echo "MMC loaded"; run uenvcmdmmc; fi; else echo "MMC loaded"; run uenvcmdmmc; fi

uenvcmdmmc=echo "*** Boot button Unpressed..!!"; run loadfiles; run mmcargs; bootz \${loadaddr} \${initrd_addr}:\${initrd_size} \${fdtaddr}
uenvcmdsdcard=echo "*** Boot button pressed..!!"; bootpart=0:1;bootdir=;fdtaddr=0x81FF0000;optargs=quiet capemgr.disable_partno=BB-BONELT-HDMI,BB-BONELT-HDMIN;load mmc 0 \${loadaddr} uImage;run loadfdt;setenv bootargs console=\${console} \${optargs};bootm \${loadaddr} - \${fdtaddr}
uenvcmd= if gpio input 72; then run uenvcmdsdcard; else run uenvcmdmmc; fi


#
_EOF_


echo "uEnv.txt done updating"
