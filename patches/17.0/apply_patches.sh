#!/usr/bin/env bash
set -e

TOP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Applying ProjectBlaze 17.0 patches in $TOP_DIR ..."

apply_am() {
    local target="$1"
    local pdir="$2"
    if [ -d "$TOP_DIR/$target" ] && [ -d "$PATCH_DIR/$pdir" ]; then
        echo "  [am] $target <- $pdir"
        git -C "$TOP_DIR/$target" am --3way "$PATCH_DIR/$pdir"/*.patch || git -C "$TOP_DIR/$target" am --abort
    fi
}

apply_diff() {
    local target="$1"
    local pfile="$2"
    if [ -d "$TOP_DIR/$target" ] && [ -f "$PATCH_DIR/$pfile" ]; then
        echo "  [apply] $target <- $pfile"
        git -C "$TOP_DIR/$target" apply --check "$PATCH_DIR/$pfile" 2>/dev/null && \
            git -C "$TOP_DIR/$target" apply "$PATCH_DIR/$pfile" || \
            echo "    (already applied or skipped)"
    fi
}

apply_am "packages/apps/Aperture" "Aperture"
apply_am "packages/apps/Backgrounds" "Backgrounds"
apply_am "packages/apps/Launcher3" "Launcher3"
apply_am "packages/apps/SetupWizard" "SetupWizard"

apply_diff "build/make" "build_make.patch"
apply_diff "build/soong" "build_soong.patch"
apply_diff "device/lineage/sepolicy" "device_lineage_sepolicy.patch"
apply_diff "frameworks/av" "frameworks_av.patch"
apply_diff "packages/apps/Aperture" "packages_apps_Aperture.patch"
apply_diff "packages/modules/Connectivity" "packages_modules_Connectivity.patch"
apply_diff "system/bpf" "system_bpf.patch"
apply_diff "system/core" "system_core.patch"
apply_diff "system/sepolicy" "system_sepolicy.patch"
apply_diff "system/vold" "system_vold.patch"

echo "All ProjectBlaze 17.0 patches processed successfully."
