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

### Basic Networking

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
jailer create -s www0@server_ready -b bridge0 -d srv.illuriasecurity.com -a 10.0.0.80 www_prod
```

### Listing Jails

To list all your Jails use the `list` subcommand

```
# jailer list
NAME      STATE   JID  HOSTNAME                          IPv4
www0      Active  1    www0.dev.mydomain.com             10.0.0.10/24
www_prod  Active  2    www_prod.srv.illuriasecurity.com  10.0.0.80/24
```

It can also provide a JSON output with the `-j` flag

```
# jailer list -j | jq
[
  {
    "name": "www0",
    "state": "Active",
    "jid": "1",
    "hostname": "www0.dev.mydomain.com",
    "ipv4": "10.0.0.10/24"
  },
  {
    "name": "www_prod",
    "state": "Active",
    "jid": "2",
    "hostname": "www_prod.srv.illuriasecurity.com",
    "ipv4": "10.0.0.80/24"
  }
]
```

### Advanced Networking
First, please enable routing.

```
echo 'net.inet.ip.forwarding=1' >> /etc/sysctl.conf
service sysctl restart
```

#### NAT with PF

Jailer has `nat` subcommand that automates adding NAT rules into your PF configuration.

First add the following at the top of your `pf.conf` configuration's `nat` section

```
include "/etc/jail.conf.d/.pf.nat.jailer.conf"
```
And then execute

```
touch /etc/jail.conf.d/.pf.nat.jailer.conf
```

To add a NAT rule use the `nat add` subcommand. Here's how to NAT the traffic of jail `www0` on `vtnet0` interface

```
jailer nat add -i vtnet0 www0
```

To use a specific outbound IP address use the `-a` flag

```
jailer nat add -i vtnet0 -a my.second.ip.addr www0
```

To list all NAT rules use the `nat list` subcommand

```
# jailer nat list
nat on vtnet0 inet from 10.0.0.10 to any -> my.second.ip.addr #www0
nat on vtnet0 inet from 10.0.0.80 to any -> (vtnet0:0) #www_prod
```

To delete a NAT rule use the `nat del` subcommand

```
jailer nat del www0
```

#### Port Redirection with PF

Jailer has `rdr` subcommand that automates port and address redirection

First add the following at the top of your `pf.conf` configuration's `rdr` section

```
include "/etc/jail.conf.d/.pf.rdr.jailer.conf"
```
And then execute

```
touch /etc/jail.conf.d/.pf.rdr.jailer.conf
```

To add a port redirection use the `rdr` subcommand. Here's how to redirect the traffic coming to the `vtnet0` interface over TCP port 80 to the `www0` Jail

```
jailer rdr add -i vtnet0 -p tcp -r 80 www0
```

To understand the flags; `-i` is the external interface, `-p` is the protocol (TCP/UDP) and `-r` is the receiving port. If no destination port `-d` is defined then it will be set as the source port.

To redirect all the packets coming to an address (i.e. your secondary IP) you can use the `-a` address flag

```
jailer rdr add -i vtnet0 -a my.second.ip.addr www_prod
```

You can also mix these flags! To redirect all the traffic coming to `my.other.ip.addr` on the `vtnet0` interface over TCP port 8080 to TCP port 80 of the `www0` Jail

```
jailer rdr add -i vtnet0 -a my.other.ip.addr -p tcp -r 8080 -d 80 www0
```

> Be careful not to lock yourself out! For example, don't redirect the host's SSH port by accident unless you know what you're doing.

To list all the redirection created by Jailer, use the `rdr list` subcommand

```
# jailer rdr list
rdr pass on vtnet0 inet proto tcp from any to  port 80 -> 10.0.0.10 port 80 #1 www0
rdr pass on vtnet0 inet  from any to my.second.ip.addr  -> 10.0.0.80  #2 www_prod
rdr pass on vtnet0 inet proto tcp from any to my.other.ip.addr port 8080 -> 10.0.0.10 port 80 #3 www0
```

To delete a port redirection, we can use the index of the rule (next to `#`) or the jail name.

To delete rule `#2` for the `www_prod` Jail, use the `rdr del` subcommand

```
jailer rdr del -j www_prod -i 2
```

To delete all the rules for the `www0` Jail, we use the flush `-f` flag

```
jailer rdr del -j www0 -f
```

> After each deletion/flush, Jailer keeps the old config file in `/etc/jail.conf.d/` as `/etc/jail.conf.d/.pf.rdr.jailer.conf.TIMESTAMP` in case you flush by accident. This will become configurable in the future.

