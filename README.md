# Jailer

**NOTE**: This README is just a complete guide. We'd like your help to write manual pages :)

> Jailer is heavily under development and not yet ready for production use. The interface is subject to refinement and change, but you are more than welcome to use it and help us improve it with your invaluable feedback. It does not mean you cannot use it in production, though. Just beware that a lot might change in time.
>
> However, that being said, we **do** use it in our production to manage servers and in our products.

Jailer is a modern, minimal, flexible, and easy-to-expand FreeBSD Jail manager built with love by experienced users for both neophytes and experts.

## Installation

Jailer is not in FreeBSD ports *yet*, you need to install it manually

```console
git clone https://github.com/illuria/jailer
cd jailer
make install
```

## Prerequisites

- FreeBSD
- ZFS

Jailer is so much attached to ZFS and does not support UFS at this time (and most likely it will never do.) In case you are not using ZFS, you can create a ZFS pool by doing something like the following:

```console
truncate -s 20G /usr/local/disk0.img
zpool create zroot /usr/local/disk0.img
```

## Setup and Initialization

> ### Custom Jail Service file
>
> At the moment we use a custom `rc.d/jail` file, which is sent to FreeBSD as [**D38826: Fix multiple rc.d/jail and jail.conf.d issues**](https://reviews.freebsd.org/D38826). Once it's merged, we wont patch `rc.d/jail` anymore (unless we do more changes). `jailer init` will handle the patches.

Once the environment meets the basic requirements, Jailer initialization is required. all you need to do is the following:

```console
jailer init
```

Here's how it looks like →

```
root@armbsd13:~ # jailer init
Jailer will create
 dataset     : zroot/jails
 mount point : /usr/local/jails
OK? (y/N) y
Creating ZFS dataset zroot/jails with the mount point /usr/local/jails: Done!
Setting jailer_dir in rc.conf: Done!
Enabling the jail service: Done!
Patching jail service for jail.conf.d support: Done!

You may run `jailer init info` to check system status
You may run `jailer init bridge` to setup advanced networking

Please report any problems at https://github.com/illuria/jailer/issues
The latest information about Jailer is available at https://jailer.dev/
Consider joining Jailer's worldwide community:
 https://github.com/illuria/jailer

Thank you for choosing Jailer!
```

Or, if you like colors, here's a picture :)

![](https://notes.bsd.am/Jailer_images/i/Screenshot%202023-03-05%20at%209.46.12%20PM.png)

## Usage

### Basic Usage

At this point, you can create a Jail

```
jailer create
```

You should get the following →

```
root@armbsd13:~ # jailer create
Fetching 13.1-RELEASE: Done!
Creating 99d6c13c: Done!
```

By default, Jailer will fetch a base image if it's not available. You can list all images by doing

```
root@armbsd13:~ # jailer image list
  13.1-RELEASE
```

> Fetching might take a while, if you know a mirror that's closer to you, you can set the `FreeBSD_mirror` variable to that. e.g. `setenv FreeBSD_mirror "https://mirror.yandex.ru/freebsd/"` with `tcsh` or `export FreeBSD_mirror="https://mirror.yandex.ru/freebsd/"` with `/bin/sh`

You can list and download other images as well

```
root@armbsd13:~ # jailer image list remote
  12.3-RELEASE
  12.4-RELEASE
  13.0-RELEASE
  13.1-RELEASE
root@armbsd13:~ # jailer image fetch 13.0-RELEASE
Fetching 13.0-RELEASE: Done!
```

To list all the Jails, you can do `jailer list`. You should get the following →

```
root@armbsd13:~ # jailer list
NAME      STATE   JID  HOSTNAME           IPv4  GW
99d6c13c  Active  7    99d6c13c.armbsd13  -     -
```

This means that Jail `99d6c13c` is using an ***inherited*** network stack, which is **NOT SECURE** for production use. In the next part, we will configure jails with restricted and isolated network stacks.

### Restricted networking on an external interface

You can attach your Jail to an external interface as well. To attach a Jail to the interface `vtnet0` with the IP address `192.168.64.15` you can do the following →

```
root@armbsd13:~ # jailer create -t new -b vtnet0 -a 192.168.64.15 www0
Creating www0: Done!
root@armbsd13:~ # jailer list
NAME      STATE   JID  HOSTNAME           IPv4           GW
99d6c13c  Active  7    99d6c13c.armbsd13  -              -
www0      Active  9    www0.armbsd13      192.168.64.15  -
```

Unlike `99d6c13c`, which has an inherited network stack, the Jail `www0` has a restricted network stack, we can see that by logging into the Jail and running `ifconfig` →

```
root@armbsd13:~ # jailer console www0
root@www0:~ # ifconfig 
vtnet0: flags=8863<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	options=80028<VLAN_MTU,JUMBO_MTU,LINKSTATE>
	ether 52:88:80:9b:bb:00
	inet 192.168.64.15 netmask 0xffffffff broadcast 192.168.64.15
	media: Ethernet autoselect (10Gbase-T <full-duplex>)
	status: active
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> metric 0 mtu 16384
	options=680003<RXCSUM,TXCSUM,LINKSTATE,RXCSUM_IPV6,TXCSUM_IPV6>
	groups: lo
```

The Jail `www0` is not aware of any other IP addresses, but can see the network interfaces. It also has the same networking that's available on the host's `vtnet0` interface. If the host has internet access, so does `www0`

```
root@www0:~ # ping -c 1 bsd.am
PING bsd.am (37.252.73.34): 56 data bytes
64 bytes from 37.252.73.34: icmp_seq=0 ttl=57 time=44.368 ms
```

### Advanced Networking

Jailer can auto-configure the host to have advanced networking. We can check the status by running the following

```
root@armbsd13:~ # jailer init info
Checking system state...
 jail_enable in rc.conf  ==> YES!
 patched rc.d/jail file  ==> YES!
Checking jailer state...
 jailer_dir in rc.conf   ==> YES!
 jailer_dir is define to ==> zfs:zroot/jails
 Jailer ZFS dataset      ==> zroot/jails
 Jailer ZFS mountpoint   ==> /usr/local/jails
Checking network status...
 bridge0 in rc.conf      ==> NO :(
  If you want Jailer to auto-configure bridge interfaces, run `jailer init bridge`
```

![](https://notes.bsd.am/Jailer_images/i/Screenshot%202023-03-05%20at%2011.12.39%20PM.png)

We can run `jailer init bridge` to setup internal bridge networking between Jails and the host

```
Jailer will configure
 network interface : bridge0
 network address   : 10.0.0.1/24
OK? (y/N) y
Configuring interface bridge0 with IP address 10.0.0.1/24: Done!

You may run `jailer init dhcp` to setup DHCP server for bridge0
```

![](https://notes.bsd.am/Jailer_images/i/Screenshot%202023-03-05%20at%2011.12.52%20PM.png)

At this point, we can run a VNET (Virtualized Network) Jail that uses an `epair` to attach to `bridge0` (we call that an `eb` Jail for `epair/bridge`)

```
root@armbsd13:~ # jailer create -t eb -a 10.0.0.10
Creating fd1dafdc: Done!
root@armbsd13:~ # jailer list
NAME      STATE   JID  HOSTNAME           IPv4           GW
99d6c13c  Active  7    99d6c13c.armbsd13  -              -
fd1dafdc  Active  11   fd1dafdc.armbsd13  10.0.0.10/24   10.0.0.1
www0      Active  9    www0.armbsd13      192.168.64.15  -
```

To assign IPs automatically on VNET interfaces, you can setup a DHCP server. No worries! Jailer can handle that for you as well! It will install OpenBSD's `dhcpd`, setup `dhcpd.conf` and the needed `devfs.rules` for Jail.

```
root@armbsd13:~ # jailer init dhcp
Jailer will
 - Install OpenBSD's dhcpd from packages.
 - Setup dhcpd.conf.
 - Create /etc/devfs.rules for VNET Jails.
OK? (y/N) y
Setting up dhcpd, dhcpd.conf and devfs.rules: Done!
```

![](https://notes.bsd.am/Jailer_images/i/Screenshot%202023-03-06%20at%2012.30.24%20PM.png)

Now we can create a VNET Jail that uses DHCP.

```
root@armbsd13:~ # jailer create -t eb app0
Creating app0: Done!
root@armbsd13:~ # jailer list
NAME      STATE   JID  HOSTNAME           IPv4           GW
99d6c13c  Active  7    99d6c13c.armbsd13  -              -
app0      Active  12   app0.armbsd13      10.0.0.2/24    10.0.0.1
fd1dafdc  Active  11   fd1dafdc.armbsd13  10.0.0.10/24   10.0.0.1
www0      Active  9    www0.armbsd13      192.168.64.15  -
```

As you have guessed, if `-a address` is not assigned, then Jailer defaults to `-a dhcp` :)

If your VNET Jails need internet access, you probably need to setup NAT. Here's the easiest way to do that

```
# Enable routing
echo 'net.inet.ip.forwarding=1' >> /etc/sysctl.conf
service sysctl restart
# Enable pf
sysrc pf_enable="YES"
# Get default interface
default_interface=$(route get default | grep interface | cut -w -f 3)
# Generate the configuration and start pf
echo "nat on $default_interface from 10.0.0.0/24 to any -> ($default_interface)" >> /etc/pf.conf
service pf start
```

> If you get a message that says `Illegal variable name` then you're probably using `tcsh`. You can jump into `/bin/sh` by running `sh` :)

> Jailer has the `nat` and `rdr` subcommands to manage NAT and Redirection, but it will be integrate in the next release.

Now, you can login into your VNET Jail and access the internet.

```
root@armbsd13:~ # jailer console app0
root@app0:~ # host -t A bsd.am
bsd.am has address 37.252.73.34
```

### Stopping and Destroying Jails

To stop a Jail

```
root@armbsd13:~ # jailer stop www0
Stopping www0: Done!
```

To stop all Jails

```
root@armbsd13:~ # jailer stopall
Stopping jails: 99d6c13c fd1dafdc app0.
```

And to start all

```
root@armbsd13:~ # jailer startall
Starting jails: 99d6c13c app0 fd1dafdc www0.
```

### Snapshots and Clones

ZFS Snapshots are some of its best features. You can snap a Jail to 1) rollback in case something fails 2) create a new Jail base on it.

```
# Create a snapshot of `app0` named `prod`
root@armbsd13:~ # jailer snap app0@prod
Taking the snapshot app0@prod: Done!
# Create Jail named `app01` from `app0@prod`
root@armbsd13:~ # jailer create -t eb -s app0@prod app01
Creating app01: Done!
```

> In the coming releases, Jailer will have the ability to deploy ZFS Clones as well, which would allow you to save storage space.

### Default Values

#### Default Image/Relase

To specify an `image` as default, you can use the `image use` subcommand →

```
root@armbsd13:~ # jailer image list
  13.0-RELEASE
  13.1-RELEASE
root@armbsd13:~ # jailer image use 13.1-RELEASE
root@armbsd13:~ # jailer image list
  13.0-RELEASE
* 13.1-RELEASE
```

Otherwise, you can use the `-r imagename` flag to create a Jail based on `imagename` on the fly.

#### Default Network Type

As mentioned above, it's not a good idea to use inherited network stack on production. You can specify the default network type with the `network use` subcommand

```
root@armbsd13:~ # jailer network use eb
root@armbsd13:~ # jailer network use
eb
```

### Dry run

Jailer can display all the commands it would run during creation by using the `-D` flag.

```
root@armbsd13:~ # jailer create -D db0
jail.conf file =>
# vim: set syntax=sh:
exec.clean;
allow.raw_sockets;
mount.devfs;

db0 {
  $id             = "6";
  devfs_ruleset   = 10;
  $bridge         = "bridge0";
  $domain         = "armbsd13";
  vnet;
  vnet.interface = "epair${id}b";

  exec.prestart   = "ifconfig epair${id} create up";
  exec.prestart  += "ifconfig epair${id}a up descr vnet-${name}";
  exec.prestart  += "ifconfig ${bridge} addm epair${id}a up";

  exec.start      = "/sbin/ifconfig lo0 127.0.0.1 up";
  exec.start     += "/bin/sh /etc/rc";

  exec.stop       = "/bin/sh /etc/rc.shutdown jail";
  exec.poststop   = "ifconfig ${bridge} deletem epair${id}a";
  exec.poststop  += "ifconfig epair${id}a destroy";

  host.hostname   = "${name}.${domain}";
  path            = "/usr/local/jails/db0";
  exec.consolelog = "/var/log/jail/${name}.log";
  persist;
}
ZFS commands =>

  (zfs send zroot/jails/image/13.1-RELEASE@base |
   zfs recv zroot/jails/db0)
    
Resolver commands =>
  cp /etc/resolv.conf /usr/local/jails/db0/etc/resolv.conf
Network setup commands =>
  echo "ifconfig epair6b ether 58:9c:fc:a1:8a:3a" > /usr/local/jails/db0/etc/start_if.epair6b
  sysrc -q -f /usr/local/jails/db0/etc/rc.conf ifconfig_epair6b="SYNCDHCP"
Post-Installation =>
  sysrc -q -f /usr/local/jails/db0/etc/rc.conf sendmail_enable="NONE" syslogd_flags="-ss"
```

![](https://notes.bsd.am/Jailer_images/i/Screenshot%202023-03-06%20at%201.08.26%20PM.png)

### JSON Output

Some subcommands support JSON output.

```json
root@armbsd13:~ # jailer list -j | jq
[
  {
    "name": "99d6c13c",
    "state": "Active",
    "jid": "21",
    "hostname": "99d6c13c.armbsd13",
    "ipv4": "-",
    "gateway": "-"
  },
  {
    "name": "app0",
    "state": "Active",
    "jid": "22",
    "hostname": "app0.armbsd13",
    "ipv4": "10.0.0.2/24",
    "gateway": "10.0.0.1"
  },
  {
    "name": "app01",
    "state": "Active",
    "jid": "25",
    "hostname": "app01.armbsd13",
    "ipv4": "10.0.0.3/24",
    "gateway": "10.0.0.1"
  },
  {
    "name": "fd1dafdc",
    "state": "Active",
    "jid": "23",
    "hostname": "fd1dafdc.armbsd13",
    "ipv4": "10.0.0.10/24",
    "gateway": "10.0.0.1"
  },
  {
    "name": "www0",
    "state": "Active",
    "jid": "24",
    "hostname": "www0.armbsd13",
    "ipv4": "192.168.64.15",
    "gateway": "-"
  }
]
```

![](https://notes.bsd.am/Jailer_images/i/Screenshot%202023-03-06%20at%201.09.31%20PM.png)

## Contributing

You are more than welcome to contribute to Jailer, whether it is on code, doc, or just to fix a typo. Please open an issue if you find a bug, or a PR if you have fixed one. All code changes must be reviewed and tested.

## History

In January of 2021, @antranigv and @riks-ar had a bet If Antranig was able to rewrite @illuria's ZFS, Jail and `ifconfig(8)` wrappers from Elixir to Shell. The deal was if @antranigv failed to do that in 2 weeks, then @riks-ar gets @antranigv's desk and chair (which was the best one in the office at the time). If @antranigv succeeded, then he had the right to open-source the Shell program at any time in the future.

On October 20th 2022, @illuria open-sourced Jailer by pushing the code to this repository :)



































---

### Basic Networking

It's a very multidisciplinary field and we do not set out
any specific approach here. But to create a simple switch,
the following could be useful (or maybe enough?)

```console
sysrc cloned_interfaces="bridge0"
sysrc ifconfig_bridge0="inet 10.0.0.1 netmask 0xffffff00 descr jailer-bridge"
service netif start bridge0
```

### Fetching a Base Image

To fetch a base system, <ins>jailer-image(8)</ins> with
`fetch` subcommand could be used. For instance, the
following would download and extract `base.txz`
of the 13.1-RELEASE from `https://download.FreeBSD.org/ftp`:

```console
> jailer image fetch 13.1-RELEASE
```

> If you want to use a mirror closer to you, you can change the `FreeBSD_mirror` environment variable, e.g. `setenv FreeBSD_mirror https://mirror.yandex.ru/freebsd`

To list all fetched base images, run `jailer image list`,
and to list possible images to fetch, `image list remote`
(this has to be improved, though, as it currently means
no jail named "remote" could be used.)

### Creating Jails

To create a new jail, use the
<ins>jailer-create(8)</ins> command:

```console
jailer create -r 13.1-RELEASE -b bridge0 -d example.com -a 10.0.0.10 dev
```

Once created, it automatically starts the jail, and you
can enter it with the `console` command:

```console
jailer console dev
```

You can make snapshots from your jails, and later use
them to create another jail or roll back or whatever.
If you do not provide a name for your snapshot, the
current date and time is used; for example, on Oct 19,
20:05:10, the following will create a snapshot named
<ins>2022-10-19-20:05:10</ins>:

```console
jailer snap dev
```

Otherwise, you can do something like the following:

```console
jailer snap dev@prod
```

And later create a jail from the the snapshot:

```console
jailer create -s dev@prod -b bridge0 -d example.com -a 10.0.0.100 www
```

### Listing Jails

To list all the jails:

```console
# jailer list
NAME  STATE   JID  HOSTNAME         IPv4          GW
dev   Active  1    dev.example.com  10.0.0.10/24  -
www   Active  2    www.example.com  10.0.0.80/24  -
```

It can also provide a JSON output with the `-j` flag:

```console
# jailer list -j | jq
[
  {
    "name": "dev",
    "state": "Active",
    "jid": "1",
    "hostname": "dev.example.com",
    "ipv4": "10.0.0.10/24",
    "gateway": "-"
  },
  {
    "name": "www",
    "state": "Active",
    "jid": "2",
    "hostname": "www.example.com",
    "ipv4": "10.0.0.100/24",
    "gateway": "-"
  }
]
```

## Contributing

You are more than welcome to contribute to jailer,
whether it is on code, doc, or just to fix a typo.
Please open an issue if you find a bug, or a PR if
you have fixed one. All code changes must be
reviewed and tested.

