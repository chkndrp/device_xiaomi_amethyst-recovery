#!/system/bin/sh

# Copyright (C) 2024 The OrangeFox Recovery Project
# Copyright (C) 2026 chkndrp
# SPDX-License-Identifier: GPL-3.0-only

LOGMSG() {
	echo "I:$1" >> /tmp/recovery.log;
}

do_prop_prep() {
    LOGMSG "Resetting SPL date to prevent data wipe..."
    resetprop twrp.temp.security_patch "$(resetprop ro.build.version.security_patch)"

    resetprop ro.build.version.security_patch 2024-09-23
    resetprop ro.vendor.build.security_patch 2024-09-23

    LOGMSG "Setting verified boot state to orange to prevent OTA rejection..."
    resetprop ro.boot.verifiedbootstate orange
}

do_sysfs_tune() {
	LOGMSG "Tuning sysfs parameters..."

    resetprop twrp.temp.cpu_governor "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)";
    for governor in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; 
		do echo performance > "$governor" 2>/dev/null;
    done

	echo 0 > /sys/bus/platform/devices/1d84000.ufshc/auto_hibern8 2>/dev/null
    echo 0 > /sys/bus/platform/devices/1d84000.ufshc/clkgate_enable 2>/dev/null
    echo 0 > /sys/bus/platform/devices/1d84000.ufshc/enable_wb_buf_flush 2>/dev/null
	echo 1 > /sys/devices/system/cpu/qcom_lpm/parameters/sleep_disabled 2>/dev/null
}

backup_fox() {
	file=$1;

	if [ -f "$file" ]; then
		x=$(unzip -lq "$file" | grep "payload.bin");
		[ -n "$x" ] && return; # standard payload.bin - no need for a backup
	fi

	source="/dev/block/bootdevice/by-name/recovery";
	destination="/tmp/fox_backup.img";

	if [ ! -f $destination ]; then
		LOGMSG "Backing up OrangeFox to \"$destination\"...";
		dd bs=1048576 if=$source of=$destination >/dev/null 2>&1;
	fi
}

LOGMSG "Running pre-ROM-flash script...";
do_prop_prep;
do_sysfs_tune;
backup_fox "$@";
sync;
exit 0;
