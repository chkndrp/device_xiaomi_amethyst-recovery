#!/system/bin/sh

# Copyright (C) 2026 chkndrp
# SPDX-License-Identifier: GPL-3.0-only

LOGMSG() {
	echo "I:$1" >> /tmp/recovery.log;
}

do_prop_cleanup() {
    LOGMSG "Resetting SPL date back to original value..."

    resetprop ro.build.version.security_patch "$(resetprop twrp.temp.security_patch)"
    resetprop ro.vendor.build.security_patch "$(resetprop twrp.temp.security_patch)"

    resetprop --delete twrp.temp.security_patch 
}

undo_sysctl_tune() {
    LOGMSG "Reverting sysctl tune..."
    
    gov=$(resetprop twrp.temp.cpu_governor);
    if [ -n "$gov" ]; 
        then
            for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; 
                do echo "$gov" > "$g" 2>/dev/null;
            done

            resetprop --delete twrp.temp.cpu_governor;
    fi

	echo 10000 > /sys/bus/platform/devices/1d84000.ufshc/auto_hibern8 2>/dev/null
    echo 1 > /sys/bus/platform/devices/1d84000.ufshc/clkgate_enable 2>/dev/null
    echo 1 > /sys/bus/platform/devices/1d84000.ufshc/enable_wb_buf_flush 2>/dev/null
	echo 0 > /sys/devices/system/cpu/qcom_lpm/parameters/sleep_disabled 2>/dev/null
}

do_prop_cleanup;
undo_sysctl_tune;
sync;
exit 0;
