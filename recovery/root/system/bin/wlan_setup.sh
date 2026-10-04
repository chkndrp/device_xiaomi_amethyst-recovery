#!/system/bin/sh

# Copyright (C) 2026 chkndrp
# SPDX-License-Identifier: GPL-3.0-only

# Standard TW_POST_DECRYPT_MODULES does not work well for this device.
# Somewhy, it struggles with loading the system_dlkm modules. 
# So this script is the solution

SYSTEM_DLKM_MNT="/system_dlkm"
VENDOR_DLKM_MNT="/vendor_dlkm"

# Based on modules.dep from vendor dump
MODULES="
qcom_glink.ko
qcom_glink_smem.ko
qcom_smd.ko
rproc_qcom_common.ko
qmi_helpers.ko
pdr_interface.ko
pmic_glink.ko
ucsi_glink.ko
wcd_usbss_i2c.ko
redriver.ko
repeater.ko
dwc3-msm.ko
gsim.ko
rmnet_mem.ko
usb_f_gsi.ko
ipam.ko
rmnet_ctl.ko
rmnet_core.ko
rfkill.ko
libarc4.ko
cfg80211.ko
mac80211.ko
rmnet_wlan.ko
rmnet_offload.ko
rmnet_perf.ko
rmnet_perf_tether.ko
rmnet_sch.ko
rmnet_shs.ko
rmnet_aps.ko
qcom_ramdump.ko
wlan_firmware_service.ko
cnss_prealloc.ko
cnss_utils.ko
cnss_nl.ko
icnss2.ko
xiaomi_wifi_gpio.ko
qca_cld3_qca6750.ko
"

LOGMSG() {
    level="$1"
    shift
    echo "${level}:[WLAN] $*" >> /tmp/recovery.log
}

# shellcheck disable=SC2329
cleanup() {
    LOGMSG I "Unmounting $SYSTEM_DLKM_MNT and $VENDOR_DLKM_MNT..."
    umount "$SYSTEM_DLKM_MNT" 2>/dev/null
    umount "$VENDOR_DLKM_MNT" 2>/dev/null
}
trap cleanup EXIT INT TERM

mount_dlkm() {
    part="$1"
    mnt="$2"

    slot=$(resetprop ro.boot.slot_suffix)
    dev="/dev/block/mapper/${part}${slot}"

    if mountpoint -q "$mnt"; 
        then return 0
    fi

    # Kinda redundant
    mkdir -p "$mnt"

    mount -t erofs -o ro "$dev" "$mnt" 2>> /tmp/recovery.log || \
    mount -t ext4 -o ro,barrier=1,discard "$dev" "$mnt" 2>> /tmp/recovery.log || return 1

    return 0
}

LOGMSG I "Mounting partitions..."
if ! mount_dlkm "system_dlkm" "$SYSTEM_DLKM_MNT";
    then LOGMSG E "Failed to mount $SYSTEM_DLKM_MNT"
fi
if ! mount_dlkm "vendor_dlkm" "$VENDOR_DLKM_MNT"; 
    then LOGMSG E "Failed to mount $VENDOR_DLKM_MNT"
fi

LOGMSG I "Loading DLKM modules for WLAN..."
for mod in $MODULES; do
    mod_name=$(echo "${mod%.ko}" | tr '-' '_')

    if grep -q "^${mod_name} " /proc/modules 2>/dev/null; 
        then continue
    fi

    ko=$(find "$SYSTEM_DLKM_MNT" "$VENDOR_DLKM_MNT" -name "$mod" -type f 2>/dev/null | head -n 1)

    if [ -n "$ko" ]; 
        then
            if ! insmod "$ko" 2>> /tmp/recovery.log; 
                then LOGMSG E "Failed to load module: $ko"
            fi
        else LOGMSG E "Module not found: $mod"
    fi
done

resetprop twrp.wlan.drivers.loaded true
exit 0
