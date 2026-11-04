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

# Inherit LineageOS common definitions
$(call inherit-product, vendor/lineage/config/common.mk)

# BlazeAOSP Brand & Model
PRODUCT_BRAND := BlazeAOSP

# Inherit Blaze versioning
include vendor/blaze/config/version.mk

# Custom Blaze Overlays
PRODUCT_PACKAGE_OVERLAYS += \
    vendor/blaze/overlay/common

# Blaze Performance, Frame Pacing, Thermal, LMKD PSI & Liquid Glass Properties
PRODUCT_SYSTEM_PROPERTIES += \
    dalvik.vm.usap_pool_enabled=true \
    persist.device_config.runtime_native.usap_pool_enabled=true \
    pm.dexopt.bg-dexopt=speed-profile \
    pm.dexopt.install=speed-profile \
    dalvik.vm.dex2oat-threads=4 \
    dalvik.vm.dex2oat-cpu-set=0,1,2,3,4,5 \
    ro.lmk.use_psi=true \
    ro.lmk.use_minfree_levels=false \
    ro.lmk.psi_partial_stall_ms=70 \
    ro.lmk.psi_complete_stall_ms=700 \
    ro.lmk.swap_free_low_percentage=10 \
    ro.lmk.thrashing_limit=30 \
    ro.lmk.thrashing_limit_decay=50 \
    ro.sys.fw.bg_apps_limit=48 \
    ro.surface_flinger.use_content_detection_for_refresh_rate=true \
    ro.surface_flinger.set_touch_timer_ms=200 \
    ro.surface_flinger.set_idle_timer_ms=250 \
    ro.surface_flinger.set_display_power_timer_ms=1000 \
    ro.surface_flinger.max_frame_buffer_acquired_buffers=3 \
    ro.surface_flinger.supports_background_blur=1 \
    ro.window_blur_supported=true \
    persist.sys.sf.disable_blurs=0 \
    debug.sf.latch_unsignaled=1 \
    debug.sf.auto_latch_unsignaled=true \
    debug.hwui.use_hint_manager=true \
    renderthread.skia.reduceopstasksplitting=true \
    touch.pressure.scale=0.001 \
    persist.sys.scrollingcache=3

# Blaze Custom Packages
PRODUCT_PACKAGES += \
    ThemePicker

# Blaze Prebuilt APKs (Firefox, etc.)
$(call inherit-product-if-exists, vendor/blaze/prebuilt/blaze_prebuilt.mk)

# GApps / GMS Integration (MindTheGapps, Pixel GMS, or NikGapps)
ifeq ($(WITH_GMS),true)
    $(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)
    $(call inherit-product-if-exists, vendor/gapps/x86_64/x86_64-vendor.mk)
    $(call inherit-product-if-exists, vendor/gapps/gapps.mk)
    $(call inherit-product-if-exists, vendor/partner_gms/products/gms.mk)
endif

# Blaze Banner during build
$(info )
$(info ===================================================)
$(info                   BlazeAOSP 24.0                   )
$(info ===================================================)
$(info  Building: $(BLAZE_VERSION))
$(info ===================================================)
$(info )
