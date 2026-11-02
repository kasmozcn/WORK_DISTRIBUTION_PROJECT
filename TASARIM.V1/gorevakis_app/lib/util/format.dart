// Tarih ve saat metinleri. intl paketine gerek kalmasın diye elle yazıldı.

import '../data/models.dart';
import 'turkish.dart';

const monthsShort = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
const monthsLong = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];
const weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

String two(int n) => n.toString().padLeft(2, '0');

/// 17.00
String hhmm(DateTime d) => '${two(d.hour)}.${two(d.minute)}';

/// 3 Kas
String dayMonth(DateTime d) => '${d.day} ${monthsShort[d.month - 1]}';

/// Pazar, 1 Kasım
String longDate(DateTime d) => '${weekdays[d.weekday - 1]}, ${d.day} ${monthsLong[d.month - 1]}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Bugünden kaç gün sonra (geçmiş için eksi).
int daysFrom(DateTime day, DateTime now) {
  final diff = dateOnly(day).difference(dateOnly(now));
  return (diff.inHours / 24).round();
}

/// "bugün", "yarın", "Perşembe" (bir hafta içi) ya da "12 Kas".
String dayWord(DateTime day, DateTime now) {
  final d = daysFrom(day, now);
  if (d == 0) return 'bugün';
  if (d == 1) return 'yarın';
  if (d == -1) return 'dün';
  if (d > 1 && d < 7) return weekdays[day.weekday - 1];
  return dayMonth(day);
}

/// Bildirim ve yorumların zamanı: bugün ise saat, değilse gün.
String stamp(DateTime t, DateTime now) {
  final d = daysFrom(t, now);
  if (d == 0) return hhmm(t);
  if (d == -1) return 'Dün';
  if (d < 0 && d > -7) return weekdays[t.weekday - 1];
  return dayMonth(t);
}

enum DueTone { normal, soon, overdue }

class DueLabel {
  const DueLabel(this.text, this.tone);
  final String text;
  final DueTone tone;
}

/// İş kartındaki son tarih etiketi.
/// Bitmiş işlerde gecikme gösterilmez.
DueLabel? dueLabelFor(Task task, {required bool done, DateTime? now}) {
  final due = task.dueAt;
  if (due == null) return null;
  final n = now ?? DateTime.now();
  final d = daysFrom(due, n);
  final time = task.dueHasTime ? hhmm(due) : null;
  if (!done) {
    if (d < 0) return DueLabel('${-d} gün gecikti', DueTone.overdue);
    if (d == 0 && task.dueHasTime && due.isBefore(n)) {
      return const DueLabel('Gecikti', DueTone.overdue);
    }
    if (d == 0) return DueLabel(time == null ? 'Bugün' : 'Bugün $time', DueTone.soon);
    if (d == 1) return DueLabel(time == null ? 'Yarın' : 'Yarın $time', DueTone.soon);
  }
  final base = dayMonth(due);
  return DueLabel(time == null ? base : '$base, $time', DueTone.normal);
}

bool isOverdue(Task task, {required bool done, DateTime? now}) {
  return dueLabelFor(task, done: done, now: now)?.tone == DueTone.overdue;
}

/// "Perşembe 17.00", "yarın 12.00", "12 Kas"
String dueShort(Task task, DateTime now) {
  final due = task.dueAt;
  if (due == null) return '';
  final w = dayWord(due, now);
  return task.dueHasTime ? '$w ${hhmm(due)}' : w;
}

/// İş detayındaki tam tarih: "Salı, 27 Ekim · 12.00"
String dueLong(Task task) {
  final due = task.dueAt;
  if (due == null) return 'Yok';
  final base = longDate(due);
  return task.dueHasTime ? '$base · ${hhmm(due)}' : base;
}

/// Ana sayfadaki büyük başlık.
String waitingHeadline(int count) {
  if (count == 0) return 'Bugün sende\naçık iş yok.';
  return '$count iş seni\nbekliyor.';
}

/// Başlığın altındaki cümle: "Biri yarın 12.00'de, diğeri Perşembe teslim."
/// [tasks] son tarihe göre sıralı, kişinin açık işleri olmalı.
String waitingSentence(List<Task> tasks, DateTime now) {
  if (tasks.isEmpty) return 'Yeni bir iş gelince burada göreceksin.';
  final overdue = tasks.where((t) => isOverdue(t, done: false, now: now)).length;
  if (overdue > 0) {
    if (tasks.length == 1) return 'Son tarihi geçti, önce ona bak.';
    if (overdue == 1) return 'Biri gecikmiş, önce ona bak.';
    return '$overdue tanesi gecikmiş, önce onlara bak.';
  }
  final dated = tasks.where((t) => t.dueAt != null).toList();
  if (dated.isEmpty) return 'Hiçbirinin son tarihi yok.';

  String when(Task t, {required bool withTime}) {
    final due = t.dueAt!;
    final w = dayWord(due, now);
    if (withTime && t.dueHasTime) return '$w ${timeWithLocative(due.hour, due.minute)}';
    return w;
  }

  if (dated.length == 1) return '${trCapitalize(when(dated.first, withTime: true))} teslim.';
  if (tasks.length == 2 && dated.length == 2) {
    return 'Biri ${when(dated[0], withTime: true)}, diğeri ${when(dated[1], withTime: false)} teslim.';
  }
  return 'En yakını ${when(dated.first, withTime: true)} teslim.';
}

/// Proje kartındaki sayı metni için sütun adının kısa hâli.
String columnShortName(String name) {
  switch (name) {
    case 'Yapılacak':
      return 'yapılacak';
    case 'Devam Ediyor':
      return 'devam';
    case 'Tamamlandı':
      return 'bitti';
  }
  return trLower(name);
}
