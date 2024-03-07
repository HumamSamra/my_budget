import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_budget/pages/home.dart';

const boxName = 'Transactions';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(boxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'My Budget',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            fontFamily: 'Rubik',
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple, brightness: Brightness.dark),
            useMaterial3: false,
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            })),
        themeMode: ThemeMode.dark,
        home: const Homepage());
  }
}
