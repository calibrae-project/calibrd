#!/bin/bash
OUTPUTDIR="$(pwd)"
WORKROOT="/tmp/calibrd-work"
cd /tmp
if [ ! -d calibrd-work ]; then
  mkdir calibrd-work
fi
cd $WORKROOT

if [ ! -d $WORKROOT/calibrd ]; then

  echo "Cloning calibrd Git repository"
  git clone https://github.com/calibrae-project/calibrd.git
  echo "Entering repository"
  cd $WORKROOT/calibrd

  echo "Updating submodules"
  git submodule update --init --recursive

fi

cd $WORKROOT

echo "Installing pbuilder"
sudo apt install -y debootstrap pbuilder devscripts

echo "Creating ubuntu 14.04 base image"
if [ ! -f $WORKROOT/ubuntu14.tgz ]; then
  sudo pbuilder --create \
    --distribution trusty \
    --architecture amd64 \
    --basetgz $WORKROOT/ubuntu14.tgz \
    --debootstrapopts \
    --variant=buildd
fi

if [ ! -d $WORKROOT/ubuntu14 ]; then
  echo "Unpacking base build image"
  mkdir $WORKROOT/ubuntu14
  cd $WORKROOT/ubuntu14
  sudo tar xvfp ../ubuntu14.tgz
  cd ..
fi

cd $WORKROOT
if [ ! -f cmake-3.2.2.tar.gz ]; then
  echo "downloading cmake 3"
  wget http://www.cmake.org/files/v3.2/cmake-3.2.2.tar.gz
fi
cp cmake-3.2.2.tar.gz $WORKROOT/ubuntu14/

cd $WORKROOT
if [ ! -f $WORKROOT/appimagetool-x86_64.AppImage ]; then
  echo "Downloading AppImageKit"
  wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
  chmod a+x appimagetool-x86_64.AppImage
fi
cp appimagetool-x86_64.AppImage $WORKROOT/ubuntu14/

echo "copying AppDir skeleton to chroot"
cp -rf $WORKROOT/calibrd/calibrd.AppDir $WORKROOT/ubuntu14/

if [ ! -f $WORKROOT/boost_1_60_0.tar.bz2 ]; then
  echo "downloading boost 1.60"
  URL='http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.bz2/download'
  wget -c "$URL" -O $WORKROOT/boost_1_60_0.tar.bz2
  [ $( sha256sum boost_1_60_0.tar.bz2 | cut -d ' ' -f 1 ) == \
    "686affff989ac2488f79a97b9479efb9f2abae035b5ed4d8226de6857933fd3b" ] \
    || ( echo 'Corrupt download' ; exit 1 )
fi 
cp $WORKROOT/boost_1_60_0.tar.bz2 $WORKROOT/ubuntu14/

cp -rf $WORKROOT/calibrd $WORKROOT/ubuntu14/

cd $WORKROOT

echo "Mounting system folders inside chroot"
sudo mount -o bind /dev $WORKROOT/ubuntu14/dev
sudo mount -o bind /dev/pts $WORKROOT/ubuntu14/dev/pts
sudo mount -o bind /sys $WORKROOT/ubuntu14/sys
sudo mount -o bind /proc $WORKROOT/ubuntu14/proc
sudo cp /etc/resolv.conf $WORKROOT/ubuntu14/etc/resolv.conf

echo "Starting chrooted build script"
sudo cp $WORKROOT/calibrd/buildcalibrd.sh $WORKROOT/ubuntu14/
sudo chroot $WORKROOT/ubuntu14 bash /buildcalibrd.sh

echo "cleaning up"
sudo umount $WORKROOT/ubuntu14/dev/pts
sudo umount $WORKROOT/ubuntu14/dev
sudo umount $WORKROOT/ubuntu14/proc
sudo umount $WORKROOT/ubuntu14/sys

echo "copying out completed steemd, which will run on any version of ubuntu from 14.04 to 17.04"
cp $WORKROOT/ubuntu14/calibrd/programs/steemd/steemd $OUTPUTDIR

sudo rm -rf $WORKROOT/ubuntu14
#rm -rf $WORKROOT/calibrd