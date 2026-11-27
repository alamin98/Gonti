import 'package:flutter_test/flutter_test.dart';
import 'package:gonti/core/format.dart';
import 'package:gonti/core/period.dart';

void main() {
  group('periodFor (কাস্টম মাস)', () {
    test('২৭ তারিখ থেকে মাস: ২৪ নভেম্বর → ২৭ অক্টো – ২৬ নভে', () {
      final p = periodFor(DateTime(2026, 11, 24), 27);
      expect(p.start, DateTime(2026, 10, 27));
      expect(p.end, DateTime(2026, 11, 26));
    });

    test('২৭ নভেম্বর থেকে নতুন মাস শুরু', () {
      final p = periodFor(DateTime(2026, 11, 27), 27);
      expect(p.start, DateTime(2026, 11, 27));
      expect(p.end, DateTime(2026, 12, 26));
    });

    test('১ তারিখ হলে সাধারণ ক্যালেন্ডার মাস', () {
      final p = periodFor(DateTime(2026, 11, 24), 1);
      expect(p.start, DateTime(2026, 11, 1));
      expect(p.end, DateTime(2026, 11, 30));
    });

    test('৩১ তারিখ, ফেব্রুয়ারিতে শেষ তারিখ ধরা হয়', () {
      final p = periodFor(DateTime(2026, 2, 10), 31);
      expect(p.start, DateTime(2026, 1, 31));
      expect(p.end, DateTime(2026, 2, 27));
      final q = periodFor(DateTime(2026, 2, 28), 31);
      expect(q.start, DateTime(2026, 2, 28));
      expect(q.end, DateTime(2026, 3, 30));
    });

    test('offset -১ = আগের মাস', () {
      final p = periodFor(DateTime(2026, 11, 24), 27, offset: -1);
      expect(p.start, DateTime(2026, 9, 27));
      expect(p.end, DateTime(2026, 10, 26));
    });

    test('বছর পেরোলে ঠিক থাকে', () {
      final p = periodFor(DateTime(2026, 1, 5), 27);
      expect(p.start, DateTime(2025, 12, 27));
      expect(p.end, DateTime(2026, 1, 26));
    });
  });

  group('format', () {
    setUp(() => useBangla = true);

    test('বাংলাদেশি গ্রুপিং', () {
      expect(groupBd(999), '999');
      expect(groupBd(1250), '1,250');
      expect(groupBd(45000), '45,000');
      expect(groupBd(120000), '1,20,000');
      expect(groupBd(1234567), '12,34,567');
    });

    test('টাকা বাংলা সংখ্যায়', () {
      expect(taka(4500000), '৳ ৪৫,০০০');
      expect(taka(125050), '৳ ১,২৫০.৫০');
      expect(taka(-100000), '−৳ ১,০০০');
    });

    test('ইংরেজি মোডে সংখ্যা ইংরেজি', () {
      useBangla = false;
      expect(taka(4500000), '৳ 45,000');
    });
  });
}
