#!/bin/bash

# Copyright (C) 2025-2026 OrangeFox Recovery Project
# Copyright (C) 2026 chkndrp
# SPDX-License-Identifier: GPL-3.0-only

# The build vars for OrangeFox can be found here:
# https://gitlab.com/OrangeFox/infrastructure/doc/-/blob/main/dev/build_vars.md

FDEVICE="amethyst"

fox_get_target_device() {
    local src=""

    if [ -n "$ZSH_VERSION" ]; 
      then src="${(%):-%x}"
    elif [ -n "$BASH_VERSION" ];
      then src="${BASH_SOURCE[0]}"
    else src="$0"
    fi

    if echo "$src" | grep -q "$FDEVICE"; 
      then FOX_BUILD_DEVICE="$FDEVICE"
    elif [ -n "$BASH_VERSION" ] && set | grep BASH_ARGV | grep -q -w "$FDEVICE";
      then FOX_BUILD_DEVICE="$FDEVICE"
    elif echo "$* $0" | grep -q -w "$FDEVICE"; 
      then FOX_BUILD_DEVICE="$FDEVICE"
    fi
}

fetch_latest_magisk() {
    local magisk_dir magisk_tag magisk_file local_zip

    _find_zip() { 
      find "$magisk_dir" \
        -maxdepth 1 -type f -name "*.zip" \
        -size +0 "$@" -print -quit
    }

    magisk_dir="${XDG_CACHE_HOME:-$HOME/.cache}/ofrp_magisk"
    mkdir -p "$magisk_dir"

    if [ -z "$FOX_BUILD_TYPE" ]; 
      then local_zip=$(_find_zip -mtime -14)
    fi
    if [ -z "$local_zip" ];
      then magisk_tag=$(gh release view --repo topjohnwu/Magisk --json tagName -q .tagName 2>/dev/null)
    fi

    if [ -n "$magisk_tag" ];
      then
        magisk_file="${magisk_dir}/Magisk-${magisk_tag}.zip"

        if [ ! -s "$magisk_file" ];
          then
            echo "I: Downloading new Magisk release (${magisk_tag})..."
            curl -sL \
              "https://github.com/topjohnwu/Magisk/releases/download/${magisk_tag}/Magisk-${magisk_tag}.apk" \
              -o "$magisk_file"
        fi
        if [ -s "$magisk_file" ];
          then
            _find_zip ! -name "$(basename "$magisk_file")" -delete >/dev/null 2>&1
            local_zip=$(_find_zip -name "$(basename "$magisk_file")")
        fi
    fi

    : "${local_zip:=$(_find_zip)}"
    if [ -n "$local_zip" ];
      then
        export FOX_USE_SPECIFIC_MAGISK_ZIP="$local_zip"
        echo "I: Using Magisk zip: $FOX_USE_SPECIFIC_MAGISK_ZIP"
      else
        unset FOX_USE_SPECIFIC_MAGISK_ZIP
    fi
}

if [ -z "$1" ] && [ -z "$FOX_BUILD_DEVICE" ]; 
  then fox_get_target_device "$@"
fi

if [ "$1" = "$FDEVICE" ] || [ "$FOX_BUILD_DEVICE" = "$FDEVICE" ];
  then
    export TARGET_DEVICE_ALT="amethyst"

    # Binaries & Tools
    export FOX_USE_BUSYBOX_BINARY=1
    export FOX_USE_BASH_SHELL=1
    export FOX_USE_TAR_BINARY=1
    export FOX_USE_SED_BINARY=1
    export FOX_USE_XZ_UTILS=1
    export FOX_USE_ZSTD_BINARY=1
    export FOX_USE_LZ4_BINARY=1
    export FOX_USE_DATE_BINARY=1
    export FOX_USE_FSCK_EROFS_BINARY=1
    export FOX_USE_PATCHELF_BINARY=1
    export FOX_USE_GREP_BINARY=1
    export FOX_ASH_IS_BASH=1
    export FOX_BASH_TO_SYSTEM_BIN=1
    export FOX_REPLACE_TOOLBOX_GETPROP=1

    # Settings/Data storage locations
    export FOX_SETTINGS_ROOT_DIRECTORY="/data/recovery"
    export FOX_MISCELLANEOUS_ROOT_DIRECTORY="/sdcard"

    # Addons
    export FOX_ENABLE_APP_MANAGER=1
    export FOX_DELETE_AROMAFM=1
    export FOX_DELETE_INITD_ADDON=1

    # Magisk / KernelSU(-Next) / SukiSU support
    export FOX_ENABLE_KERNELSU_SUPPORT=1
    export FOX_ENABLE_KERNELSU_NEXT_SUPPORT=1
    export FOX_ENABLE_SUKISU_SUPPORT=1
    export FOX_MOVE_MAGISK_INSTALLER_TO_RAMDISK=1

    # A/B partitioning
    export FOX_VIRTUAL_AB_DEVICE=1
    export FOX_RECOVERY_SYSTEM_PARTITION="/dev/block/mapper/system"
    export FOX_RECOVERY_VENDOR_PARTITION="/dev/block/mapper/vendor"

    # Use latest "magiskboot" binaries as this is a relatively new device
    export FOX_USE_UPDATED_MAGISKBOOT=1

    # CCACHE
    export USE_CCACHE=1
    export CCACHE_EXEC="/usr/bin/ccache"
    export CCACHE_MAXSIZE="50G"
    export CCACHE_DIR="/mnt/ccache"

    # Warn if CCACHE_DIR is an invalid directory
    if [ $USE_CCACHE = 1 ] && [ ! -d ${CCACHE_DIR} ];
     then
       echo "W: CCACHE Directory/Partition is not mounted at \"${CCACHE_DIR}\""
       echo "W: Please edit the CCACHE_DIR build variable or mount the directory."
    fi

    export LC_ALL="C"
    export BUILD_USERNAME=chkndrp
    export BUILD_HOSTNAME=github

    # Debugging
    ## export FOX_RESET_SETTINGS=0
    ## export FOX_INSTALLER_DEBUG_MODE=1

    if command -v gh > /dev/null 2>&1; 
      then fetch_latest_magisk
      else 
        echo "W: Fetching magisk skipped. Install GitHub CLI"
        unset FOX_USE_SPECIFIC_MAGISK_ZIP
    fi
  else
    if [ -z "$FOX_BUILD_DEVICE" ] && [ -z "$BASH_SOURCE" ] && [ -z "$ZSH_VERSION" ]; 
      then echo "W: This script requires bash or zsh. Not processing $FDEVICE"
    fi
fi
