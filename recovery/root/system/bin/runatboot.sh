#!/system/bin/sh

# Copyright (C) 2026 chkndrp
# SPDX-License-Identifier: GPL-3.0-only

# Load batterysecret and kickstart touchfeature if not running
QCOM_BATTERY_DIR="/sys/class/qcom-battery"
TOUCH_SVC_STATUS=$(getprop init.svc.touchfeature-service)

( # For batterysecret (async)
    while [ ! -d "$QCOM_BATTERY_DIR" ]; 
        do sleep 1
    done
    setprop vendor.qcom_battery.initialized true
) &

if [ "$TOUCH_SVC_STATUS" != "running" ]; 
    then 
        setprop ctl.start touchfeature-service
        echo "Forced touchscreen service start" >> /tmp/recovery.log
fi

exit 0
