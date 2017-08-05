#!/bin/bash
echo
echo "> # Never forget: DOCUMENTATION IS DOCUMENTATION!"
echo
sleep 2
echo
echo "> # Building calibrd on ubuntu 17.04"
echo
sleep 2
echo
echo "> # Install prerequisite packages"
echo
sleep 2
sudo apt install -y autoconf automake cmake g++-5 git libssl-dev libtool make pkg-config python3 python3-jinja2 libbz2-dev gcc-5
echo
echo "> # Adding Ubuntu 16.10 sources for Boobs version 1.60"
echo
sleep 2
if [ ! -f /etc/apt/sources.list.d/yakkety.list]; then
  sudo cp yakkety.list /etc/apt/sources.list.d/yakkety.list
fi
echo
echo "> # Updating dpkg repository index"
echo
sleep 2
sudo apt update
echo
echo "> # Installing Boobs 1.60. Please keep your hands in your pockets"
echo
sleep 2
sudo apt install -y libboost-chrono1.60-dev libboost-context1.60-dev libboost-coroutine1.60-dev libboost-date-time1.60-dev libboost-filesystem1.60-dev libboost-iostreams1.60-dev libboost-locale1.60-dev libboost-program-options1.60-dev libboost-serialization1.60-dev libboost-signals1.60-dev libboost-system1.60-dev libboost-test1.60-dev libboost-thread1.60-dev
#echo "Clone the steem"
#git clone https://github.com/steemit/steem -b v0.19.1
echo
echo "> # You are about to enter the Bog of eternal Steem, make sure you have first donned your biohazard suit"
echo
sleep 2
#cd steem
echo
echo "# Update submodules"
echo
sleep 2
git submodule update --init --recursive
echo
echo "> # Configuring Cmake crap (note, this is just for making your own personal copy of the blagchain, aka p2p node)... edit this script to build a witness, or impossible to run RPC node"
sleep 2
rm -rf build
mkdir build
cd build
CC="gcc-5" CXX="g++-5" CCFLAGS="-Os -pipe" CXXFLAGS="-Os -pipe" cmake -DCMAKE_BUILD_TYPE=Release -DLOW_MEMORY_NODE=ON -DSKIP_BY_TX_ID=ON ..
echo 
echo "> # Build it, and they probably won't come"
echo
sleep 2
make -j`nproc` steemd
make -j`nproc` cli_wallet
echo
echo "> # Prepare to sign away your life with your user password"
echo
sleep 2
CC="gcc-5" CXX="g++-5" CCFLAGS="-Os -pipe" CXXFLAGS="-Os -pipe" sudo make install
echo 
echo "> # Now, you may run 'steemd' and it will vandalise your hard drive with all their premine"
echo
cd ..
sudo rm -rf build
