#!/bin/bash

cd /tmp
if [ ! -d calibrd-work ]; then
  mkdir calibrd-work
fi
cd /tmp/calibrd-work

if [ ! -d calibrd ]; then

  echo "Cloning calibrd Git repository"
  git clone https://github.com/calibrae-project/calibrd.git
  echo "Entering repository"
  cd calibrd

  echo "Updating submodules"
  git submodule update --init --recursive

fi

cd /tmp/calibrd-work

echo "Installing pbuilder"
sudo apt install -y debootstrap pbuilder devscripts

echo "Creating ubuntu 14.04 base image"
if [ ! -f ubuntu14.tgz ]; then
  sudo pbuilder --create \
    --distribution trusty \
    --architecture amd64 \
    --basetgz ubuntu14.tgz \
    --debootstrapopts \
    --variant=buildd
fi

if [ ! -d ubuntu14 ]; then
  echo "Unpacking base build image"
  mkdir ubuntu14
  cd ubuntu14
  tar xvf ../ubuntu14.tgz
  cd ..
fi

cd /tmp/calibrd-work
echo "downloading cmake 3"
if [ ! -f cmake-3.2.2.tar.gz ]; then
  wget http://www.cmake.org/files/v3.2/cmake-3.2.2.tar.gz
fi
cp cmake-3.2.2.tar.gz ubuntu14/

cd /tmp/calibrd-work
echo "Downloading AppImageKit"
wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod a+x appimagetool-x86_64.AppImage
cp appimagetool-x86_64.AppImage ubuntu14/

echo "copying AppDir skeleton to chroot"
cp -rf steemd.AppDir ubuntu14/

echo "downloading boost 1.60"
if [ ! -f boost_1_60_0.tar.bz2 ]; then
  URL='http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.bz2/download'
  wget -c "$URL" -O boost_1_60_0.tar.bz2
  [ $( sha256sum boost_1_60_0.tar.bz2 | cut -d ' ' -f 1 ) == \
    "686affff989ac2488f79a97b9479efb9f2abae035b5ed4d8226de6857933fd3b" ] \
    || ( echo 'Corrupt download' ; exit 1 )
fi 
cp boost_1_60_0.tar.bz2 ubuntu14/

cp -rf calibrd ubuntu14/

cd /tmp/calibrd-work

echo "Mounting system folders inside chroot"
sudo mount -o bind /dev ubuntu14/dev
sudo mount -o bind /dev/pts ubuntu14/dev/pts
sudo mount -o bind /sys ubuntu14/sys
sudo mount -o bind /proc ubuntu14/proc
cp /etc/resolv.conf ubuntu14/etc/resolv.conf

echo "Starting chrooted build script"
sudo cp buildcalibrd.sh ubuntu14/
sudo chroot ubuntu14 bash /buildcalibrd.sh

echo "cleaning up"
sudo umount ubuntu14/dev/pts
sudo umount ubuntu14/dev
sudo umount ubuntu14/proc
sudo umount ubuntu14/sys
sudo rm -rf ubuntu14
