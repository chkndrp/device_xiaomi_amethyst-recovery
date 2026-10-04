#!/system/bin/sh

# Copyright (C) 2026 chkndrp
# SPDX-License-Identifier: GPL-3.0-only

# rmt_storage is required for WLAN in recovery, however it somehow modifies 
# or allows for modifying the modem configuration - breaking the RIL forever 
# unless EFS backup is restored (SW_MBN_AP_BP_NUM_NOT_SAME) (Scary!).

# This script sets up read-only loop devices and tricks rmt_storage
# into using them instead of the real partitions.

set -eu

# Modemst[1,2], fsc, fsg
TARGET_DEVS="sdf3 sdf4 sdf5 sdf6"

BOOTDEVICE_DIR="/dev/block/bootdevice/by-name"
VIRTUAL_RO_DIR="/dev/block/bootdevice_ro"
RO_DIR="/dev/rmt_ro"

LOGMSG() {
    echo "E:[RMT] $1" >> /tmp/recovery.log;
}

trap 'LOGMSG "Fatal error during setup. Aborting."; exit 1' EXIT
mkdir -p "$RO_DIR" "$VIRTUAL_RO_DIR"

for dev in $TARGET_DEVS; 
    do
        SUCCESS=0
        for __attempt in 1 2 3; 
            do
                LOOP_DEV=$(losetup -j "/dev/block/$dev" 2>/dev/null | cut -d: -f1 || true)

                if [ -z "$LOOP_DEV" ]; 
                    then LOOP_DEV=$(losetup -frs "/dev/block/$dev" 2>/dev/null || true)
                fi
                if [ -n "$LOOP_DEV" ]; 
                    then
                        ln -sfn "$LOOP_DEV" "$RO_DIR/$dev"
                        SUCCESS=1
                        break
                fi

                sleep 1
        done

        if [ $SUCCESS -ne 1 ]; 
            then
                LOGMSG "Failed to attach read-only loop device for $dev after 3 attempts. Aborting."
                exit 1
        fi
done

for entry in "$BOOTDEVICE_DIR"/*; 
    do
        if [ -e "$entry" ] || [ -L "$entry" ]; 
            then
                name=$(basename "$entry")
                ln -sfn "$entry" "$VIRTUAL_RO_DIR/$name"
        fi
done

ln -sfn "$RO_DIR/sdf3" "$VIRTUAL_RO_DIR/modemst1"
ln -sfn "$RO_DIR/sdf4" "$VIRTUAL_RO_DIR/modemst2"
ln -sfn "$RO_DIR/sdf5" "$VIRTUAL_RO_DIR/fsg"
ln -sfn "$RO_DIR/sdf6" "$VIRTUAL_RO_DIR/fsc"

if ! mount --bind "$VIRTUAL_RO_DIR" "$BOOTDEVICE_DIR"; 
    then
        LOGMSG "Failed to bind mount virtual directory. Aborting."
        exit 1
fi

# Redundant check, but it's good for safety
for part in modemst1 modemst2 fsg fsc; 
    do
        REAL_DEV=$(realpath "$BOOTDEVICE_DIR/$part" 2>/dev/null || true)
        LOOP_NAME=$(basename "$REAL_DEV" 2>/dev/null || true)

        if [ "$(cat "/sys/class/block/$LOOP_NAME/ro" 2>/dev/null)" != "1" ]; 
            then
                LOGMSG "$part is not bound to a read-only loop device! Aborting."
                exit 1
        fi
done

trap - EXIT
exec /vendor/bin/rmt_storage "$@"
