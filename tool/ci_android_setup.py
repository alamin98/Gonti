"""CI: flutter create এর পরে Android প্রজেক্ট ঠিক করে।
- অ্যাপের নাম "গণতি"
- GONTI_KEYSTORE_B64 secret থাকলে release build সেই একই key দিয়ে sign হয়
  (একই key = আপডেট install করলে ডেটা থাকে, Play Store এও এটাই লাগবে)
"""
import base64, os, re, pathlib

app = pathlib.Path('android/app')
manifest = app / 'src/main/AndroidManifest.xml'
m = manifest.read_text()
m = re.sub(r'android:label="[^"]*"', 'android:label="গণতি"', m, count=1)
manifest.write_text(m)

# Firebase (auth, firestore) এর জন্য minSdk 23
for g in (app / 'build.gradle.kts', app / 'build.gradle'):
    if g.exists():
        t = g.read_text()
        t = t.replace('minSdk = flutter.minSdkVersion', 'minSdk = 23').replace('minSdkVersion flutter.minSdkVersion', 'minSdkVersion 23')
        # Android lint release build এ crash করছে (Firebase plugin এর Java doc) — release lint বন্ধ
        lint = '    lint {\n        checkReleaseBuilds = false\n        abortOnError = false\n    }\n\n' if g.suffix == '.kts' else '    lintOptions {\n        checkReleaseBuilds false\n        abortOnError false\n    }\n\n'
        if 'checkReleaseBuilds' not in t:
            t = t.replace('    buildTypes {', lint + '    buildTypes {', 1)
        g.write_text(t)

b64 = os.environ.get('GONTI_KEYSTORE_B64', '').strip()
if not b64:
    print('No keystore secret: release build uses debug key')
    raise SystemExit(0)

clean = re.sub(r'[^A-Za-z0-9+/=]', '', b64).rstrip('=')
print(f'keystore secret length: {len(b64)} chars (clean {len(clean)}), expected 3488')
try:
    data = base64.b64decode(clean + '=' * (-len(clean) % 4))
    # JKS (feedfeed) বা PKCS12 (ASN.1 sequence 0x30 0x82)
    if data[:4] != bytes.fromhex('feedfeed') and data[:2] != bytes.fromhex('3082'):
        raise ValueError('not a keystore file')
except Exception as e:
    print(f'::warning::GONTI_KEYSTORE_B64 secret ঠিক নেই ({e}) — debug key দিয়ে build হচ্ছে')
    raise SystemExit(0)
(app / 'gonti-release.jks').write_bytes(data)
kts = app / 'build.gradle.kts'
groovy = app / 'build.gradle'
if kts.exists():
    s = kts.read_text()
    block = '''    signingConfigs {
        create("release") {
            storeFile = file("gonti-release.jks")
            storePassword = System.getenv("GONTI_KEYSTORE_PASSWORD")
            keyAlias = "gonti"
            keyPassword = System.getenv("GONTI_KEYSTORE_PASSWORD")
        }
    }

    buildTypes {'''
    s = s.replace('    buildTypes {', block, 1)
    s = s.replace('signingConfig = signingConfigs.getByName("debug")', 'signingConfig = signingConfigs.getByName("release")')
    kts.write_text(s)
else:
    s = groovy.read_text()
    block = '''    signingConfigs {
        release {
            storeFile file("gonti-release.jks")
            storePassword System.getenv("GONTI_KEYSTORE_PASSWORD")
            keyAlias "gonti"
            keyPassword System.getenv("GONTI_KEYSTORE_PASSWORD")
        }
    }

    buildTypes {'''
    s = s.replace('    buildTypes {', block, 1)
    s = s.replace('signingConfig signingConfigs.debug', 'signingConfig signingConfigs.release')
    groovy.write_text(s)
print('Release signing configured')
