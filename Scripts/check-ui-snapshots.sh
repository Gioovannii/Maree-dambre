#!/bin/zsh
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
developer_dir="${DEVELOPER_DIR:-/Applications/Xcode 27.1.app/Contents/Developer}"
simulator_id="${SIMULATOR_ID:-FB634AC5-AA73-49F9-86DE-8BB59894AC25}"
mode="${1:-verify}"
build_dir="/tmp/MareesAmbreSnapshotDerivedData"
output_dir="/tmp/MareesAmbreUISnapshots"
reference_dir="$project_root/Tests/Snapshots/iPhone18Pro-iOS27"

if [[ "$mode" != verify && "$mode" != record ]]; then
    print -u2 "Usage: $0 [verify|record]"
    exit 2
fi

mkdir -p "$output_dir"
DEVELOPER_DIR="$developer_dir" "$developer_dir/usr/bin/xcodebuild" \
    -project "$project_root/MareesAmbre.xcodeproj" \
    -scheme MareesAmbre -configuration Debug \
    -destination "platform=iOS Simulator,id=$simulator_id" \
    -derivedDataPath "$build_dir" CODE_SIGNING_ALLOWED=NO build \
    > "$output_dir/build.log" 2>&1 || {
        rg 'error:|BUILD FAILED' "$output_dir/build.log" | tail -n 12
        exit 1
    }

simctl() { DEVELOPER_DIR="$developer_dir" /usr/bin/xcrun simctl "$@"; }
app_path="$build_dir/Build/Products/Debug-iphonesimulator/MareesAmbre.app"
bundle_id=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$app_path/Info.plist")
simctl install "$simulator_id" "$app_path"
simctl status_bar "$simulator_id" override --time '9:41' --dataNetwork wifi \
    --wifiMode active --wifiBars 3 --cellularMode active --cellularBars 4 \
    --batteryState charged --batteryLevel 100
trap 'simctl status_bar "$simulator_id" clear' EXIT

DEVELOPER_DIR="$developer_dir" /usr/bin/xcrun swiftc -O \
    -module-cache-path /tmp/MareesAmbreSwiftModuleCache \
    "$project_root/Scripts/compare-snapshot.swift" -o "$output_dir/compare-snapshot"

for district in resources centre upgrade world; do
    simctl terminate "$simulator_id" "$bundle_id" >/dev/null 2>&1 || true
    if [[ "$district" == centre ]]; then
        simctl launch "$simulator_id" "$bundle_id" --ui-snapshot --snapshot-center >/dev/null
    elif [[ "$district" == upgrade ]]; then
        simctl launch "$simulator_id" "$bundle_id" --ui-snapshot --snapshot-upgrade >/dev/null
    elif [[ "$district" == world ]]; then
        simctl launch "$simulator_id" "$bundle_id" --ui-snapshot --snapshot-world >/dev/null
    else
        simctl launch "$simulator_id" "$bundle_id" --ui-snapshot >/dev/null
    fi
    sleep 3
    simctl io "$simulator_id" screenshot "$output_dir/$district.png" >/dev/null 2>&1

    if [[ "$mode" == record ]]; then
        mkdir -p "$reference_dir"
        cp "$output_dir/$district.png" "$reference_dir/$district.png"
        print "RECORDED: $district"
    elif "$output_dir/compare-snapshot" "$reference_dir/$district.png" "$output_dir/$district.png"; then
        print "PASS: $district matches its iPhone 18 Pro snapshot"
    else
        print -u2 "FAIL: $district differs from $reference_dir/$district.png"
        print -u2 "Actual capture: $output_dir/$district.png"
        exit 1
    fi
done
