"""Check local archive metadata before Xcode's signed distribution validation."""
import plistlib
import sys
from pathlib import Path

archive = Path(sys.argv[1])
app = archive / "Products/Applications/MareesAmbre.app"
extensions = list(app.rglob("*.appex"))
assert len(extensions) == 1, "Expected exactly one widget extension"
extension = extensions[0]
assert extension.parent == app / "PlugIns", "Extension must be directly inside PlugIns"
metadata = []
for bundle in (app, extension):
    info = plistlib.loads((bundle / "Info.plist").read_bytes())
    for key in ("CFBundleDisplayName", "CFBundleIdentifier", "CFBundleName",
                "CFBundleExecutable", "CFBundleVersion", "CFBundleShortVersionString",
                "CFBundlePackageType", "MinimumOSVersion"):
        assert isinstance(info.get(key), str) and info[key].strip(), f"{bundle.name}: missing {key}"
    assert (bundle / info["CFBundleExecutable"]).is_file(), "Missing executable"
    metadata.append(info)
main, widget = metadata
assert main["CFBundlePackageType"] == "APPL"
assert widget["CFBundlePackageType"] == "XPC!"
assert widget["CFBundleIdentifier"].startswith(main["CFBundleIdentifier"] + ".")
for key in ("CFBundleVersion", "CFBundleShortVersionString"):
    assert main[key] == widget[key], f"Mismatched {key}"
assert widget["NSExtension"]["NSExtensionPointIdentifier"] == "com.apple.widgetkit-extension"
print("PASS: app and widget names, identifiers, versions, executables and extension embedding")
print("Apple signed distribution validation is still required in Xcode.")
