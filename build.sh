#!/bin/bash
##############################################################################
#                                                                            #
#  build.sh                                                                  #
#                                                                            #
#  Automated build script for Calibrae's calibrd server                      #
#  This script is the 'outer' part that initiates and controls the chroot    #
#  build process                                                             #
#                                                                            #
##############################################################################
#                                                                            #
#  Credits for creation of this code can be found in the Git log.            #
#                                                                            #
##############################################################################
#                                                                            #
#  "LICENCE" for redistribution, derivation and use of this code             #
#                                                                            #
#  This is free and unencumbered software released into the public domain.   #
#                                                                            #
#  Anyone  is  free  to  copy,  modify,  publish,  use,  compile,  sell, or  #
#  distribute  this software,  either in source code  form or as a compiled  #
#  binary, for any purpose, commercial or non-commercial, and by any means.  #
#                                                                            #
#  In jurisdictions  that recognize  copyright laws,  the author or authors  #
#  of this software dedicate any and all copyright interest in the software  #
#  to the public  domain.   We make this dedication  for the benefit of the  #
#  public at  large and to  the detriment  of our heirs  and successors. We  #
#  intend  this  dedication  to  be   an  overt  act  of  relinquishment in  #
#  perpetuity  of  all present  and  future  rights to this  software under  #
#  copyright law.                                                            #
#                                                                            #
#  THE  SOFTWARE  IS  PROVIDED  "AS IS",  WITHOUT  WARRANTY  OF  ANY  KIND,  #
#  EXPRESS  OR  IMPLIED,  INCLUDING  BUT NOT LIMITED  TO  THE WARRANTIES OF  #
#  MERCHANTABILITY,   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  #
#  IN  NO EVENT  SHALL THE  AUTHORS BE LIABLE  FOR ANY  CLAIM,   DAMAGES OR  #
#  OTHER  LIABILITY,  WHETHER IN AN ACTION OF CONTRACT,  TORT OR OTHERWISE,  #
#  ARISING FROM,  OUT OF OR IN CONNECTION WITH  THE SOFTWARE  OR THE USE OR  #
#  OTHER DEALINGS IN THE SOFTWARE.                                           #
#                                                                            #
#  For more information, please refer to <http://unlicense.org/>             #
#                                                                            #
##############################################################################

REPODIR="$(pwd)"
BINARYNAME="steemd"
WORKROOT="$HOME/calibrd-work"
if [[ ! -d $WORKROOT ]]; then
  mkdir $WORKROOT
fi

# update submodules every time to be sure repo is always ready to build
cd $REPODIR
git submodule update --init --recursive

# Colours for console output
BLK='\033[0;30m';DGY='\033[1;30';RED='\033[0;31m';LRD='\033[1;31m';GRN='\033[0;32m';LGN='\033[1;32m'
ORG='\033[0;33m';YLW='\033[1;33m';BLU='\033[0;34m';LBL='\033[1;34m';PRP='\033[0;35m';LPR='\033[1;35m'
CYN='\033[0;36m';LCY='\033[1;36m';LGY='\033[0;37m';WHT='\033[1;37m'
#NC means reset colour to default terminal colour. ANSI colour terminal convention.
NC='\033[0m'
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
  
  prstat "Unmounting chroot bind mounts"
  sudo umount $WORKROOT/ubuntu14/dev/pts
  sudo umount $WORKROOT/ubuntu14/dev
  sudo umount $WORKROOT/ubuntu14/proc
  sudo umount $WORKROOT/ubuntu14/sys

  # Each step of the process has an initialising indication and
  # a completed indicator. Only initialised but incomplete steps
  # are cleaned up

  # Finally, remove the working folder if process was finished
  if [[ -f $WORKROOT/.complete ]]; then
    prstat "removing $WORKROOT"
    sudo rm -rf $WORKROOT
  fi
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
install_pkg 'gnupg2'

# Create work directory if it does not exist
if [[ ! -d $WORKROOT ]]; then
  prstat "Creating work directory $WORKROOT"
  mkdir -p $WORKROOT
fi

prstat "Entering $WORKROOT..."
cd $WORKROOT

# Check if base image has been created
if [[ ! -f $WORKROOT/.ubuntu14.tgz || ! -f $WORKROOT/ubuntu14.tgz ]]; then
  # Clean up mess if previous attempt was interrupted
  if [ -f $WORKROOT/ubuntu14.tgz ]; then
    prfalse "Base image creation was interrupted, cleaning up"
    rm -f $WORKROOT/ubuntu14.tgz
  fi
  prstat "Creating Ubuntu 14.04 base image"
  sudo pbuilder --create \
    --distribution trusty \
    --architecture amd64 \
    --basetgz $WORKROOT/ubuntu14.tgz \
    --debootstrapopts \
    --variant=buildd &>/dev/null
  
  # Process complete, mark it complete
  touch $WORKROOT/.ubuntu14.tgz
  prtrue "Completed creating image"
else
  prtrue "Ubuntu 14.04 image was already created"
fi

# Check if base build image was created
if [[ ! -f $WORKROOT/ubuntu14/.complete ]]; then
  # Clean up mess if previous attempt was interrupted
  if [[ -d $WORKROOT/ubuntu14 ]]; then
    prfalse "Base image unpacking was interrupted, cleaning up"
    sudo rm -rf $WORKROOT/ubuntu14
  fi

  prstat "Unpacking base build image"
  mkdir $WORKROOT/ubuntu14
  cd $WORKROOT/ubuntu14
  sudo tar zxfp ../ubuntu14.tgz
  cd ..
  
  # if this step needed to be repeated, then so do all subsequent
  rm $WORKROOT/.cmake $WORKROOT/.appimage $WORKROOT/.boost

  # Process complete, mark it complete
  touch $WORKROOT/ubuntu14/.complete
  prtrue "Ubuntu 14.04 base image unpacked successfully"
else
  # Process was already completed
  prtrue "Ubuntu 14.04 base image was already unpacked"
fi

# Check if Cmake download was marked completed, was downloaded yet, or correctly downloaded
if [[ ! -f $WORKROOT/.cmake || ! -f $WORKROOT/cmake-3.2.2.tar.gz || \
  ! $( sha256sum $WORKROOT/cmake-3.2.2.tar.gz | cut -d ' ' -f 1 ) == \
  "ade94e6e36038774565f2aed8866415443444fb7a362eb0ea5096e40d5407c78" ]]; then
  # Download was not completed, clean up
  if [[ -f $WORKROOT/cmake-3.2.2.tar.gz ]]; then
    # If file is not correct, delete intrerrupted download
    if [[ ! $( sha256sum $WORKROOT/cmake-3.2.2.tar.gz | cut -d ' ' -f 1 ) == \
      "ade94e6e36038774565f2aed8866415443444fb7a362eb0ea5096e40d5407c78" ]]; then
      prfalse "Cmake download was corrupted, retry build script"
    fi
    rm -f $WORKROOT/cmake-3.2.2.tar.gz
    prfalse "Removed incomplete download of Cmake 3.2.2"
  fi
  
  prstat "Downloading Cmake 3.2.2"
  cd $WORKROOT
  # Attempt to download Cmake 3.2.2 source tarball
  if wget http://www.cmake.org/files/v3.2/cmake-3.2.2.tar.gz &>/dev/null;  then 
    cp cmake-3.2.2.tar.gz $WORKROOT/ubuntu14/

    # TODO: check binary was not corrupted
    if [[ ! $( sha256sum $WORKROOT/cmake-3.2.2.tar.gz | cut -d ' ' -f 1 ) == \
      "ade94e6e36038774565f2aed8866415443444fb7a362eb0ea5096e40d5407c78" ]]; then
      prfalse "Cmake download was corrupted, retry build script"
      exit 1
    fi
    # Process complete, mark it complete
    touch $WORKROOT/.cmake
    prtrue "Cmake 3.2.2 was downloaded and copied into chroot"
  fi
else
  # Process was already completed
  prtrue "Cmake 3.2.2 was already installed and copied into chroot"
fi

# Check if AppImageKit was downloaded and copied into chroot
# and that the AppImage folder skeleton was created
if [[ ! -f $WORKROOT/.appimage || ! -d $WORKROOT/$BINARYNAME-x86_64.AppDir || ! -d $WORKROOT/cli_wallet-x86_64.AppDir ]]; then
  # Clean up mess if previous attempt was interrupted
  if [[ -f $WORKROOT/appimagetool-x86_64.AppImage ]]; then
    # remove previous incomplete download
    rm -f $WORKROOT/appimagetool-x86_64.AppImage
    prfalse "Removed incomplete download of AppImage tool"
  fi

  # Download AppImageKit
  cd $WORKROOT
  prstat "Downloading AppImageKit"
  wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" &>/dev/null
  # Make file executable
  chmod a+x appimagetool-x86_64.AppImage
  # Copy into chroot
  cp appimagetool-x86_64.AppImage $WORKROOT/ubuntu14/

  # Create AppDir skeleton in chroot
  prstat "Creating AppDir skeleton in chroot for $BINARYNAME"
  mkdir -p $WORKROOT/$BINARYNAME-x86_64.AppDir/usr/bin
  mkdir -p $WORKROOT/$BINARYNAME-x86_64.AppDir/usr/lib
  mkdir -p $WORKROOT/$BINARYNAME-x86_64.AppDir/lib
  echo "[Desktop Entry]">$WORKROOT/$BINARYNAME-x86_64.AppDir/$BINARYNAME.desktop
  echo "Name=$BINARYNAME">>$WORKROOT/$BINARYNAME-x86_64.AppDir/$BINARYNAME.desktop
  echo "Exec=$BINARYNAME">>$WORKROOT/$BINARYNAME-x86_64.AppDir/$BINARYNAME.desktop
  echo "Comment=$BINARYNAME server">>$WORKROOT/$BINARYNAME-x86_64.AppDir/$BINARYNAME.desktop
  echo "Icon=$BINARYNAME">>$WORKROOT/$BINARYNAME-x86_64.AppDir/$BINARYNAME.desktop
  echo "Type=server">>$WORKROOT/$BINARYNAME-x86_64.AppDir/$BINARYNAME.desktop
  echo "Categories=server blockchain">>$WORKROOT/$BINARYNAME-x86_64.AppDir/$BINARYNAME.desktop
  touch $WORKROOT/$BINARYNAME-x86_64.AppDir/$BINARYNAME.png

  prstat "Creating AppDir skeleton in chroot for cli_wallet"
  mkdir -p $WORKROOT/cli_wallet-x86_64.AppDir/usr/bin
  mkdir -p $WORKROOT/cli_wallet-x86_64.AppDir/usr/lib
  mkdir -p $WORKROOT/cli_wallet-x86_64.AppDir/lib
  echo "[Desktop Entry]">$WORKROOT/cli_wallet-x86_64.AppDir/cli_wallet.desktop
  echo "Name=cli_wallet">>$WORKROOT/cli_wallet-x86_64.AppDir/cli_wallet.desktop
  echo "Exec=cli_wallet">>$WORKROOT/cli_wallet-x86_64.AppDir/cli_wallet.desktop
  echo "Comment=cli_wallet for $BINARYNAME">>$WORKROOT/cli_wallet-x86_64.AppDir/cli_wallet.desktop
  echo "Icon=cli_wallet">>$WORKROOT/cli_wallet-x86_64.AppDir/cli_wallet.desktop
  echo "Type=cli app">>$WORKROOT/cli_wallet-x86_64.AppDir/cli_wallet.desktop
  echo "Categories=client blockchain">>$WORKROOT/cli_wallet-x86_64.AppDir/cli_wallet.desktop
  touch $WORKROOT/cli_wallet-x86_64.AppDir/cli_wallet.png

  # Process completed successfully, mark complete
  touch $WORKROOT/.appimage
  prtrue "Completed download of AppImageKit and copied with AppDir skeleton into chroot"
else
  # Process was already completed
  prtrue "AppImageKit already downloaded and copied into chroot"
fi

# Check if boost download was already done, or if the source is missing from the chroot
if [[ ! -f $WORKROOT/.boost || ! -f $WORKROOT/ubuntu14/boost_1_60_0.tar.bz2 ]]; then
  # Remove incomplete download if it was started and not finished
  if [[ -f $WORKROOT/boost_1_60_0.tar.bz2 ]]; then
    # Delete incomplete download
    rm -f $WORKROOT/boost_1_60_0.tar.bz2
    prfalse "Removed incomplete download of Boost source"
  fi

  # If boost sources are not present or not correct, download them
  if [[ ! -f $WORKROOT/boost_1_60_0.tar.bz2 || ! $( sha256sum boost_1_60_0.tar.bz2 | cut -d ' ' -f 1 ) == \
      "686affff989ac2488f79a97b9479efb9f2abae035b5ed4d8226de6857933fd3b" ]]; then
    # Download Boost
    prstat "Downloading boost 1.60..."
    URL='http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.bz2/download'
    wget -c "$URL" -O $WORKROOT/boost_1_60_0.tar.bz2 &>/dev/null
    
    # Check that download was correct
    [ $( sha256sum boost_1_60_0.tar.bz2 | cut -d ' ' -f 1 ) == \
      "686affff989ac2488f79a97b9479efb9f2abae035b5ed4d8226de6857933fd3b" ] \
      || ( prfalse 'Corrupt download, retry build script' ; exit 1 )
  fi

  # If tarball is not in chroot, copy it in, and remove build completion flag if present
  if [[ ! -f $WORKROOT/ubuntu14/boost_1_60_0.tar.bz2 ]]; then
    # Copy source tarball into chroot
    cp $WORKROOT/boost_1_60_0.tar.bz2 $WORKROOT/ubuntu14/
    rm $WORKROOT/ubuntu14/.boost
  fi

  # Mark process complete
  touch $WORKROOT/.boost
  prtrue "Completed download of boost and placed into chroot"
else
  # Process was already completed
  prtrue "Already have Boost downloaded and copied into chroot"
fi 

# If user has added clean launch parameters, completely remove the repo within the chroot
if [[ $1 = "clean" ]]; then
  prstat "User has requested to clean repository in chroot"
  sudo rm -rf $WORKROOT/ubuntu14/calibrd
fi

# Copy all updated files in the repository to the work directory
prstat "Updating $BINARYNAME Git repository..."
cp -rfup $REPODIR $WORKROOT/ubuntu14/

# Test whether anything in the repo have been changed
# If there is change, unset the complete marker inside the repo in the chroot
# Code taken from https://www.jpablo128.com/how-to-detect-changes-in-a-directory-with-bash/
DIR_TO_CHECK="$REPODIR"
PATH_TO_EXCLUDE="$REPODIR/{*.md}"

OLD_SUM_FILE="$HOME/calibrd_stat.txt"

# If this is first run, create an empty stat file
if [[ -e $OLD_SUM_FILE ]]
then OLD_SUM="$(cat $OLD_SUM_FILE)"
else OLD_SUM="nothing"
fi

NEW_SUM=`find $DIR_TO_CHECK/* \! -path "$PATH_TO_EXCLUDE"  -print0| xargs -0 du -b --time --exclude=$PATH_TO_EXCLUDE | sort -k4,4 | sha1sum | awk '{print $1}'`

if [[ "$OLD_SUM" != "$NEW_SUM" || $1 = "rebuild" || ! -f $WORKROOT/ubuntu14/calibrd/programs/steemd/steemd ]]; then
  prstat "Stuff has changed. Running build"
  # Remove build completed flag
  if [[ -f $WORKROOT/ubuntu14/calibrd/build/.calibrd ]]; then rm -f $WORKROOT/ubuntu14/calibrd/build/.calibrd
  fi

  # Bind mount system folders and mark that procedure was started (so it can be cleaned up)
  prstat "Mounting system folders inside chroot"
  MOUNTEDSYSFOLDERS="1"
  sudo mount -o bind /dev $WORKROOT/ubuntu14/dev
  sudo mount -o bind /dev/pts $WORKROOT/ubuntu14/dev/pts
  sudo mount -o bind /sys $WORKROOT/ubuntu14/sys
  sudo mount -o bind /proc $WORKROOT/ubuntu14/proc
  sudo cp /etc/resolv.conf $WORKROOT/ubuntu14/etc/resolv.conf

  # Copy chroot build script into chroot and run it
  prstat "Starting chrooted build script"
  sudo chroot $WORKROOT/ubuntu14 bash /calibrd/buildcalibrd.sh $1

  echo $NEW_SUM > $OLD_SUM_FILE
  cleanup
else
  prtrue "No changes in $REPODIR, nothing to do"
fi

# The End