#!/bin/bash
# Build calibrd inside Ubuntu 14.04 chroot
BINARYNAME="steemd"

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

# Check if prerequisite binary packages are installed
if [[ ! -f /.binpkgs ]]; then
  # Binary packages were not yet installed
  prstat "Installing prerequisite binary packages"
  apt install -y autoconf \
    g++ git libssl-dev libtool \
    make pkg-config doxygen \
    libncurses5-dev libreadline-dev \
    libbz2-dev python-dev \
    perl python3 python3-jinja2 \
    wget build-essential automake \
    autotools-dev &>/dev/null
  # Process complete, mark it  complete
  touch /.binpkgs
  prtrue "Prerequisite binary packages installed"
else
  # Process was already performed
  prtrue "Prerequiste binary packages already installed"
fi

# Check if Cmake 3.2.2 has been built
if [[ ! -f /.cmake ]]; then
  # Cmake 3.2.2 build has not been marked complete
  if [[ -d /cmake-3.2.2 ]]; then
    # Cmake 3.2.2 build was started but did not complete
    prfalse "Cmake 3.2.2 build was interrupted, cleaning up"
    rm -rf /cmake-3.2.2
  fi

  # Build Cmake 3.2.2
  prstat "Building and installing Cmake 3.2.2"
  tar zxf /cmake-3.2.2.tar.gz
  cd cmake-3.2.2
  
  # Configure build
  prstat "Configuring autotools build"
  ./configure

  # Build Cmake 3.2.2
  prstat "Building Cmake 3.2.2"
  make -j$(nproc)

  # Install Cmake 3.2.2
  make install

  # Process completed successfully, mark complete
  touch /.cmake
  prtrue "Cmake 3.2.2 build complete"
else
  # Cmake was already built and installed
  prtrue "Cmake 3.2.2 was previously built and installed"
fi

# Check to see if build was built and installed
if [[ ! -f /.boost ]]; then
  # Boost build has not been marked complete
  if [[ -d /boost_1_60_0 ]]; then
    # Boost build was interrupted
    prfalse "Boost build was interrupted, cleaning up"
    rm -rf /boost_1_60_0
  fi

  # Build and install Boost 1.60
  prstat "Building and installing Boost 1.60"
  
  # Create environment variable to tell build where to find boost
  export BOOST_ROOT=/boost_1_60_0
  
  # Unpack Boost source tarball
  cd /
  tar xjf /boost_1_60_0.tar.bz2

  # Start Boost 1.60 Build
  cd /boost_1_60_0
  ./bootstrap.sh "--prefix=$BOOST_ROOT"
  ./b2 install

  # Process completed successfully, mark complete
  touch /.boost
  prtrue "Boost build successful"
else
  # Boost was already built and installed
  prtrue "Boost was already built and installed"
fi

# Check to see if calibrd was already built
if [[ ! -f /.calibrd]]; then
  # If process was interrupted, clean up
  if [[ /calibrd/build ]]; then
    prfalse "$BINARYNAME build was interrupted, cleaning up"
    rm -rf /calibrd/build
  fi

  prstat "Initiating $BINARYNAME build"
  mkdir /calibrd/build
  cd /calibrd/build

  # Configure build
  prstat "Running Cmake autoconfiguration for $BINARYNAME"
  cmake -DCMAKE_BUILD_TYPE=Release ..

  # Build!
  prstat "building $BINARYNAME"
  make -j$(nproc) $BINARYNAME

  # Process completed successfully, mark complete
  touch /.calibrd
  prtrue "Completed $BINARYNAME build"
else
  # Was already built
  prtrue "$BINARYNAME was already built"
fi

#echo "dropping to shell inside chroot so you can test /calibrd/programs/steemd/steemd binary is operational"
#bash -i
# echo "Building cli_wallet"
# make -j$(nproc) cli_wallet
