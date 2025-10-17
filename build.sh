#!/usr/bin/env bash

set -e

export CMAKE_OSX_ARCHITECTURES="arm64e;arm64"
export CMAKE_OSX_SYSROOT="iphoneos"

# --- Functions ---

show_usage() {
    echo "Usage: ./build.sh <sideload|rootless|rootful>"
}

clean_artifacts() {
    echo "Cleaning previous build artifacts..."
    make clean > /dev/null 2>&1
    rm -rf .theos
}

check_submodules() {
    if [ -z "$(ls -A modules/FLEXing)" ]; then
        echo "FLEXing submodule not found."
        exit 1
    fi
}

handle_plugins() {
    local original_ipa="packages/instagram.ipa"
    local temp_dir="packages/temp_unzip"
    
    echo "Processing IPA plugins (removing all by default)..." >&2
    
    unzip -q "$original_ipa" -d "$temp_dir"
    
    local app_path="$temp_dir/Payload/Instagram.app"
    
    if [ "${KEEP_SHARE}" != "true" ]; then
        echo "  - Removing Share Extension" >&2
        rm -rf "${app_path}/Plugins/InstagramShareExtension.appex"
    else
        echo "  - Keeping Share Extension" >&2
    fi

    if [ "${KEEP_WIDGET}" != "true" ]; then
        echo "  - Removing Widget Extension" >&2
        rm -rf "${app_path}/Plugins/InstagramWidgetExtension.appex"
    else
        echo "  - Keeping Widget Extension" >&2
    fi

    if [ "${KEEP_NOTIFICATION}" != "true" ]; then
        echo "  - Removing Notification Extensions" >&2
        rm -rf "${app_path}/Plugins/InstagramNotificationContentExtension.appex"
        rm -rf "${app_path}/Plugins/InstagramNotificationExtension.appex"
    else
        echo "  - Keeping Notification Extensions" >&2
    fi

    if [ "${KEEP_LIVEACTIVITIES}" != "true" ]; then
        echo "  - Removing Live Activities Extension" >&2
        rm -rf "${app_path}/Plugins/InstagramWidgetExtensionLiveActivities.appex"
    else
        echo "  - Keeping Live Activities Extension" >&2
    fi

    if [ "${KEEP_BROADCAST}" != "true" ]; then
        echo "  - Removing Broadcast Extension" >&2
        rm -rf "${app_path}/Plugins/InstagramBroadcastSampleHandlerExtension.appex"
    else
        echo "  - Keeping Broadcast Extension" >&2
    fi

    if [ "${KEEP_LOCKSCREEN_WIDGET}" != "true" ]; then
        echo "  - Removing Lock Screen Widget" >&2
        rm -rf "${app_path}/Plugins/InstagramWidgetExtensionLockScreenCameraControl.appex"
    else
        echo "  - Keeping Lock Screen Widget" >&2
    fi
    
    if [ "${KEEP_LOCKSCREEN_CAMERA}" != "true" ]; then
        echo "  - Removing Lock Screen Camera Extension" >&2
        rm -rf "${app_path}/Extensions/InstagramExtensionLockScreenCamera.appex"
    else
        echo "  - Keeping Lock Screen Camera Extension" >&2
    fi
    
    echo "Re-packaging cleaned IPA..." >&2
    
    (cd "$temp_dir" && zip -qr "../instagram-cleaned.ipa" .)
    
    rm -rf "$temp_dir"
    
    echo "packages/instagram-cleaned.ipa"
}


# --- Main Build Logic ---

check_submodules

if [ -z "$1" ]; then
    show_usage
    exit 1
fi

case "$1" in
    sideload)
        clean_artifacts
        
        if [ ! -f "packages/instagram.ipa" ]; then
            echo "packages/instagram.ipa not found." >&2
            exit 1
        fi
        
        ipaFile=$(handle_plugins)
        
        echo "Building SCInsta for sideloading..." >&2
        
        MAKEARGS='SIDELOAD=1'
        FLEXPATH='.theos/obj/debug/FLEXing.dylib .theos/obj/debug/libflex.dylib'
        COMPRESSION=9

        make $MAKEARGS

        echo "Creating the final IPA file..." >&2
        rm -f packages/SCInsta-sideloaded.ipa
        
        cyan -i "${ipaFile}" \
             -o packages/SCInsta-sideloaded.ipa \
             -n "${APP_NAME:-Instagram}" \
             -b "${BUNDLE_ID:-com.burbn.instagram}" \
             -f .theos/obj/debug/SCInsta.dylib .theos/obj/debug/sideloadfix.dylib $FLEXPATH \
             -c $COMPRESSION -m 15.0 -du
        ;;

    rootless)
        clean_artifacts
        echo "Building SCInsta for rootless..." >&2
        export THEOS_PACKAGE_SCHEME=rootless
        make package
        ;;

    rootful)
        clean_artifacts
        echo "Building SCInsta for rootful..." >&2
        unset THEOS_PACKAGE_SCHEME
        make package
        ;;

    *)
        echo "Error: Unknown build mode '$1'" >&2
        show_usage
        exit 1
        ;;
esac

echo "Build finished successfully!" >&2