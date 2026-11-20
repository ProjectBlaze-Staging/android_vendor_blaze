#
# Copyright (C) 2026 The BlazeAOSP Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Include Blaze Updater for OFFICIAL builds (or when WITH_BLAZE_UPDATER=true)
ifeq ($(filter OFFICIAL,$(BLAZE_BUILD_TYPE)),OFFICIAL)
    WITH_BLAZE_UPDATER := true
endif

ifeq ($(WITH_BLAZE_UPDATER),true)
PRODUCT_PACKAGES += \
    Updater

PRODUCT_COPY_FILES += \
    vendor/blaze/prebuilt/common/etc/init/init.blaze-updater.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.blaze-updater.rc
endif
