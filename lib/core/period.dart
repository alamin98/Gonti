/// কাস্টম মাস: ইউজার যেদিন থেকে মাস শুরু করতে চায় (যেমন ২৭ তারিখ)।
/// start ও end দুটোই inclusive, শুধু তারিখ (সময় নেই)।
class Period {
  const Period(this.start, this.end);
  final DateTime start;
  final DateTime end;

  bool contains(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return !x.isBefore(start) && !x.isAfter(end);
  }
}

int _daysIn(int y, int m) => DateTime(y, m + 1, 0).day;

/// কোনো মাসে anchor তারিখ না থাকলে (যেমন ফেব্রুয়ারিতে ৩১) ওই মাসের শেষ তারিখ ধরা হয়।
DateTime _startOf(int y, int m, int anchor) {
  final base = DateTime(y, m, 1);
  final last = _daysIn(base.year, base.month);
  return DateTime(base.year, base.month, anchor > last ? last : anchor);
}

/// [now] যে মাসের (period) ভেতরে পড়ে, [offset] দিয়ে আগে/পরের মাসে যাওয়া যায় (-1 = আগের মাস)।
Period periodFor(DateTime now, int anchorDay, {int offset = 0}) {
  final today = DateTime(now.year, now.month, now.day);
  var base = DateTime(today.year, today.month, 1);
  if (today.isBefore(_startOf(base.year, base.month, anchorDay))) {
    base = DateTime(base.year, base.month - 1, 1);
  }
  base = DateTime(base.year, base.month + offset, 1);
  final start = _startOf(base.year, base.month, anchorDay);
  final next = DateTime(base.year, base.month + 1, 1);
  final nextStart = _startOf(next.year, next.month, anchorDay);
  final end = DateTime(nextStart.year, nextStart.month, nextStart.day - 1);
  return Period(start, end);
}
