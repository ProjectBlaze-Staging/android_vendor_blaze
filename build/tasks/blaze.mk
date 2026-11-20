#
# Copyright (C) 2026 The BlazeAOSP Project
#
# SPDX-License-Identifier: Apache-2.0
#

# -----------------------------------------------------------------
# BlazeAOSP OTA update package

BLAZE_TARGET_PACKAGE := $(PRODUCT_OUT)/BlazeAOSP-$(BLAZE_VERSION).zip
SHA256 := prebuilts/build-tools/path/$(HOST_PREBUILT_TAG)/sha256sum

$(BLAZE_TARGET_PACKAGE): $(INTERNAL_OTA_PACKAGE_TARGET)
	$(hide) ln -f $(INTERNAL_OTA_PACKAGE_TARGET) $(BLAZE_TARGET_PACKAGE)
	$(hide) $(SHA256) $(BLAZE_TARGET_PACKAGE) | sed "s|$(PRODUCT_OUT)/||" > $(BLAZE_TARGET_PACKAGE).sha256sum
	@echo '------------------------------------------------------' >&2
	@echo ' BlazeAOSP 5.0 Build Complete!' >&2
	@echo ' Variant : $(BLAZE_EDITION) ($(BLAZE_BUILD_TYPE))' >&2
	@echo ' Zip     : $(BLAZE_TARGET_PACKAGE)' >&2
	@echo ' SHA256  : $(BLAZE_TARGET_PACKAGE).sha256sum' >&2
	@echo '------------------------------------------------------' >&2

.PHONY: blaze
blaze: $(BLAZE_TARGET_PACKAGE) $(DEFAULT_GOAL)

bacon: $(BLAZE_TARGET_PACKAGE)
