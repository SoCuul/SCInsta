#!/usr/bin/env bash

set -e

echo 'Note: This script is meant to be used while developing the tweak.'
echo '      This does not build "libflex" or "FLEXing", they must be built manually and moved to ./packages'
echo

if [ "$1" == "true" ];
then
    _scinsta_dev_before
    
    # Build tweak and package into ipa
    ./build.sh sideload --dev

    _scinsta_dev_after
else
    _scinsta_devquick_before

    # Built tweak and deploy to live container
    make clean
    make DEV=1

    # Change framework locations to @rpath
    install_name_tool -change "/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate" "@rpath/CydiaSubstrate.framework/CydiaSubstrate" ".theos/obj/debug/SCInsta.dylib" 2>/dev/null || true

    _scinsta_devquick_after
fi