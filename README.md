# Jailer

**NOTE**: This README is just a kick-start. For a deeper
understanding, reading manual pages is required and ever
so recommended.

> Jailer is heavily under development and not yet ready for production use. The interface is subject to refinement and change, but you are more than welcome to use it and help us improve it with your invaluable feedbacks. It does not mean you cannot use it in production, though. Just beware that a lot might change in time.

Jailer is a modern, minimal, flexible, and easy-to-expand FreeBSD jail manager built with love by experienced users for both neophytes and experts.

## Installation

As jailer is not ported yet, you need to clone this repo and
run `make install` to install the software. We will port the
software in upcoming days.

## Prerequisites

Jailer is so much attached to ZFS and does not support UFS at
this time (and most likely it will never do.) In case you are
not using ZFS, you can create a ZFS pool by doing something
like the following:

```console
> truncate -s 20G /usr/local/disk0.img
> zpool create zroot /usr/local/disk0.img
```

## Setup and Initialisation

Once the environment meets the basic requirements, to start
using jailer, initialisation is required, and the simplest
you can do is the following:

```console
> jailer init
```

If for any reasons it fails, consult <ins>jailer(8)</ins>
and <ins>jailer-init(8)</ins> manual pages, in order.

## Usage and Basic Applications

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

