#!/usr/bin/env bash

set -e

echo 'Note: This script is meant to be used while developing the tweak.'
echo '      This does not build "libflex" or "FLEXing", they must be built manually and moved to ./packages'
echo

./build.sh sideload --dev

# Install to device
cp -fr ./packages/SCInsta-sideloaded.ipa ~/Documents/Signing/SCInsta/ipas/UNSIGNED.ipa
cd ~/Documents/Signing
./sign.sh SCInsta
./deploy.sh SCInsta $1