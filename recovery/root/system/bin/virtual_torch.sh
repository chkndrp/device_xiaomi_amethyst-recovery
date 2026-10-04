#!/system/bin/sh

# Copyright (C) 2026 chkndrp
# SPDX-License-Identifier: GPL-3.0-only

# OrangeFox has very basic flashlight support, and it does not work natively for this device.
#
# This workaround creates a virtual torch brightness control node that 
# handles this extra step for OrangeFox, and makes the flashlight feature work.

BRIGHTNESS_LEVEL=430
VIRTUAL_TORCH_DIR=/tmp/of_torch
CONTROL_NODE=$VIRTUAL_TORCH_DIR/brightness
PREVIOUS_VAL=-1

rm -rf $VIRTUAL_TORCH_DIR
mkdir -p $VIRTUAL_TORCH_DIR
echo 0 > $CONTROL_NODE

chmod 666 $CONTROL_NODE
echo $BRIGHTNESS_LEVEL > $VIRTUAL_TORCH_DIR/max_brightness

while sleep 0.1; 
    do
        CURRENT_VAL=$(cat $CONTROL_NODE)

        if [ -z "$CURRENT_VAL" ] || [ "$CURRENT_VAL" = "$PREVIOUS_VAL" ]; 
            then continue
        fi

        PREVIOUS_VAL=$CURRENT_VAL

        if [ "$CURRENT_VAL" -eq 0 ]; 
            then echo 0 > /sys/class/leds/led:switch_0/brightness
            else
                echo $BRIGHTNESS_LEVEL > /sys/class/leds/led:torch_0/brightness
                echo 1 > /sys/class/leds/led:switch_0/brightness
        fi
done
