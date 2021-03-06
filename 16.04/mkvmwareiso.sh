#!/usr/bin/env bash

set -uex

DIR=$(dirname ${0})
cd $DIR

# Get ISO Image
mkdir -p ISOTMP
cd ISOTMP
wget -c http://releases.ubuntu.com/16.04.4/ubuntu-16.04.4-server-amd64.iso
sudo mkdir -p /mnt/cdrom
sudo mount -o loop ubuntu-16.04.4-server-amd64.iso /mnt/cdrom
rm -rf image
mkdir -p image
rsync -av /mnt/cdrom/ image/
sudo umount /mnt/cdrom

chmod 755 image/preseed
cp ../vmware.seed image/preseed

cd image/isolinux
chmod 755 .
chmod 644 txt.cfg
sudo sed -i 's/file=\/cdrom\/preseed\/ubuntu-server.seed vga=788 initrd=\/install\/initrd.gz/auto=true priority=critical file=\/cdrom\/preseed\/vmware.seed vga=788 initrd=\/install\/initrd.gz/' txt.cfg
sudo sed -i 's/timeout 0/timeout 1/' isolinux.cfg
cd ../../
sudo find image -type d -exec chmod 755 {} \;
sudo find image -type f -exec chmod 644 {} \;

NOW=$(date '+%Y%m%d-%H%M%S')
ISO="truemark-vmware-ubuntu-16.04.4-server-amd64-${NOW}.iso"

mkisofs -r -V "TrueMark Ubuntu Install CD" \
  -cache-inodes \
  -J -l -b isolinux/isolinux.bin \
  -c isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -o ${ISO} image/

sudo rm -rf image
sha1sum ${ISO} > ${ISO}.sha1
scp ${ISO} ${ISO}.sha1 download@172.16.224.50:iso/
