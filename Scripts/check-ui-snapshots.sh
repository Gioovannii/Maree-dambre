#!/bin/zsh
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
source "$project_root/Scripts/xcode-environment.sh"
developer_dir="$DEVELOPER_DIR"
mode="${1:-verify}"
build_dir="/tmp/MareesAmbreSnapshotDerivedData"
snapshot_device="${SNAPSHOT_DEVICE:-iphone}"
output_dir="/tmp/MareesAmbreUISnapshots/$snapshot_device"

case "$snapshot_device" in
    iphone)
        device_name='iPhone 18 Pro'
        capture_delay=3
        reference_dir="$project_root/Tests/Snapshots/iPhone18Pro-iOS27"
        districts=(resources centre upgrade world market forge infirmary expeditionQuay commerce raidReport expansion expansionDeparture colony shipment shipmentDeparture mailbox mailDetail protection)
        ;;
    ipad)
        device_name='iPad Pro 11-inch (M5)'
        capture_delay=5
        reference_dir="$project_root/Tests/Snapshots/iPad11-iOS27"
        districts=(resources centre world expansion mailbox mailDetail protection)
        ;;
    *)
        print -u2 'SNAPSHOT_DEVICE must be iphone or ipad'
        exit 2
        ;;
esac

# Restrict a run to one or more comma-separated screens.
if [[ -n "${SNAPSHOT_SCREEN:-}" ]]; then
    districts=("${(@s:,:)SNAPSHOT_SCREEN}")
    for district in "${districts[@]}"; do
        case "$district" in
            raidPreparation|worldTravel|heroSupport|absence|storage|resources|centre|upgrade|world|market|forge|infirmary|expeditionQuay|commerce|raidReport|expansion|expansionDeparture|colony|shipment|shipmentDeparture|mailbox|mailDetail|protection|botAttacks|hero|heroProfile|heroMission|heroActive|heroRepair|heroBoat|heroEquipment|heroEquipmentLocked|heroEquipmentMax|heroEnhancedMission) ;;
            *) print -u2 'Unknown SNAPSHOT_SCREEN'; exit 2 ;;
        esac
    done
fi

if [[ "$mode" != verify && "$mode" != record && "$mode" != capture ]]; then
    print -u2 "Usage: $0 [verify|record|capture]"
    exit 2
fi

simctl() { DEVELOPER_DIR="$developer_dir" /usr/bin/xcrun simctl "$@"; }
simulator_id="${SIMULATOR_ID:-$(simctl list devices available --json | /usr/bin/python3 -c '
import json, sys
devices = json.load(sys.stdin)["devices"].get("com.apple.CoreSimulator.SimRuntime.iOS-27-0", [])
matches = [device for device in devices if device["name"] == sys.argv[1]]
matches.sort(key=lambda device: device["state"] != "Booted")
if not matches:
    sys.exit("Install an iOS 27.0 simulator for " + sys.argv[1] + " or set SIMULATOR_ID.")
print(matches[0]["udid"])
' "$device_name")}"

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

simctl bootstatus "$simulator_id" -b
app_path="$build_dir/Build/Products/Debug-iphonesimulator/MareesAmbre.app"
bundle_id=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$app_path/Info.plist")
simctl install "$simulator_id" "$app_path"
# The ISO timestamp also freezes the date displayed in the iPad status bar.
# simctl's ISO parser requires fractional seconds.
simctl status_bar "$simulator_id" override --time '2026-10-13T09:41:00.000+08:00' --dataNetwork wifi \
    --wifiMode active --wifiBars 3 --cellularMode active --cellularBars 4 \
    --batteryState charged --batteryLevel 100
trap 'simctl status_bar "$simulator_id" clear' EXIT

DEVELOPER_DIR="$developer_dir" /usr/bin/xcrun swiftc -O \
    -module-cache-path /tmp/MareesAmbreSwiftModuleCache \
    "$project_root/Scripts/compare-snapshot.swift" -o "$output_dir/compare-snapshot"

for district in "${districts[@]}"; do
    simctl terminate "$simulator_id" "$bundle_id" >/dev/null 2>&1 || true
    snapshot_args=(--ui-snapshot -AppleLanguages '(fr)' -AppleLocale fr_FR)
    case "$district" in
        absence) snapshot_args+=(--snapshot-developed --snapshot-absence) ;;
        storage) snapshot_args+=(--snapshot-developed --snapshot-storage) ;;
        centre) snapshot_args+=(--snapshot-center) ;;
        upgrade) snapshot_args+=(--snapshot-upgrade) ;;
        world) snapshot_args+=(--snapshot-world) ;;
        raidPreparation) snapshot_args+=(--snapshot-developed --snapshot-raid --snapshot-hero-profile --snapshot-raid-preparation) ;;
        worldTravel) snapshot_args+=(--snapshot-developed --snapshot-world --snapshot-world-travel) ;;
        heroSupport) snapshot_args+=(--snapshot-developed --snapshot-world --snapshot-hero-support) ;;
        commerce) snapshot_args+=(--snapshot-world --snapshot-commerce) ;;
        heroEnhancedMission) snapshot_args+=(--snapshot-developed --snapshot-missions --snapshot-hero --snapshot-hero-profile --snapshot-hero-equipment --snapshot-hero-enhanced-mission) ;;
        heroEquipment) snapshot_args+=(--snapshot-developed --snapshot-missions --snapshot-hero --snapshot-hero-profile --snapshot-hero-equipment) ;;
        heroEquipmentLocked) snapshot_args+=(--snapshot-developed --snapshot-missions --snapshot-hero --snapshot-hero-profile --snapshot-hero-equipment --snapshot-equipment-locked) ;;
        heroEquipmentMax) snapshot_args+=(--snapshot-developed --snapshot-missions --snapshot-hero --snapshot-hero-profile --snapshot-hero-equipment --snapshot-equipment-max) ;;
        heroMission) snapshot_args+=(--snapshot-developed --snapshot-missions --snapshot-hero --snapshot-hero-mission) ;;
        heroActive) snapshot_args+=(--snapshot-developed --snapshot-missions --snapshot-hero --snapshot-hero-mission --snapshot-hero-active) ;;
        heroRepair) snapshot_args+=(--snapshot-developed --snapshot-missions --snapshot-hero --snapshot-hero-mission --snapshot-hero-repair) ;;
        heroBoat) snapshot_args+=(--snapshot-developed --snapshot-missions --snapshot-hero --snapshot-hero-mission --snapshot-hero-boat) ;;
        hero) snapshot_args+=(--snapshot-developed --snapshot-missions --snapshot-hero) ;;
        heroProfile) snapshot_args+=(--snapshot-developed --snapshot-missions --snapshot-hero --snapshot-hero-profile) ;;
        botAttacks) snapshot_args+=(--snapshot-developed --snapshot-missions --snapshot-bot-attacks) ;;
        protection) snapshot_args+=(--snapshot-developed --snapshot-protection) ;;
        mailbox) snapshot_args+=(--snapshot-developed --snapshot-mailbox) ;;
        mailDetail) snapshot_args+=(--snapshot-developed --snapshot-mail-detail) ;;
        shipmentDeparture) snapshot_args+=(--snapshot-expansion --snapshot-shipment --snapshot-shipment-departure) ;;
        shipment) snapshot_args+=(--snapshot-expansion --snapshot-shipment) ;;
        colony) snapshot_args+=(--snapshot-expansion --snapshot-colony) ;;
        expansionDeparture) snapshot_args+=(--snapshot-expansion --snapshot-expansion-departure) ;;
        expansion) snapshot_args+=(--snapshot-expansion) ;;
        raidReport) snapshot_args+=(--snapshot-developed --snapshot-raid-report) ;;
        market|forge|infirmary|expeditionQuay)
            snapshot_args+=("--snapshot-$district" --snapshot-actions)
            ;;
    esac
    simctl launch "$simulator_id" "$bundle_id" "${snapshot_args[@]}" >/dev/null
    case "$district" in
        worldTravel|heroSupport) sleep 8 ;;
        *) sleep "$capture_delay" ;;
    esac
    # Make hardware cutouts deterministic when Device Hub is shown or hidden.
    simctl io "$simulator_id" screenshot --mask=black "$output_dir/$district.png" >/dev/null 2>&1

    if [[ "$mode" == record ]]; then
        mkdir -p "$reference_dir"
        cp "$output_dir/$district.png" "$reference_dir/$district.png"
        print "RECORDED: $district"
    elif [[ "$mode" == capture ]]; then
        print "CAPTURED: $output_dir/$district.png"
    elif "$output_dir/compare-snapshot" "$reference_dir/$district.png" "$output_dir/$district.png"; then
        print "PASS: $district matches its $device_name snapshot"
    else
        print -u2 "FAIL: $district differs from $reference_dir/$district.png"
        print -u2 "Actual capture: $output_dir/$district.png"
        exit 1
    fi
done
