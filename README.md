
![Calibrae Hummingbird Logo](https://raw.githubusercontent.com/calibrae-project/assets/master/calibrae-header.png)

 # Calibrae 
 #### The Decentralised Distributed Social Network

# What is Calibrae

Calibrae is a social network system built on a variant of Byzantine Fault Tolerance which uses peer review via election of Witness operators to implement defences against byzantine behaviour of actors within the system.

  - Currency symbol JUICE
  - Vote power deposit instrument called Stake with 1% per day drawdown of remaining balance
  - Incentivised voting for network operator leaders
  - 5% flat issuance rate of primary token JUICE starting with an initial preload of the rewards pool of 1024 Juice

# Public Announcement & Discussion

Calibrae was announced and the first fork was made on the 4th of August, 2017. The first proper public announcement was on 11 August 2017, on reddit (we are not going to refer to the steemit.com post of the 4th of August, as that might up and disappear any time):

https://www.reddit.com/r/BlockChain/comments/6t0iud/calibrae_a_fork_of_the_steem_blockchain/

You can join the discussion at http://calibrae.freeforums.net - or if you want to chat with the team and miscellaneous supporters at the Discord chat: https://discord.gg/AmyB6ee

# Building
It should be possible to build this on any version of Debian or derivatives with a kernel version at or above the one found in Ubuntu 14.04.

> ## Notes
> Due to some difficulties with getting the binaries to link and run inside other debian systems, and no immediate solution, everything happens inside a chroot. The only restriction, apart from this minor inconvenience, is that you are inside a chroot ;). This will be fixed later by changing the binary output to be a proper static binary with all its dependencies included. The only showstopper for Ubuntu 17.04 was libreadline, every other dependency was present (and the server works, but not the cli_wallet). 
> 
> Yes, this means that there is a good chance the binary created in `<repo directory>/build/programs/steemd` will run in any version of ubuntu from 14 onwards (well, no need for the chroot there at all, everything will work), and probably in any version of debian from 7, and any other debian derivative of similar vintage, such as Linux Mint.

To facilitate easy building, there is a script called `build.sh` which cleanly rebuilds all the prerequisites and recognises if there has been changes to the repository contents. Invoke it like this, while your shell is inside the directory of the repository:

`bash build.sh`

If you have deleted any files from the repository, while there is the remainder of the chroot environment still existing and completed, execute the clean command to have the repository re-copied into the chroot, sans the deleted files:

`bash build.sh clean`

To force an unchanged repository to re-run the build:

`bash build.sh rebuild`

To run and use/test the produced binaries, run the following command:

`bash enterchroot.sh`

> This build script has been created so as to reduce the cognitive burden on developers, and early testers, and will eventually produce a universal binary down the track. The Calibrae dev team cares about its developers, and those who want to operate our software.

Below remains the rest of the original contents of this file:

---

~~See [doc/building.md](doc/building.md) for detailed build instructions, including compile-time options, and specific commands for Linux (Ubuntu LTS) or macOS X.~~

# ~~Testing~~

~~See [doc/testing.md](doc/testing.md) for test build targets and info on how to use lcov to check code test coverage.~~

# ~~System Requirements~~

~~For a full web node, you need at least 55GB of space available. Steemd uses a memory mapped file which currently holds 36GB of data and by default is set to use up to 40GB. The block log of the blockchain itself is a little over 10GB. It's highly recommended to run steemd on a fast disk such as an SSD or by placing the shared memory files in a ramdisk and using the `--shard-file-dir=/path` command line option to specify where. At least 16GB of memory is required for a full web node. Seed nodes (p2p mode) can run with as little as 4GB of memory. Any CPU with decent single core performance should be sufficient.~~

~~On Linux use the following Virtual Memory configuration for the initial sync and subsequent replays. It is not needed for normal operation.~~

These commands will probably not be needed until the chain gets beyond about 4Gb in size.

```
echo    75 | sudo tee /proc/sys/vm/dirty_background_ratio
echo  1000 | sudo tee /proc/sys/vm/dirty_expire_centisec
echo    80 | sudo tee /proc/sys/vm/dirty_ratio
echo 30000 | sudo tee /proc/sys/vm/dirty_writeback_centisec
```
