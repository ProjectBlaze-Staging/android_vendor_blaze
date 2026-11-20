#
# Copyright (C) 2026 The BlazeAOSP Project
#
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_VERSION_MAJOR = 24
PRODUCT_VERSION_MINOR = 0
BLAZE_VERSION_CODE := 5.0

ifeq ($(BLAZE_VERSION_APPEND_TIME_OF_DAY),true)
    BLAZE_BUILD_DATE := $(shell date -u +%Y%m%d_%H%M%S)
else
    BLAZE_BUILD_DATE := $(shell date -u +%Y%m%d)
endif

BLAZE_DEVICE := $(or $(BLAZE_BUILD),$(LINEAGE_BUILD),$(TARGET_DEVICE))

# Resolve BLAZE_BUILD_TYPE (default: UNOFFICIAL; maintainers set RELEASE_TYPE=OFFICIAL or BLAZE_BUILD_TYPE=OFFICIAL)
ifndef BLAZE_BUILD_TYPE
    ifdef RELEASE_TYPE
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^BLAZE_||g' -e 's|^LINEAGE_||g')
        BLAZE_BUILD_TYPE := $(RELEASE_TYPE)
    else
        BLAZE_BUILD_TYPE := UNOFFICIAL
    endif
endif

ifeq ($(filter OFFICIAL RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL UNOFFICIAL,$(BLAZE_BUILD_TYPE)),)
    BLAZE_BUILD_TYPE := UNOFFICIAL
endif

# Optional official device roster gate if vendor/blaze/config/blaze.devices is present
ifeq ($(BLAZE_BUILD_TYPE),OFFICIAL)
ifneq ($(wildcard vendor/blaze/config/blaze.devices),)
    BLAZE_OFFICIAL_LIST := $(shell cat vendor/blaze/config/blaze.devices)
    ifneq ($(filter $(BLAZE_DEVICE),$(BLAZE_OFFICIAL_LIST)),$(BLAZE_DEVICE))
        $(error Device "$(BLAZE_DEVICE)" is not listed in vendor/blaze/config/blaze.devices for OFFICIAL build)
    endif
endif
endif

# Set BLAZE_EDITION (GAPPS vs VANILLA)
ifeq ($(WITH_GMS),true)
    BLAZE_EDITION := GAPPS
else
    BLAZE_EDITION := VANILLA
endif

BLAZE_VERSION := BlazeAOSP-$(BLAZE_VERSION_CODE)-$(BLAZE_BUILD_DATE)-$(BLAZE_EDITION)-$(BLAZE_BUILD_TYPE)-$(BLAZE_DEVICE)
BLAZE_DISPLAY_VERSION := ProjectBlaze-$(BLAZE_VERSION_CODE)-$(BLAZE_EDITION)-$(BLAZE_BUILD_TYPE)

# BlazeAOSP System Properties
PRODUCT_PRODUCT_PROPERTIES += \
    ro.blaze.version=$(BLAZE_VERSION) \
    ro.blaze.display.version=$(BLAZE_DISPLAY_VERSION) \
    ro.blaze.edition=$(BLAZE_EDITION) \
    ro.blaze.build.version=$(BLAZE_VERSION_CODE) \
    ro.blaze.build.date=$(BLAZE_BUILD_DATE) \
    ro.blaze.releasetype=$(BLAZE_BUILD_TYPE) \
    ro.blaze.device=$(BLAZE_DEVICE)

# LineageOS Compatibility Properties (for Lineage SDK / backuptool / Updater)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.lineage.version=$(BLAZE_VERSION) \
    ro.lineage.display.version=$(BLAZE_DISPLAY_VERSION) \
    ro.lineage.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.lineage.releasetype=$(BLAZE_BUILD_TYPE) \
    ro.lineage.device=$(BLAZE_DEVICE)

# Optional Release Signing Keys
-include vendor/blaze-priv/keys/keys.mk
-include vendor/lineage-priv/keys/keys.mk
