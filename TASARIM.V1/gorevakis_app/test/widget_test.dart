import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gorevakis/app.dart';
import 'package:gorevakis/data/fake_repository.dart';
import 'package:gorevakis/data/models.dart';
import 'package:gorevakis/util/format.dart';
import 'package:gorevakis/util/turkish.dart';

void phoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('Giriş ekranı açılır, deneme hesabıyla girilir', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(GorevAkisApp(repository: FakeRepository()));
    expect(find.text('Tekrar hoş geldin'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'y3@ahsatech.test');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('Giriş yap'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Projelerin'), findsOneWidget);
    expect(find.text('Destek ve Bakım'), findsOneWidget);
  });

  testWidgets('Hatalı şifrede uyarı çıkar', (tester) async {
    phoneSize(tester);
    await tester.pumpWidget(GorevAkisApp(repository: FakeRepository()));
    await tester.enterText(find.byType(TextField).at(0), 'y3@ahsatech.test');
    await tester.enterText(find.byType(TextField).at(1), 'yanlis');
    await tester.tap(find.text('Giriş yap'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('E-posta ya da şifre hatalı.'), findsOneWidget);
  });

  test('Türkçe küçük harf ve saat ekleri', () {
    expect(trLower('YEDEKLEME İŞİ'), 'yedekleme işi');
    expect(trLower('IŞIK'), 'ışık');
    expect(timeWithLocative(12, 0), "12.00'de");
    expect(timeWithLocative(9, 0), "09.00'da");
    expect(timeWithLocative(17, 30), "17.30'da");
  });

  test('Son tarih etiketi', () {
    final now = DateTime(2026, 11, 2, 10);
    Task task(DateTime due, {bool time = false}) => Task(
          id: 'x',
          projectId: 'p',
          title: 'Deneme',
          columnId: 'c',
          createdBy: 'u',
          createdAt: now,
          dueAt: due,
          dueHasTime: time,
        );

    expect(dueLabelFor(task(DateTime(2026, 10, 31)), done: false, now: now)?.text, '2 gün gecikti');
    expect(dueLabelFor(task(DateTime(2026, 11, 3, 12), time: true), done: false, now: now)?.text, 'Yarın 12.00');
    expect(dueLabelFor(task(DateTime(2026, 11, 5)), done: false, now: now)?.text, '5 Kas');
    expect(dueLabelFor(task(DateTime(2026, 10, 31)), done: true, now: now)?.tone, DueTone.normal);
  });
}
