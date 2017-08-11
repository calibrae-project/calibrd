#!/bin/bash

echo "Installing debootstrap"
sudo apt install debootstrap

echo "creating ubuntu 14.04 base image"
sudo debootstrap --variant=buildd --arch=amd64 trusty ubuntu14

echo "Starting chrooted build script"
sudo cp buildcalibrd.sh ubuntu14/
sudo chroot ubuntu14 bash -i

echo "removing work folder"
cd ..
sudo rm -rf ubuntu14
