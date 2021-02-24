# WSC Kiosk Setup Script

The `setup-kiosk.sh` script is designed to be used with the SNF [`customize.sh`][customize] script,
to take a SolarNodeOS image and turn it into a kiosk image with the WSC energy profile kiosk shown
in a fullscreen browser window.

In the following example, a host Debian 11 system with `apt-cacher-ng` configured and available
at `http://172.16.159.141:3142`, a compressed `wsc-kiosk-deb11-pi-2GB-YYYYMMDD.img.xz` image will
be created from a source `solarnodeos-deb11-pi-2GB-20210225.img.xz` image:

```sh
sudo ~/solarnode-os-images/debian/bin/customize.sh -v -z \
        -N 1 -n 2 -M /boot/firmware \
        -a '-P -o 172.16.159.141:3142' \
        -o /var/tmp/wsc-kiosk-deb11-pi-2GB-$(date '+%Y%m%d').img \
        /var/tmp/solarnodeos-deb11-pi-2GB-20210225.img.xz \
        setup-kiosk.sh \
        $PWD:/tmp/overlay
```

# Requirements

The `customize.sh` script relies on a Debian based host system to run, with the following software
installed:

```sh
sudo apt install apt-cacher-ng bc binfmt-support btrfs-progs dosfstools e2fsprogs mtools \
	qemu qemu-user-static systemd-container util-linux xz-utils
```

[customize]: https://github.com/SolarNetwork/solarnode-os-images/blob/master/debian/bin/customize.sh
