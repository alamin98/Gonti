# গণতি (Gonti) — Flutter app

সহজ বাংলা হিসাবের অ্যাপ: আয়, খরচ, দেনা-পাওনা, সঞ্চয়/ডিপিএস, বাজেট।
Design: Figma "Money-Management-App" (tokens → `lib/core/tokens.dart`)

## প্রথমবার চালানো (আপনার কম্পিউটারে)
1. Flutter (stable, 3.24 বা নতুন) + Android Studio/SDK install করুন → `flutter doctor` সব ঠিক থাকা চাই।
2. একটা খালি প্রজেক্ট বানান:
   `flutter create --org com.gonti --project-name gonti gonti_app`
3. এই zip এর ভেতরের এগুলো `gonti_app` এ কপি করে replace করুন:
   `pubspec.yaml`, `analysis_options.yaml`, `lib/`, `assets/`, `test/`
   (`gonti_app/test/widget_test.dart` মুছে দিন)
4. `cd gonti_app && flutter pub get && flutter test && flutter run`
5. অ্যাপের নাম "গণতি": `android/app/src/main/AndroidManifest.xml` এ `android:label="গণতি"`

## এখন যা আছে (Phase 1 — ধাপ ১)
- Splash → Onboarding (২ পেজ) → Login (ভাষা বদল + Skip) → Shell
- ৪ ট্যাব + ভাসমান নেভ + মাঝের (+) : হোম, লেনদেন, রিপোর্ট (শীঘ্রই), আরও
- Home: কাস্টম মাস (যেমন ২৭ – ২৬), বাকি = আয় − খরচ, বাজেট বার, পাওনা/দেনা, শেষ ৫ লেনদেন
- Quick Add: আয়/খরচ, ক্যাটাগরি (নতুন যোগ), "বাজেটে ধরা হবে", তারিখ, নোট
- লেনদেন: ফিল্টার, তারিখ অনুযায়ী গ্রুপ, swipe করে মোছা
- Settings: মাস শুরুর তারিখ, মাসের বাজেট, ভাষা (বাংলা/English)
- SQLite (offline): সব মডিউলের টেবিল আগে থেকেই তৈরি

## পরের ধাপ
দেনা/পাওনা → ডিপিএস → বাজেট (ক্যাটাগরি লিমিট) → রিপোর্ট → টুলস → PIN → ক্যাটাগরি ম্যানেজ → ব্যাকআপ/Google login (Phase 2)

## নিয়ম (ডাবল গোনা ঠেকাতে)
- দেনা/পাওনা/ডিপিএসের লেনদেন সিস্টেম ক্যাটাগরি (`system_key`) দিয়ে মডিউল থেকেই তৈরি হবে, Quick Add এ দেখাবে না।
- টাকা পয়সায় (int) জমা হয়, দশমিক ভুল হয় না।

ফন্ট: Baloo Da 2 (SIL OFL) — `assets/fonts/OFL.txt`
