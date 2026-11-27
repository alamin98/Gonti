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

b64 = os.environ.get('GONTI_KEYSTORE_B64', '').strip()
if not b64:
    print('No keystore secret: release build uses debug key')
    raise SystemExit(0)

(app / 'gonti-release.jks').write_bytes(base64.b64decode(b64))
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
