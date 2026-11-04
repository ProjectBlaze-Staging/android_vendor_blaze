#
# Copyright (C) 2026 BlazeAOSP Project
#

# Ensure LC_ALL and LANG are set to C / C.UTF-8 to prevent Java/AutoValue Turkish 'i' locale bugs
export LC_ALL=C
export LANG=C.UTF-8

function blaze_help() {
    echo "BlazeAOSP Build Commands:"
    echo "  blaze <device> [variant]   - Lunch and build bacon for target device (default: userdebug)"
    echo "  blazefast <device>         - Lunch target device"
    echo "  mka <target>               - Fast parallel build wrapper for m"
}

function blazefast()
{
    local target=$1
    local variant=$2
    local aosp_target_release="cp2a"
    if [ -f ${ANDROID_BUILD_TOP}/vendor/lineage/vars/aosp_target_release ]; then
        source ${ANDROID_BUILD_TOP}/vendor/lineage/vars/aosp_target_release
    fi

    if [ -z "$target" ]; then
        lunch
    else
        if [[ "$target" =~ -(user|userdebug|eng)$ ]]; then
            lunch $target
        else
            if [ -z "$variant" ]; then
                variant="userdebug"
            fi
            lunch blaze_$target-$aosp_target_release-$variant 2>/dev/null || lunch lineage_$target-$aosp_target_release-$variant
        fi
    fi
    return $?
}

function blaze()
{
    blazefast $*
    if [ $? -eq 0 ]; then
        mka bacon
    else
        echo "Failed to lunch target device. Try blazefast <device>"
        return 1
    fi
    return $?
}

alias bz=blaze
alias bzf=blazefast
