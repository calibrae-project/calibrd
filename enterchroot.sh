#!/bin/bash
# Enter chroot containing built servers/apps for dev testing

# This is the hard-coded relative location also in build.sh and both must be changed (or maybe we can fix this later)
WORKROOT="$HOME/calibrd-work"

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
# or DOOOOOOOOOOOOOOOOOOOOMMMMM!
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
}

# Bind mount system folders and mark that procedure was started (so it can be cleaned up)
prstat "Mounting system folders inside chroot"
MOUNTEDSYSFOLDERS="1"
sudo mount -o bind /dev $WORKROOT/ubuntu14/dev
sudo mount -o bind /dev/pts $WORKROOT/ubuntu14/dev/pts
sudo mount -o bind /sys $WORKROOT/ubuntu14/sys
sudo mount -o bind /proc $WORKROOT/ubuntu14/proc
sudo cp /etc/resolv.conf $WORKROOT/ubuntu14/etc/resolv.conf

prfalse "You are now in the chroot, have fun!"
sudo chroot $WORKROOT/ubuntu14 bash -i

cleanup