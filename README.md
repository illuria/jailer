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

First you will need to create a switch
```
jailio switch create -a 192.168.100.1/24 public
```

Sidenote: the name public is just a description, it does nothing

Now you can create a Jail

```
jailio create -r 12.2-RELEASE -b bridge0 -d loc.illuriasecurity.com -a 192.168.100.10 www0
```

you can enter it
```
jailio console www0
```

you can also run scripts/programs from the host into the jail

```
jailio exec -f ~/scripts/install_packages.sh www0
```


