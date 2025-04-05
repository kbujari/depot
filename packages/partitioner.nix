# Apply standard partition layout to a disk device.
{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "partitioner";

  runtimeInputs = with pkgs; [
    gptfdisk
    dosfstools
    zfs
    coreutils
    util-linux
  ];

  text = ''
    set -euo pipefail

    if [ $# -ne 1 ]; then
      echo "Usage: $0 <device>"
      echo "Example: $0 /dev/sda or /dev/nvme0n1"
      exit 1
    fi

    DISK="$1"

    if [ ! -b "$DISK" ]; then
      echo "Error: $DISK is not a valid block device"
      exit 1
    fi

    echo "creating partition table on $DISK"
    # create gpt partition table
    sgdisk --zap-all "$DISK"

    echo "creating efi partition"
    sgdisk --new=1:0:+1G --typecode=1:EF00 --change-name=1:ESP "$DISK"

    echo "creating zfs partition with remaining space"
    sgdisk --new=2:0:0 --typecode=2:BF00 --change-name=2:ZROOT "$DISK"

    if [[ "$DISK" == *"nvme"* ]]; then
      EFI_PART="''${DISK}p1"
      ZFS_PART="''${DISK}p2"
    else
      EFI_PART="''${DISK}1"
      ZFS_PART="''${DISK}2"
    fi

    sleep 1

    echo "formatting rfi partition ($EFI_PART)"
    mkfs.fat -F32 -n ESP "$EFI_PART"

    echo "creating pool on $ZFS_PART"
    zpool create -f \
      -o ashift=12 \
      -o autotrim=on \
      -O acltype=posixacl \
      -O canmount=off \
      -O compression=on \
      -O mountpoint=none \
      -O normalization=formD \
      -O relatime=off \
      -O xattr=sa \
      zroot "$ZFS_PART"

    # create ZFS datasets
    echo "Creating datasets"

    zfs create \
      -o refreservation=10G \
      -o mountpoint=none \
      zroot/reserved

    zfs create -o mountpoint=legacy zroot/nix
    zfs create -o mountpoint=legacy zroot/home
    zfs create -o mountpoint=legacy zroot/persist

    echo "---"
    echo "done"
  '';
}
