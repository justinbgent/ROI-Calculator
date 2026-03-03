// Shared formatting helpers for the ROI calculator.

String formatCurrency(double value) {
  if (value.isNaN || value.isInfinite) return r'$0';
  final int v = value.round();
  final s = v.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}\$$buf';
}
