#
# Copyright (C) 2026 BlazeAOSP Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PRODUCT_VERSION_MAJOR = 24
PRODUCT_VERSION_MINOR = 0
BLAZE_VERSION_CODE = 4.0

ifeq ($(BLAZE_VERSION_APPEND_TIME_OF_DAY),true)
    BLAZE_BUILD_DATE := $(shell date -u +%Y%m%d_%H%M%S)
else
    BLAZE_BUILD_DATE := $(shell date -u +%Y%m%d)
endif

# Set BLAZE_BUILD_TYPE
ifndef BLAZE_BUILD_TYPE
    ifdef RELEASE_TYPE
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^BLAZE_||g')
        BLAZE_BUILD_TYPE := $(RELEASE_TYPE)
    endif
endif

ifeq ($(filter OFFICIAL COMMUNITY NIGHTLY EXPERIMENTAL,$(BLAZE_BUILD_TYPE)),)
    BLAZE_BUILD_TYPE := UNOFFICIAL
endif

# Set BLAZE_EDITION (GAPPS vs VANILLA)
ifeq ($(WITH_GMS),true)
    BLAZE_EDITION := GAPPS
else
    BLAZE_EDITION := VANILLA
endif

BLAZE_VERSION := BlazeAOSP-$(BLAZE_VERSION_CODE)-$(BLAZE_BUILD_DATE)-$(BLAZE_EDITION)-$(BLAZE_BUILD_TYPE)-$(BLAZE_BUILD)
BLAZE_DISPLAY_VERSION := BlazeAOSP-$(BLAZE_VERSION_CODE)-$(BLAZE_EDITION)-$(BLAZE_BUILD_TYPE)

PRODUCT_PRODUCT_PROPERTIES += \
    ro.blaze.version=$(BLAZE_VERSION) \
    ro.blaze.display.version=$(BLAZE_DISPLAY_VERSION) \
    ro.blaze.edition=$(BLAZE_EDITION) \
    ro.blaze.build.version=$(BLAZE_VERSION_CODE) \
    ro.blaze.build.date=$(BLAZE_BUILD_DATE) \
    ro.blaze.releasetype=$(BLAZE_BUILD_TYPE) \
    ro.blaze.device=$(BLAZE_BUILD)

# LineageOS compatibility properties (for Lineage SDK / LineageParts if used)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.lineage.version=$(BLAZE_VERSION) \
    ro.lineage.display.version=$(BLAZE_DISPLAY_VERSION) \
    ro.lineage.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.lineage.releasetype=$(BLAZE_BUILD_TYPE)
