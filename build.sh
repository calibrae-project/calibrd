#!/bin/bash

echo "Installing debootstrap"
sudo apt install debootstrap

echo "creating ubuntu 14.04 base image"
sudo debootstrap --variant=buildd --arch=amd64 trusty ubuntu14

echo "mounting system folders into chroot"
cd ubuntu14
sudo mount -o bind /dev dev
sudo mount -o bind /dev/pts dev/pts
sudo mount -o bind /sys sys
sudo mount -o bind /proc proc



echo "unmounting system folders"
sudo umount dev/pts
sudo umount dev
sudo umount sys
sudo umount proc

echo "removing work folder"
cd ..
sudo rm -rf ubuntu14
