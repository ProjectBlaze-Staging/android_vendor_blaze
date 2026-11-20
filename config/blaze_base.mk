#
# Copyright (C) 2026 The BlazeAOSP Project
#
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(_BLAZE_BASE_INCLUDED),)
_BLAZE_BASE_INCLUDED := true

# BlazeAOSP release flavor. Vanilla is the reproducible default; LiteGApps
# requires an authorized partner GMS tree.
BLAZE_BUILD_VARIANT ?= vanilla
ifneq ($(filter $(BLAZE_BUILD_VARIANT),vanilla litegapps),$(BLAZE_BUILD_VARIANT))
$(error Unsupported BLAZE_BUILD_VARIANT "$(BLAZE_BUILD_VARIANT)"; use vanilla or litegapps)
endif

ifeq ($(BLAZE_BUILD_VARIANT),litegapps)
WITH_GMS := true
GMS_MAKEFILE ?= gms_minimal.mk
ifeq ($(wildcard vendor/partner_gms/products/$(GMS_MAKEFILE)),)
$(error LiteGApps requires vendor/partner_gms/products/$(GMS_MAKEFILE))
endif
$(call inherit-product, vendor/partner_gms/products/$(GMS_MAKEFILE))
endif

# BlazeAOSP Brand
PRODUCT_BRAND := BlazeAOSP

# Blaze Overlays (default_wallpaper, platlogo, webview allowlist)
PRODUCT_PACKAGE_OVERLAYS += \
    vendor/blaze/overlay/common

# Blaze Properties, Performance, LMKD PSI & Blur Defaults
PRODUCT_PRODUCT_PROPERTIES += \
    ro.blaze.build.variant=$(BLAZE_BUILD_VARIANT) \
    ro.com.android.mobiledata=true \
    persist.sys.zram_enabled=1 \
    ro.lmk.kill_heaviest_task=true \
    ro.lmk.kill_timeout_ms=100 \
    ro.lmk.use_psi=true \
    ro.lmk.swap_free_low_percentage=10 \
    ro.lmk.thrashing_limit=100 \
    ro.lmk.thrashing_limit_decay=10 \
    ro.lmk.psi_partial_stall_ms=70 \
    ro.lmk.psi_complete_stall_ms=700 \
    ro.lmk.swap_util_max=90 \
    debug.sf.disable_backpressure=0 \
    ro.surface_flinger.supports_background_blur=1 \
    persist.sys.sf.disable_blurs=0 \
    ro.sf.blurs_are_expensive=0 \
    dalvik.vm.usap_pool_enabled=true \
    persist.device_config.runtime_native.usap_pool_enabled=true \
    pm.dexopt.bg-dexopt=speed-profile \
    pm.dexopt.install=speed-profile \
    dalvik.vm.dex2oat-threads=4 \
    dalvik.vm.dex2oat-cpu-set=0,1,2,3,4,5 \
    ro.sys.fw.bg_apps_limit=48 \
    ro.surface_flinger.use_content_detection_for_refresh_rate=true \
    ro.surface_flinger.set_touch_timer_ms=200 \
    ro.surface_flinger.set_idle_timer_ms=250 \
    ro.surface_flinger.set_display_power_timer_ms=1000 \
    ro.surface_flinger.max_frame_buffer_acquired_buffers=3 \
    ro.window_blur_supported=true \
    debug.sf.latch_unsignaled=1 \
    debug.sf.auto_latch_unsignaled=true \
    debug.hwui.use_hint_manager=true \
    renderthread.skia.reduceopstasksplitting=true \
    touch.pressure.scale=0.001 \
    persist.sys.scrollingcache=3

# Performance & Sysctl Init Script
PRODUCT_COPY_FILES += \
    vendor/blaze/prebuilt/common/etc/init/blaze-perf.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/blaze-perf.rc

# Blaze Core Packages & Prebuilts (Vanilla)
PRODUCT_PACKAGES -= \
    Browser2 \
    Jelly

PRODUCT_PACKAGES += \
    BlazeIcons \
    Firefox \
    FossifyGallery \
    ThemePicker \
    Wallpapera.jpg \
    Wallpaperb.jpg \
    Wallpaperl.jpg

# GoogleWeather launcher bridge only when GMS is integrated
ifeq ($(WITH_GMS),true)
PRODUCT_PACKAGES += \
    GoogleWeather
endif

# Modern Pixel UI Sound Pack
PIXEL_SOUND_FILES := \
    camera_click camera_focus VideoRecord VideoStop Lock Unlock Effect_Tick \
    LowBattery ChargingStarted WirelessChargingStarted Dock Undock \
    KeypressStandard KeypressDelete KeypressSpacebar KeypressReturn \
    InCallNotification NFCInitiated NFCSuccess NFCFailure \
    NFCTransferInitiated NFCTransferComplete

PRODUCT_COPY_FILES += $(foreach fn,$(PIXEL_SOUND_FILES),\
    vendor/blaze/prebuilt/common/media/audio/ui/$(fn).ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ui/$(fn).ogg)

# Versioning & OTA
include vendor/blaze/config/version.mk
include vendor/blaze/config/ota.mk

endif # _BLAZE_BASE_INCLUDED
