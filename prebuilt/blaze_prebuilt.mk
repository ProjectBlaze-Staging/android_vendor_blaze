#
# Copyright (C) 2026 BlazeAOSP Project
# SPDX-License-Identifier: Apache-2.0
#
# blaze_prebuilt.mk
# Add this file to vendor/blaze/config/common.mk via:
#   $(call inherit-product-if-exists, vendor/blaze/prebuilt/blaze_prebuilt.mk)
#
# To add a new prebuilt APK:
#   1. Copy the APK to vendor/blaze/prebuilt/apk/<AppName>.apk
#   2. Add an android_app_import block in vendor/blaze/prebuilt/Android.bp
#   3. Add the app name to BLAZE_PREBUILT_PACKAGES below
#

BLAZE_PREBUILT_PACKAGES := \
    Firefox

PRODUCT_PACKAGES += \
    $(BLAZE_PREBUILT_PACKAGES)

PRODUCT_COPY_FILES += \
    vendor/blaze/prebuilt/etc/init/blaze-perf.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/blaze-perf.rc

