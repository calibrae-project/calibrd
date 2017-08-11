#!/bin/bash
echo "Entered Ubuntu 14 chroot"
mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts 
mount none -t sys /sys