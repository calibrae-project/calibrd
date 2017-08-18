#!/bin/bash
# set locale to standart en_US.UTF-8 in case user uses other locale, to stop filling build output with dumb locale errors
if [[ ! -f /.locale ]]; then
  locale-gen en_US.UTF-8

  export LANGUAGE="en_US.UTF-8"
  export LC_ALL="en_US.UTF-8"
  export LC_TIME="en_US.UTF-8"
  export LC_MONETARY="en_US.UTF-8"
  export LC_ADDRESS="en_US.UTF-8"
  export LC_TELEPHONE="en_US.UTF-8"
  export LC_NAME="en_US.UTF-8"
  export LC_MEASUREMENT="en_US.UTF-8"
  export LC_IDENTIFICATION="en_US.UTF-8"
  export LC_NUMERIC="en_US.UTF-8"
  export LC_PAPER="en_US.UTF-8"
  export LANG="en_US.UTF-8"

  touch /.locale
fi

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
    autotools-dev clang &>/dev/null
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
if [[ ! -f /calibrd/build/.$BINARYNAME || ! -f /calibrd/build/programs/steemd/steemd || ! -f /calibrd/build/programs/cli_wallet/cli_wallet || \
  $1 == "rebuild" ]]; then

  prstat "Initiating $BINARYNAME and cli_wallet build"
  # if this is the first run, create build folder
  if [[ ! -f /calibrd/build ]]; then
    mkdir /calibrd/build
  fi
  cd /calibrd/build

  # Create environment variable to tell build where to find boost
  export BOOST_ROOT=/boost_1_60_0

  # Configure build
  prstat "Running Cmake autoconfiguration for $BINARYNAME"
  cmake -DCMAKE_BUILD_TYPE=Release ..

  # Build!
  prstat "Building $BINARYNAME"
  if [[ $1 == "rebuild" ]]; then
    make clean
  fi
  make -j$(nproc)
  make install

  if [[ $? -eq 0 ]]; then
    # Process completed successfully, mark complete
    touch /calibrd/build/.$BINARYNAME
    prtrue "Completed $BINARYNAME build"
  fi
else
  # Was already built
  prtrue "$BINARYNAME and cli_wallet were already built"
fi

#bash -i

# echo "Building cli_wallet"
# make -j$(nproc) cli_wallet
