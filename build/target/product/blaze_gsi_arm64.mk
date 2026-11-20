#
# Copyright (C) 2026 The BlazeAOSP Project
#
# SPDX-License-Identifier: Apache-2.0
#

$(call inherit-product, device/generic/common/gsi_arm64.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
include vendor/lineage/build/target/product/lineage_generic_target.mk
$(call inherit-product, vendor/blaze/config/blaze_base.mk)

PRODUCT_USE_DYNAMIC_PARTITION_SIZE := true
TARGET_NO_KERNEL_OVERRIDE := true

PRODUCT_NAME := blaze_gsi_arm64
PRODUCT_DEVICE := generic_arm64
PRODUCT_BRAND := BlazeAOSP
PRODUCT_MODEL := BlazeAOSP GSI (arm64)

# Identify GSI builds explicitly so GSI-only settings (e.g. TrebleSettings) remain hidden on devices
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.blaze.is_gsi=true

PRODUCT_PACKAGES += \
    SettingsIntelligence \
    update_engine_client

PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS :=
