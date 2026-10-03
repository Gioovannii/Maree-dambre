#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
APP_PATH=${1:?Pass the absolute path of the built MareesAmbre.app}
CHECK_DIR=$(mktemp -d /tmp/marees-localization.XXXXXX)
xcrun swift -module-cache-path "$CHECK_DIR/cache" Tests/LocalizationChecks.swift "$APP_PATH" "$PWD"
