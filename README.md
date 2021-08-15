# Jailer
## The final word in container orchestration

Jailer is meant to be as integrated as possible with FreeBSD Jail subsystem


THIS IS ALPHA SOFTWARE: HERE BE DRAGONS

## Installation

First, clone the repo into a FreeBSD machine

Next, run `make install`

## Configuration

Jailer loves to have ZFS, so make sure you have a system with ZFS

> In case you don't, you can create a ZFS pool in your existing filesystem by doing `truncate -s 10G /usr/local/disk0.img; zpool create zroot /usr/local/disk0.img`


To create a ZFS dataset for Jails, run the following

```
zfs create -o mountpoint=/usr/local/jails zroot/jails
```

Then, need to specify the ZFS dataset for Jailer and enable Jails

```
sysrc jailer_dir="zfs:zroot/jails"
sysrc jail_enable="YES"
```

Jailer uses the [`jail.conf.d`](https://reviews.freebsd.org/D24570) patch, it will need to patch your `/etc/rc.d/jail` script.

To patch, you can run

```
jailer init
```


## Usage

### Networking

First you will need to create a switch

```console
sysrc cloned_interfaces="bridge0"
sysrc ifconfig_bridge0="inet 10.0.0.1 netmask 0xffffff00 descr jails-bridge"
```

### Bootstraping the base system
To bootstrap the base system run the bootstrap subcommand

```
jailer bootstrap 12.2-RELEASE
```

This will download and extract `base.txz` from `https://download.freebsd.org/ftp`

> If you want to use a mirror closer to you, you can change the `FreeBSD_mirror` environment variable, e.g. `setenv FreeBSD_mirror https://mirror.yandex.ru/freebsd`

To list all bootstrapped base systems run the `bootstrap` subcommand without arguments.

```console
# jailer bootstrap
12.2-RELEASE
```
### Creating Jails

To create a new jail use the `create` subcommand

```
jailer create -r 12.2-RELEASE -b bridge0 -d dev.mydomain.com -a 10.0.0.10 www0
```

The `-r` flag is to specify the release, `-b` is for the bridge, `-d` is the domain and `-a` is the IP address.

No man pages yet, but the `help` subcommand can help you out!

```
# jailer help create
Usage:  jailer create  [-r version | -s snap] [-b bridge] [-n] [-d domain] [-a addr] [-f exec.sh] [-c dir/file] name
Options:
  -r version    : FreeBSD-version as base of Jail
  -s snapshot   : Clone from snapshot as base of Jail
  -b bridge     : Attach to bridge
  -n            : Make Jail less noisy
  -d domain     : Set domain in Jail
  -a addr       : Use addr as address or DHCP to use dhclient in Jail
  -f exec.sh    : Execute exec.sh in Jail after creation
  -c dir/file   : Copy dir/file into /tmp of Jail
```


Now you can enter the Jail

```
jailer console www0
```

you can also run scripts/programs from the host into the jail

```
jailer exec -f ~/scripts/install_packages.sh www0
```

you can make a snapshot of your jail (while running)

```
jailer snap www0
```

will make a snapshot with the snapshot name as current date with minutes/seconds

```
jailer snap www0@server_ready
```

will make a named snapshot to use later.


Now we will clone our snapshot

```
jailer create -s www0@server_ready -b bridge0 -d srv.illuriasecurity.com -a 10.0.0.81 www_prod
```


