# Apply standard partition layout to a disk device.
{ pkgs, ... }:

pkgs.writeShellScriptBin "partitioner" ''
  set -e

  if [ $# -ne 1 ]; then
    echo "Usage: $0 <disk-device>"
    exit 1
  fi

  DISK=$1

  # Clear existing partitions
  sgdisk -Z "$DISK"

  # 1GB EFI partition (FAT32)
  sgdisk -n 1:0:+1G -t 1:EF00 -c 1:EFI "$DISK"

  # Rest for ZFS
  sgdisk -n 2:0:0 -t 2:BF01 -c 2:ZFS "$DISK"

  mkfs.fat -F32 -nEFI ""

  zpool create \
    -o ashift=12 \
    -O compression=on \
    -O acltype=posixacl \
    -O xattr=sa \
    -O relatime=off
    -O normalization=formD \
    zroot "$DISK"
''
