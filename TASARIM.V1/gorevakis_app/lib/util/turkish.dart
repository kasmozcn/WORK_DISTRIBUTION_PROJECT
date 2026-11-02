// Türkçeye özgü küçük yardımcılar.
//
// Dart'ın toLowerCase/toUpperCase fonksiyonları I/ı ve İ/i harflerini
// Türkçe kurala göre çevirmez; arama ve baş harfler için bunları kullanıyoruz.

/// Türkçe küçük harfe çevirir. Uzunluğu korur (arama vurgusu için önemli).
String trLower(String s) {
  final b = StringBuffer();
  for (final ch in s.split('')) {
    if (ch == 'I') {
      b.write('ı');
    } else if (ch == 'İ') {
      b.write('i');
    } else {
      final lower = ch.toLowerCase();
      b.write(lower.length == ch.length ? lower : ch);
    }
  }
  return b.toString();
}

/// Türkçe büyük harfe çevirir.
String trUpper(String s) {
  final b = StringBuffer();
  for (final ch in s.split('')) {
    if (ch == 'i') {
      b.write('İ');
    } else if (ch == 'ı') {
      b.write('I');
    } else {
      b.write(ch.toUpperCase());
    }
  }
  return b.toString();
}

/// İlk harfi büyütür: "yarın" -> "Yarın".
String trCapitalize(String s) {
  if (s.isEmpty) return s;
  return trUpper(s.substring(0, 1)) + s.substring(1);
}

/// Saat sonuna bulunma eki getirir: 12.00 -> "12.00'de", 09.00 -> "09.00'da".
///
/// Ek, okunuştaki son kelimeye göre seçilir (on ikide, dokuzda, on üçte...).
String timeWithLocative(int hour, int minute) {
  final text = '${_two(hour)}.${_two(minute)}';
  final spoken = minute == 0 ? hour : minute;
  return "$text'${_locativeSuffix(spoken)}";
}

String _locativeSuffix(int n) {
  if (n == 0) return 'da'; // sıfırda
  const ones = {1: 'de', 2: 'de', 3: 'te', 4: 'te', 5: 'te', 6: 'da', 7: 'de', 8: 'de', 9: 'da'};
  const tens = {1: 'da', 2: 'de', 3: 'da', 4: 'ta', 5: 'de'};
  final o = n % 10;
  if (o != 0) return ones[o]!;
  return tens[n ~/ 10] ?? 'de';
}

String _two(int n) => n.toString().padLeft(2, '0');
