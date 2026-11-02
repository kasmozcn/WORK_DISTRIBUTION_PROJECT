import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/fake_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // VERİTABANI BAĞLANTISI BURADAN YAPILIR:
  // GorevRepository arayüzünü (lib/data/repository.dart) uygulayan gerçek
  // sınıf yazılınca FakeRepository() yerine o verilir. Ekranlara dokunmak
  // gerekmez.
  runApp(GorevAkisApp(repository: FakeRepository()));
}
