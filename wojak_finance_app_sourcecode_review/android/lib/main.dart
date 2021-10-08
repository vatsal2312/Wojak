import 'package:flutter/material.dart';
import 'package:wojak_finance/screens/splash.dart';
import 'package:wojak_finance/widgets/appdata.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wojak Finance',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: "Quicksand",
        brightness: Brightness.dark,
        canvasColor: Color(0xFF111111),
        appBarTheme: AppBarTheme(
          backgroundColor: AppData.Bg,
          brightness: Brightness.dark,
          iconTheme: IconThemeData(color: Colors.white),
          textTheme: TextTheme(
              subtitle1: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ),
      ),
      themeMode: ThemeMode.dark,
      home: Splash(),
    );
  }
}
