import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/splash_screen.dart';
import 'package:untitled1/model/ad_manager.dart';
import 'package:untitled1/style/style.dart';
import 'package:untitled1/vm/viewmodel.dart';
import 'db/database.dart';
import 'generated/l10n.dart';

// グローバルな初期化
late MyDatabase database;
AdManager adManager = AdManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await adManager.initAdmob();
  database = MyDatabase();

  runApp(
    ChangeNotifierProvider<ViewModel>(
        create: (context) => ViewModel(db: database),
        child: DevicePreview(
          enabled: false,
          builder: (context) => const MyApp(),
        )
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "バッグの中身",
      theme: ThemeData(fontFamily: MainFont, useMaterial3: false),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      // 起動時はスプラッシュ画面を表示
      home: const BagZoomSplash(),
      builder: DevicePreview.appBuilder,
      locale: DevicePreview.locale(context),
    );
  }
}