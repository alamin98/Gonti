"""CI (macOS): flutter create এর পরে iOS প্রজেক্ট ঠিক করে।
- অ্যাপের নাম "গণতি"
- Google লগইনের URL scheme (REVERSED_CLIENT_ID)
- Firebase এর জন্য iOS 13+
"""
import pathlib, plistlib, re

root = pathlib.Path(__file__).resolve().parent.parent
fb = plistlib.loads((root / 'firebase/GoogleService-Info.plist').read_bytes())

info_path = root / 'ios/Runner/Info.plist'
info = plistlib.loads(info_path.read_bytes())
info['CFBundleDisplayName'] = 'গণতি'
info['CFBundleName'] = 'গণতি'
scheme = fb['REVERSED_CLIENT_ID']
types = info.setdefault('CFBundleURLTypes', [])
if not any(scheme in t.get('CFBundleURLSchemes', []) for t in types):
    types.append({'CFBundleTypeRole': 'Editor', 'CFBundleURLSchemes': [scheme]})
info['GIDClientID'] = fb['CLIENT_ID']
info_path.write_bytes(plistlib.dumps(info))

# Podfile: iOS 13 (Firebase এর ন্যূনতম)
podfile = root / 'ios/Podfile'
if podfile.exists():
    p = podfile.read_text()
    p = re.sub(r"^#?\s*platform :ios.*$", "platform :ios, '13.0'", p, count=1, flags=re.M)
    if "platform :ios" not in p:
        p = "platform :ios, '13.0'\n" + p
    podfile.write_text(p)

# Xcode প্রজেক্টেও deployment target 13.0
pbx = root / 'ios/Runner.xcodeproj/project.pbxproj'
s = pbx.read_text()
s = re.sub(r'IPHONEOS_DEPLOYMENT_TARGET = [0-9.]+;', 'IPHONEOS_DEPLOYMENT_TARGET = 13.0;', s)
pbx.write_text(s)
print('iOS setup done, URL scheme:', scheme)
