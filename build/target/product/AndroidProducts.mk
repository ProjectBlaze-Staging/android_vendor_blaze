#
# Copyright (C) 2026 The BlazeAOSP Project
#
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/blaze_gsi_arm64.mk \
    $(LOCAL_DIR)/blaze_sdk_phone_x86_64.mk

COMMON_LUNCH_CHOICES := \
    blaze_gsi_arm64-cp2a-userdebug \
    blaze_sdk_phone_x86_64-cp2a-userdebug
