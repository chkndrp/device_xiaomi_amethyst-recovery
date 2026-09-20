# Copyright (C) 2025-2026 OrangeFox Recovery Project
# Copyright (C) 2026 chkndrp
# SPDX-License-Identifier: GPL-3.0-only

DEVICE_PATH := device/xiaomi/amethyst

# 64-bit-only architecture
TARGET_ARCH                := arm64
TARGET_ARCH_VARIANT        := armv8-2a-dotprod
TARGET_CPU_ABI             := arm64-v8a
TARGET_CPU_VARIANT         := generic
TARGET_CPU_VARIANT_RUNTIME := kryo300

# Platform
TARGET_BOOTLOADER_BOARD_NAME  := amethyst
TARGET_BOARD_PLATFORM         := volcano
TARGET_BOARD_PLATFORM_GPU     := qcom-adreno810
TARGET_USES_UEFI              := true
BOARD_USES_QCOM_HARDWARE      := true

# Kernel / Recovery image
TARGET_PREBUILT_KERNEL        := $(DEVICE_PATH)/prebuilt/kernel
TARGET_KERNEL_ARCH            := $(TARGET_ARCH)
TARGET_KERNEL_HEADER_ARCH     := $(TARGET_ARCH)

BOARD_KERNEL_PAGESIZE         := 4096
BOARD_KERNEL_IMAGE_NAME       := kernel
BOARD_BOOT_HEADER_VERSION     := 4
BOARD_MKBOOTIMG_ARGS          += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS          += --pagesize $(BOARD_KERNEL_PAGESIZE)

# Generic system/kernel image
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true

# VA/B with recovery partition. Leave this blank as Google recommends
BOARD_USES_RECOVERY_AS_BOOT :=
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT :=

# Use LZ4 Ramdisk compression instead of GZIP for faster boot
BOARD_RAMDISK_USE_LZ4 := true

# AVB, Disable hashtree + verification
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3

BOARD_AVB_VBMETA_SYSTEM := system
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 1

# Fix build errors with missing dependencies
ALLOW_MISSING_DEPENDENCIES := true
BUILD_BROKEN_USES_NETWORK := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_MISSING_REQUIRED_MODULES := true

# Partitions
BOARD_FLASH_BLOCK_SIZE                := 262144
BOARD_RECOVERYIMAGE_PARTITION_SIZE    := 104857600
BOARD_DTBOIMG_PARTITION_SIZE          := 20971520
BOARD_BOOTIMAGE_PARTITION_SIZE        := 100663296
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE  := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_CACHEIMAGE_PARTITION_SIZE       := 134217728

BOARD_USES_METADATA_PARTITION := true
BOARD_HAS_NO_REAL_SDCARD := true

# Dynamic Partitions
BOARD_SUPER_PARTITION_SIZE        := 9126805504
BOARD_SUPER_PARTITION_GROUPS      := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 9116319744
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST += \
    system \
    system_ext \
    product \
    vendor \
    vendor_dlkm \
    system_dlkm \
    odm

BOARD_PARTITION_LIST := $(call to-upper, $(BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST))
$(foreach p, $(BOARD_PARTITION_LIST), $(eval BOARD_$(p)IMAGE_FILE_SYSTEM_TYPE := erofs))
$(foreach p, $(BOARD_PARTITION_LIST), $(eval TARGET_COPY_OUT_$(p) := $(call to-lower, $(p))))
$(foreach p, $(filter-out SYSTEM, $(BOARD_PARTITION_LIST)), $(eval BOARD_USES_$(p)IMAGE := true))

# Display specifications
TARGET_SCREEN_HEIGHT  := 2712
TARGET_SCREEN_DENSITY := 480
TARGET_SCREEN_WIDTH   := 1220

# Filesystems
TARGET_USERIMAGES_USE_EXT4    := true
TARGET_USERIMAGES_USE_F2FS    := true
TARGET_USES_MKE2FS            := true

# Recovery
TARGET_SYSTEM_PROP := \
    $(DEVICE_PATH)/system.prop

TARGET_RECOVERY_FSTAB := \
    $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab

TARGET_BOARD_INFO_FILE := \
    $(DEVICE_PATH)/board-info.txt

TARGET_USE_CUSTOM_LUN_FILE_PATH := \
    /config/usb_gadget/g1/functions/mass_storage.0/lun.%d/file

TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_QCOM_RTC_FIX := true

# Debugging
TARGET_USES_LOGD               := true
# TARGET_RECOVERY_DEVICE_MODULES += strace
# RECOVERY_BINARY_SOURCE_FILES   += $(TARGET_OUT_EXECUTABLES)/strace
