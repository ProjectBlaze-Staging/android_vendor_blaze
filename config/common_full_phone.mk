#
# Copyright (C) 2026 The BlazeAOSP Project
#
# SPDX-License-Identifier: Apache-2.0
#

IS_BLAZE_BUILD := true

# Inherit LineageOS common full phone definitions
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit BlazeAOSP common definitions
$(call inherit-product, vendor/blaze/config/blaze_base.mk)
