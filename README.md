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

Sidenote: At first run this will download the base.txz tarball from FreeBSD. If your connection is slow then you can use another mirror by doing `setenv FreeBSD_mirror https://mirror.yandex.ru/freebsd` in (t)csh or `export FreeBSD_mirror=https://mirror.yandex.ru/freebsd` in (ba)sh

Now you can enter the jail
```
jailio console www0
```

you can also run scripts/programs from the host into the jail

```
jailio exec -f ~/scripts/install_packages.sh www0
```

you can make a snapshot of your jail (while running)

```
jailio snap www0
```

will make a snapshot with the snapshot name as current date with minutes/seconds

```
jailio snap www0@server_ready
```

will make a named snapshot to use later.


Now we will clone our snapshot

```
jailio create -s www0@server_ready -b bridge0 -d loc.illuriasecurity.com -a 192.168.100.20 www_prod
```


