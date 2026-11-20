#
# Copyright (C) 2026 The BlazeAOSP Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Ensure POSIX/C locale to prevent Java/AutoValue Turkish 'i' case conversion bugs
export LC_ALL=C
export LANG=C.UTF-8

function blaze_help() {
    cat << "EOF"
BlazeAOSP Build Commands:
  blaze <device> [variant]   - Breakfast and build BlazeAOSP zip for target device
  blazefast <device>         - Lunch target device (blaze_<device> or lineage_<device>)
  breakfast <device>         - Select BlazeAOSP device target (runs roomservice if needed)
  brunch <device>            - Breakfast and build BlazeAOSP OTA package
EOF
}

function check_product()
{
    local T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree. Try setting TOP." >&2
        return
    fi
    if (echo -n $1 | grep -q -e "^blaze_") ; then
        BLAZE_BUILD=$(echo -n $1 | sed -e 's/^blaze_//g')
        LINEAGE_BUILD=
    elif (echo -n $1 | grep -q -e "^lineage_") ; then
        LINEAGE_BUILD=$(echo -n $1 | sed -e 's/^lineage_//g')
        BLAZE_BUILD=
    else
        BLAZE_BUILD=
        LINEAGE_BUILD=
    fi
    export BLAZE_BUILD
    export LINEAGE_BUILD

    TARGET_PRODUCT=$1 \
    TARGET_RELEASE=$2 \
    TARGET_BUILD_VARIANT= \
    TARGET_BUILD_TYPE= \
    TARGET_BUILD_APPS= \
    _get_build_var_cached TARGET_DEVICE > /dev/null
}

function breakfast()
{
    local target=$1
    local variant=$2
    local aosp_target_release="cp2a"
    if [ -f "${ANDROID_BUILD_TOP}/vendor/lineage/vars/aosp_target_release" ]; then
        source "${ANDROID_BUILD_TOP}/vendor/lineage/vars/aosp_target_release"
    fi

    if [ $# -eq 0 ]; then
        lunch
    elif [[ "$target" =~ -(user|userdebug|eng)$ ]]; then
        lunch "$target"
    else
        if [ -z "$variant" ]; then
            variant="userdebug"
        fi
        if ! lunch "blaze_${target}-${aosp_target_release}-${variant}" 2>/dev/null; then
            lunch "lineage_${target}-${aosp_target_release}-${variant}"
        fi
    fi
    return $?
}

alias bib=breakfast
alias blazefast=breakfast

function brunch()
{
    breakfast $*
    if [ $? -eq 0 ]; then
        mka blaze
    else
        echo "No such item in brunch menu. Try 'breakfast'"
        return 1
    fi
    return $?
}

function blaze()
{
    brunch $*
    return $?
}

alias bz=blaze
alias bzf=blazefast
