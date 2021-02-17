# Jailio
## The final word in container orchestration

Jailio is meant to be as integrated as possible with FreeBSD Jail subsystem


THIS IS ALPHA SOFTWARE: HERE BE DRAGONS

## Installation

First, clone the repo into a FreeBSD machine
Next, run `make install`

## Configuration

Jailio loves to have ZFS, so make sure you have a system with ZFS

To create a ZFS dataset for Jails, run the following
```
zfs create -o mountpoint=/usr/local/jails zroot/jails
```

Then, need to specify the ZFS dataset for Jailio and enable Jails
```
sysrc jailio_dir="zfs:zroot/jails"
sysrc jail_enable="YES"
```

## Usage

TODO
