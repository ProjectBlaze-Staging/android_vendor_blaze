#
# Copyright (C) 2026 BlazeAOSP Project
#

$(call inherit-product, device/generic/goldfish/64bitonly/product/sdk_phone64_x86_64.mk)
include vendor/lineage/build/target/product/lineage_generic_target.mk
include device/generic/goldfish/board/kernel/x86_64.mk

# Inherit Blaze configuration
$(call inherit-product, vendor/blaze/config/common.mk)

PRODUCT_MODULE_BUILD_FROM_SOURCE := true
PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := relaxed

# Overrides
PRODUCT_NAME := blaze_sdk_phone_x86_64
PRODUCT_DEVICE := emulator_x86_64
PRODUCT_BRAND := BlazeAOSP
PRODUCT_MODEL := BlazeAOSP Emulator x86_64

BOARD_SUPER_PARTITION_SIZE ?= 8598323200
BOARD_EMULATOR_DYNAMIC_PARTITIONS_SIZE ?= 8589934592
