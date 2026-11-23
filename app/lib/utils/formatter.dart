/// Mengubah angka menjadi format Rupiah, contoh: 1200000 -> "Rp1.200.000"
String formatRupiah(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write('.');
  }
  return '${value < 0 ? '-' : ''}Rp$buffer';
}

/// "putri" -> "Putri"
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

/// 1.5 -> "1.5 km dari kampus"
String formatDistance(double? km) {
  if (km == null) return 'Jarak belum diketahui';
  return '${km.toStringAsFixed(1)} km dari kampus';
}