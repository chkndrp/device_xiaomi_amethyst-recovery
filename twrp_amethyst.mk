# Copyright (C) 2025-2026 OrangeFox Recovery Project
# Copyright (C) 2026 chkndrp
# SPDX-License-Identifier: GPL-3.0-only

# Inherit from these configurations
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

# Inherit from device configuration
$(call inherit-product, device/xiaomi/amethyst/device.mk)

# Inherit from TWRP common configuration
$(call inherit-product, vendor/twrp/config/common.mk)

# Import OrangeFox specifics
$(call inherit-product, device/xiaomi/amethyst/fox_amethyst.mk)

PRODUCT_DEVICE := amethyst
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := Redmi Note 14 Pro+ 5G
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_NAME := twrp_$(PRODUCT_DEVICE)
