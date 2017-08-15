#!/bin/bash
OUTPUTDIR="$(pwd)"
BINARYNAME="steemd"
WORKROOT="/tmp/calibrd-work"

# Colours for console output
BLK='\033[0;30m';DGY='\033[1;30';RED='\033[0;31m';LRD='\033[1;31m';GRN='\033[0;32m';LGN='\033[1;32m'
ORG='\033[0;33m';YLW='\033[1;33m';BLU='\033[0;34m';LBL='\033[1;34m';PRP='\033[0;35m';LPR='\033[1;35m'
CYN='\033[0;36m';LCY='\033[1;36m';LGY='\033[0;37m';WHT='\033[1;37m';NC='\033[0m'
PFX="###"

function prstat {
  printf "$PFX $1\n"
}
function prtrue {
  printf "$GRN$PFX $1$NC\n"
}
function prfalse {
  printf "$RED$PFX $1$NC\n"
}

# We need to trap Ctrl-C because this script bindmounts system virtual folders and must be cleaned up
trap cleanup INT

# Cleanup functions are atomic, testing for completion variables being set
function cleanup {
  # First we want to put a newline after the ^C that the console prints, for aesthetic purposes
  printf "\n"
  
  prstat "Cleaning up..."
  
  # Remove the chroot if it has been created
  if [ $MOUNTEDSYSFOLDERS ]; then
    prstat "Unmounting chroot bind mounts"
    sudo umount $WORKROOT/ubuntu14/dev/pts
    sudo umount $WORKROOT/ubuntu14/dev
    sudo umount $WORKROOT/ubuntu14/proc
    sudo umount $WORKROOT/ubuntu14/sys
  fi

  # Each step of the process has an initialising indication and
  # a completed indicator. Only initialised but incomplete steps
  # are cleaned up

  # Finally, remove the working folder if process was finished
  if [[ -f $WORKROOT/.complete ]]; then
    prstat "removing $WORKROOT"
    sudo rm -rf $WORKROOT
  fi

  # Let's blow this popstand!
  exit
}


prstat "Building $GRN$BINARYNAME$NC..."

function is_installed {
  dpkg-query -Wf'${db:Status-abbrev}' "$1" 2>/dev/null | grep -q '^i'
}

# Install a package if it has not been
function install_pkg {
  # Tests if package name in first parameter is installed, installs it if it isn't, or reports that it is
  if is_installed "$1"; then
    prtrue "$1 is installed"
  else
    prstat "Installing $1..."
    sudo apt-get install -y $1 &>/dev/null
  fi
}

prstat "Checking for necessary prerequisites..."
install_pkg 'devscripts'
install_pkg 'debootstrap'
install_pkg 'pbuilder'

# Create work directory if it does not exist
if [[ ! -d $WORKROOT ]]; then
  prstat "Creating work directory $WORKROOT"
  mkdir -p $WORKROOT
fi

prstat "Entering $WORKROOT..."
cd $WORKROOT


if [[ -f $WORKROOT/ubuntu14.tgz ]]; then
  if [[ ! -f $WORKROOT/.ubuntu14.tgz ]]; then
    prfalse "Base image creation was interrupted, cleaning up"
    rm -f $WORKROOT/ubuntu14.tgz
  fi
fi

if [ ! -f $WORKROOT/ubuntu14.tgz ]; then
  prstat "Creating Ubuntu 14.04 base image"
  sudo pbuilder --create \
    --distribution trusty \
    --architecture amd64 \
    --basetgz $WORKROOT/ubuntu14.tgz \
    --debootstrapopts \
    --variant=buildd &>/dev/null
  touch $WORKROOT/.ubuntu14.tgz
  prtrue "Completed creating image"
else
  prtrue "Ubuntu 14.04 image was already created"
fi

if [[ ! -f $WORKROOT/ubuntu14/.complete ]]; then
  if [[ -d $WORKROOT/ubuntu14 ]]; then
    prfalse "Base image unpacking was interrupted, cleaning up"
    sudo rm -rf $WORKROOT/ubuntu14
  fi
fi

if [ ! -d $WORKROOT/ubuntu14 ]; then
  prstat "Unpacking base build image"
  mkdir $WORKROOT/ubuntu14
  cd $WORKROOT/ubuntu14
  sudo tar zxfp ../ubuntu14.tgz
  cd ..
  touch $WORKROOT/ubuntu14/.complete
  prtrue "Ubuntu 14.04 base image unpacked successfully"
else
  prtrue "Ubuntu 14.04 base image was already unpacked"
fi

if [[ ! -f $WORKROOT/.cmake ]]; then
  if [[ -f $WORKROOT/cmake-3.2.2.tar.gz ]]; then
    rm -f $WORKROOT/cmake-3.2.2.tar.gz
    prfalse "Removed incomplete download of Cmake 3.2.2"
  fi
fi

cd $WORKROOT
if [[ ! -f $WORKROOT/cmake-3.2.2.tar.gz ]]; then
  prstat "Downloading Cmake 3.2.2"
  if wget http://www.cmake.org/files/v3.2/cmake-3.2.2.tar.gz &>/dev/null;  then 
    touch $WORKROOT/.cmake
  fi
fi
cp cmake-3.2.2.tar.gz $WORKROOT/ubuntu14/

if [[ ! -f $WORKROOT/.appimage ]]; then
  if [[ -f $WORKROOT/appimagetool-x86_64.AppImage ]]; then
    rm -f $WORKROOT/appimagetool-x86_64.AppImage
    prfalse "Removed incomplete download of AppImage tool"
  fi
fi

cd $WORKROOT
if [ ! -f $WORKROOT/appimagetool-x86_64.AppImage ]; then
  prstat "Downloading AppImageKit"
  wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" &>/dev/null
  chmod a+x appimagetool-x86_64.AppImage
  cp appimagetool-x86_64.AppImage $WORKROOT/ubuntu14/
  prstat "Copying AppDir skeleton to chroot"
  cp -rf $WORKROOT/calibrd/calibrd.AppDir $WORKROOT/ubuntu14/
  touch $WORKROOT/.appimage
  prtrue "Completed download of AppImageKit and copied with AppDir skeleton into chroot"
else
  prtrue "AppImageKit already downloaded and copied into chroot"
fi

if [[ ! -f $WORKROOT/.boost ]]; then
  if [[ -f $WORKROOT/boost_1_60_0.tar.bz2 ]]; then
    rm -f $WORKROOT/boost_1_60_0.tar.bz2
    prfalse "Removed incomplete download of Boost source"
  fi
fi

if [ ! -f $WORKROOT/.boost ]; then
  prstat "Downloading boost 1.60..."
  URL='http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.bz2/download'
  wget -c "$URL" -O $WORKROOT/boost_1_60_0.tar.bz2 &>/dev/null
  [ $( sha256sum boost_1_60_0.tar.bz2 | cut -d ' ' -f 1 ) == \
    "686affff989ac2488f79a97b9479efb9f2abae035b5ed4d8226de6857933fd3b" ] \
    || ( prfalse 'Corrupt download' ; exit 1 )
  cp $WORKROOT/boost_1_60_0.tar.bz2 $WORKROOT/ubuntu14/
  touch $WORKROOT/.boost
  prtrue "Completed download of boost and placed into chroot"
else
  prtrue "Already have Boost downloaded and moved into chroot"
fi 

if [[ ! -f $WORKROOT/.calibrd ]]; then
  if [[ -f $WORKROOT/boost_1_60_0.tar.bz2 ]]; then
    rm -f $WORKROOT/boost_1_60_0.tar.bz2
    prfalse "Removed incomplete download of Boost source"
  fi
fi

# If cloning was interrupted, clean it out
if [[ ! -f $WORKROOT/calibrd/.complete ]]; then
  prfalse "Cloning was interrupted, removing incomplete folder"
  rm -rf $WORKROOT/calibrd
fi

if [[ ! -d $WORKROOT/calibrd ]]; then
  # Clone the calibrd repository
  prstat "Cloning $BINARYNAME Git repository..."
  git clone https://github.com/calibrae-project/calibrd.git &>/dev/null

  prstat "Entering repository"
  cd $WORKROOT/calibrd

  prstat "Updating submodules"
  git submodule update --init --recursive &>/dev/null

  # Task is complete, does not need to be repeated
  cp -rf $WORKROOT/calibrd $WORKROOT/ubuntu14/
  touch $WORKROOT/calibrd/.complete
  prtrue "Completed cloning repository and copied into chroot"
else
  prtrue "$BINARYNAME repository was already cloned and copied into chroot"
fi

prstat "Mounting system folders inside chroot"
MOUNTEDSYSFOLDERS="1"
sudo mount -o bind /dev $WORKROOT/ubuntu14/dev
sudo mount -o bind /dev/pts $WORKROOT/ubuntu14/dev/pts
sudo mount -o bind /sys $WORKROOT/ubuntu14/sys
sudo mount -o bind /proc $WORKROOT/ubuntu14/proc
sudo cp /etc/resolv.conf $WORKROOT/ubuntu14/etc/resolv.conf

prstat "Starting chrooted build script"
sudo cp $WORKROOT/calibrd/buildcalibrd.sh $WORKROOT/ubuntu14/
sudo chroot $WORKROOT/ubuntu14 bash /buildcalibrd.sh

prstat "copying out completed steemd, which will run on any version of ubuntu from 14.04 to 17.04"
cp $WORKROOT/ubuntu14/calibrd/build/programs/steemd/steemd $OUTPUTDIR/

cleanup
# The End