
![Calibrae Hummingbird Logo](https://raw.githubusercontent.com/steempunks/calibrae/master/assets/calibrae-small.png)

 # Calibrae 
 #### The Decentralised Distributed Social Network

This is the fork that none of the preminers wanted to happen. This is the fork that is happening despite the spaghetti of the C++ code contained therein. The primary reason for the fork is to change the chain ID so there will not be any muddle between this and the old chain. 

With that in place, and a lot of edits to improve the documentation, the chain will be amended to snapshot everyone's accounts at a certain time, when there is enough people to run enough nodes to make the new network operational, and a webserver to provide an interface (probably busy's as it is likely easier to get running) so that users can start working on the new chain, with the premine deleted.

The exact edit will be decided according to the opinions and ideas of those who join this project. The name has been revised in order to avoid namespace conflicts, and to better express the ideas behind this fork.

# What is Calibrae

Calibrae is a fork of Steem that is simplified, and will launch with a premine-removed, snapshot state of the Steem blockchain at the day of launch. SBD will be removed, simplifying the currency and witness operation.

  - Currency symbol JUICE
  - Deposit contract Stake
  - 10% APR inflation narrowing to 1% APR over 20 years.

# Public Announcement & Discussion

Calibrae was announced and the first fork was made on the 4th of August, 2017

https://steemit.com/steem/@elfspice/the-steem-fork-begins-meet-steemit-reloaded

*See [transition/ROADMAP.md](transition/ROADMAP.md) for information about the planned changes as well as scripts and code relating to the process that will be placed in [transition](transition).*

# Quickstart

Just want to get up and running quickly?  Try deploying a prebuilt
dockerized container.  Both common binary types are included.

## Dockerized p2p Node

To run a p2p node (ca. 2GB of memory is required at the moment):

    docker run \
        -d -p 2001:2001 -p 8090:8090 --name steemd-default \
        steemit/steem

    docker logs -f steemd-default  # follow along

## Dockerized Full Node

To run a node with *all* the data (e.g. for supporting a content website)
that uses ca. 14GB of memory and growing:

    docker run \
        --env USE_WAY_TOO_MUCH_RAM=1 --env USE_FULL_WEB_NODE=1 \
        -d -p 2001:2001 -p 8090:8090 --name steemd-full \
        steemit/steem

    docker logs -f steemd-full

# Environment variables

There are quite a few environment variables that can be set to run steemd in different ways:

* `USE_WAY_TOO_MUCH_RAM` - if set to true, steemd starts a 'full node'
* `USE_FULL_WEB_NODE` - if set to true, a default config file will be used that enables a full set of API's and associated plugins.
* `USE_NGINX_FRONTEND` - if set to true, this will enable an NGINX reverse proxy in front of steemd that proxies websocket requests to steemd. This will also enable a custom healtcheck at the path '/health' that lists how many seconds away from current blockchain time your node is. It will return a '200' if it's less than 60 seconds away from synced.
* `USE_MULTICORE_READONLY` - if set to true, this will enable steemd in multiple reader mode to take advantage of multiple cores (if available). Read requests are handled by the read-only nodes, and write requests are forwarded back to the single 'writer' node automatically. NGINX load balances all requests to the reader nodes, 4 per available core. This setting is still considered experimental and may have trouble with some API calls until further development is completed.
* `HOME` - set this to the path where you want steemd to store it's data files (block log, shared memory, config file, etc). By default `/var/lib/steemd` is used and exists inside the docker container. If you want to use a different mountpoint (like a ramdisk, or a different drive) then you may want to set this variable to map the volume to your docker container.

# PaaS mode

Steemd now supports a PaaS mode (platform as a service) that currently works with Amazon's Elastic Beanstalk service. It can be launched using the following environment variables:

* `USE_PAAS` - if set to true, steemd will launch in a format that works with AWS EB. Containers will exit upon failure so that they can be relaunched automatically by ECS. This mode assumes `USE_WAY_TOO_MUCH_RAM` and `USE_FULL_WEB_NODE`, they do not need to be also set.
* `S3_BUCKET` - set this to the name of the S3 bucket where you will store shared memory files for steemd in Amazon S3. They will be stored compressed in bz2 format with the file name `blockchain-$VERSION-latest.tar.bz2`, where $VERSION is the release number followed by the git short commit hash stored in each docker image at `/etc/steemdversion`.
* `SYNC_TO_S3` - if set to true, the node will function to only generate shared memory files and upload them to the specified S3 bucket. This makes fast deployments and autoscaling for steemd possible.

# Seed Nodes

A list of some seed nodes to get you started can be found in
[doc/seednodes.txt](doc/seednodes.txt).

This same file is baked into the docker images and can be overridden by
setting `STEEMD_SEED_NODES` in the container environment at `docker run`
time to a whitespace delimited list of seed nodes (with port).

# Building

See [doc/building.md](doc/building.md) for detailed build instructions, including
compile-time options, and specific commands for Linux (Ubuntu LTS) or macOS X.

# Testing

See [doc/testing.md](doc/testing.md) for test build targets and info
on how to use lcov to check code test coverage.

# System Requirements

For a full web node, you need at least 55GB of space available. Steemd uses a memory mapped file which currently holds 36GB of data and by default is set to use up to 40GB. The block log of the blockchain itself is a little over 10GB. It's highly recommended to run steemd on a fast disk such as an SSD or by placing the shared memory files in a ramdisk and using the `--shard-file-dir=/path` command line option to specify where. At least 16GB of memory is required for a full web node. Seed nodes (p2p mode) can run with as little as 4GB of memory. Any CPU with decent single core performance should be sufficient.

On Linux use the following Virtual Memory configuration for the initial sync and subsequent replays. It is not needed for normal operation.

```
echo    75 | sudo tee /proc/sys/vm/dirty_background_ratio
echo  1000 | sudo tee /proc/sys/vm/dirty_expire_centisec
echo    80 | sudo tee /proc/sys/vm/dirty_ratio
echo 30000 | sudo tee /proc/sys/vm/dirty_writeback_centisec
```
