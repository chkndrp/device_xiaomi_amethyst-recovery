#!/system/bin/sh

# Copyright (C) 2026 chkndrp
# SPDX-License-Identifier: GPL-3.0-only

# Load batterysecret and kickstart touchfeature if not running
QCOM_BATTERY_DIR="/sys/class/qcom-battery"
TOUCH_SVC_STATUS=$(resetprop init.svc.touchfeature-service)

LOGMSG() {
	echo "I:$1" >> /tmp/recovery.log;
}

( # For batterysecret (async)
    while [ ! -d "$QCOM_BATTERY_DIR" ]; 
        do sleep 1
    done
    resetprop vendor.qcom_battery.initialized true
) &

if [ "$TOUCH_SVC_STATUS" != "running" ]; 
    then 
        resetprop ctl.start touchfeature-service
        LOGMSG "Forced touchfeature service start"
fi

exit 0
