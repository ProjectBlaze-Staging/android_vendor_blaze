# Copyright (C) 2017 Unlegacy-Android
# Copyright (C) 2017,2020 The LineageOS Project
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

# -----------------------------------------------------------------
# BlazeAOSP OTA update package


BLAZE_TARGET_PACKAGE := $(PRODUCT_OUT)/BlazeAOSP-v$(BLAZE_VERSION)-$(LINEAGE_BUILD_DATE)-$(LINEAGE_BUILDTYPE)-$(TARGET_DEVICE).zip
LINEAGE_TARGET_PACKAGE := $(PRODUCT_OUT)/lineage-$(LINEAGE_VERSION).zip
BLAZE_BUILD_TYPE := $(TARGET_BUILD_VARIANT)
BLAZE_TARGET_PACKAGE := $(PRODUCT_OUT)/BlazeAOSP-$(BLAZE_VERSION)-$(BLAZE_BUILD_TYPE).zip


SHA256 := prebuilts/build-tools/path/$(HOST_PREBUILT_TAG)/sha256sum

$(BLAZE_TARGET_PACKAGE): $(INTERNAL_OTA_PACKAGE_TARGET)
	$(hide) ln -f $(INTERNAL_OTA_PACKAGE_TARGET) $(BLAZE_TARGET_PACKAGE)
	$(hide) ln -f $(INTERNAL_OTA_PACKAGE_TARGET) $(LINEAGE_TARGET_PACKAGE)
	$(hide) $(SHA256) $(BLAZE_TARGET_PACKAGE) | sed "s|$(PRODUCT_OUT)/||" > $(BLAZE_TARGET_PACKAGE).sha256sum
	$(hide) $(SHA256) $(LINEAGE_TARGET_PACKAGE) | sed "s|$(PRODUCT_OUT)/||" > $(LINEAGE_TARGET_PACKAGE).sha256sum
	@echo "Package Complete: $(BLAZE_TARGET_PACKAGE)" >&2

.PHONY: bacon
bacon: $(BLAZE_TARGET_PACKAGE) $(DEFAULT_GOAL)
	$(hide) $(SHA256) $(BLAZE_TARGET_PACKAGE) | sed "s|$(PRODUCT_OUT)/||" > $(BLAZE_TARGET_PACKAGE).sha256sum
	@echo '------------------------------------------------------' >&2
	@echo ' Blaze Yall! BlazeAOSP Build Complete!' >&2
	@echo ' Build Variant : $(BLAZE_BUILD_TYPE)' >&2
	@echo ' Output Zip    : $(BLAZE_TARGET_PACKAGE)' >&2
	@echo ' SHA256 File   : $(BLAZE_TARGET_PACKAGE).sha256sum' >&2
	@echo '------------------------------------------------------' >&2

.PHONY: bacon
bacon: $(BLAZE_TARGET_PACKAGE) $(DEFAULT_GOAL)



