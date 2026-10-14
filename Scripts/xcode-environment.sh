#!/bin/zsh

# Prefer the selected Xcode, then discover an installed app when xcode-select
# points to Command Line Tools. DEVELOPER_DIR always takes precedence.
if [ -z "${DEVELOPER_DIR:-}" ]; then
    DEVELOPER_DIR=$(/usr/bin/xcode-select -p)
    if [ ! -d "$DEVELOPER_DIR/Platforms/iPhoneSimulator.platform" ]; then
        for xcode_candidate in /Applications/Xcode.app /Applications/Xcode*.app(N); do
            if [ -d "$xcode_candidate/Contents/Developer/Platforms/iPhoneSimulator.platform" ]; then
                DEVELOPER_DIR="$xcode_candidate/Contents/Developer"
                break
            fi
        done
    fi
fi

if [ ! -d "$DEVELOPER_DIR/Platforms/iPhoneSimulator.platform" ]; then
    printf '%s\n' 'Full Xcode is required. Set DEVELOPER_DIR to its Contents/Developer directory.' >&2
    exit 1
fi
export DEVELOPER_DIR
