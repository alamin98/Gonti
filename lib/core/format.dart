import 'period.dart';
import 'strings.dart';

/// বাংলা ভাষা চালু থাকলে true (AppState এটা সেট করে)।
bool useBangla = true;

const _bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
const _monthShortBn = ['জানু', 'ফেব্রু', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টে', 'অক্টো', 'নভে', 'ডিসে'];
const _monthFullBn = ['জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'];
const _monthShortEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _monthFullEn = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

/// ইংরেজি সংখ্যা → বাংলা সংখ্যা (ভাষা বাংলা হলে)।
String digits(String s) {
  if (!useBangla) return s;
  return s.replaceAllMapped(RegExp(r'\d'), (m) => _bnDigits[int.parse(m[0]!)]);
}

/// বাংলাদেশি গ্রুপিং: ১২,৩৪,৫৬৭
String groupBd(int n) {
  final s = n.toString();
  if (s.length <= 3) return s;
  final last = s.substring(s.length - 3);
  final rest = s.substring(0, s.length - 3);
  final b = StringBuffer();
  for (var i = 0; i < rest.length; i++) {
    if (i > 0 && (rest.length - i) % 2 == 0) b.write(',');
    b.write(rest[i]);
  }
  return '${b.toString()},$last';
}

/// পয়সা (int) → "৳ ১২,৫০০"  (পয়সা থাকলে দশমিকসহ)
String taka(int paisa) {
  final neg = paisa < 0;
  final p = paisa.abs();
  var s = groupBd(p ~/ 100);
  final frac = p % 100;
  if (frac != 0) s += '.${frac.toString().padLeft(2, '0')}';
  return '${neg ? '−' : ''}৳ ${digits(s)}';
}

String signedTaka(int paisa, bool income) => '${income ? '+' : '−'}${taka(paisa.abs())}';

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseKey(String s) {
  final p = s.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

String shortDate(DateTime d) => '${digits('${d.day}')} ${(useBangla ? _monthShortBn : _monthShortEn)[d.month - 1]}';
String dayMonth(DateTime d) => '${digits('${d.day}')} ${(useBangla ? _monthFullBn : _monthFullEn)[d.month - 1]}';
String fullDate(DateTime d) => '${dayMonth(d)} ${digits('${d.year}')}';
String periodLabel(Period p) => '${shortDate(p.start)} – ${shortDate(p.end)}';

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// আজ / গতকাল / ২২ নভে
String dayLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (sameDay(d, today)) return t('today');
  if (sameDay(d, DateTime(today.year, today.month, today.day - 1))) return t('yesterday');
  return shortDate(d);
}
