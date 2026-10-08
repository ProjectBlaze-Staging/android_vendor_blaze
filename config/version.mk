PRODUCT_VERSION_MAJOR = 24
PRODUCT_VERSION_MINOR = 0

# BlazeAOSP define
BLAZE_MAJVERSION := First
BLAZE_DEVICE := $(lastword $(subst _, ,$(TARGET_PRODUCT)))
BLAZE_BUILD_TYPE := $(TARGET_BUILD_VARIANT)

BLAZE_DISPLAY_VERSION := $(BLAZE_MAJVERSION)
BLAZE_VERSION := $(BLAZE_MAJVERSION)-$(BLAZE_DEVICE)-$(shell date +%Y%m%d)-$(BLAZE_BUILD_TYPE)

ifeq ($(LINEAGE_VERSION_APPEND_TIME_OF_DAY),true)
    LINEAGE_BUILD_DATE := $(shell date -u +%Y%m%d_%H%M%S)
else
    LINEAGE_BUILD_DATE := $(shell date -u +%Y%m%d)
endif

# Set LINEAGE_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef LINEAGE_BUILDTYPE
    ifdef BLAZE_BUILD_TYPE
        LINEAGE_BUILDTYPE := $(BLAZE_BUILD_TYPE)
    else ifdef RELEASE_TYPE
        # Starting with "LINEAGE_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^LINEAGE_||g')
        LINEAGE_BUILDTYPE := $(RELEASE_TYPE)
    else
        LINEAGE_BUILDTYPE := OFFICIAL
    endif
endif

# Filter out random types, so it'll reset to OFFICIAL
ifeq ($(filter OFFICIAL RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL UNOFFICIAL,$(LINEAGE_BUILDTYPE)),)
    LINEAGE_BUILDTYPE := OFFICIAL
    LINEAGE_EXTRAVERSION :=
endif

ifeq ($(LINEAGE_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        LINEAGE_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

LINEAGE_VERSION_SUFFIX := $(LINEAGE_BUILD_DATE)-$(LINEAGE_BUILDTYPE)$(LINEAGE_EXTRAVERSION)-$(LINEAGE_BUILD)

# Internal version
LINEAGE_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(LINEAGE_VERSION_SUFFIX)

# Display version
LINEAGE_DISPLAY_VERSION := $(BLAZE_DISPLAY_VERSION)

# BlazeAOSP and LineageOS version properties
PRODUCT_PRODUCT_PROPERTIES += \
    ro.blaze.version=$(BLAZE_VERSION) \
    ro.blaze.display.version=$(BLAZE_DISPLAY_VERSION) \
    ro.blaze.releasetype=$(LINEAGE_BUILDTYPE) \
    ro.lineage.version=$(LINEAGE_VERSION) \
    ro.lineage.display.version=$(BLAZE_DISPLAY_VERSION) \
    ro.lineage.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.lineage.releasetype=$(LINEAGE_BUILDTYPE)
