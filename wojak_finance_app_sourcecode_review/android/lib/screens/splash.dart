import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wojak_finance/screens/bottombar.dart';
import 'package:wojak_finance/widgets/appdata.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => BottomBarPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(Assets.main_bg),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter),
            gradient: AppData.linearGradient),
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                  width: 150,
                ),
                SizedBox(height: 5),
                Text(
                  'Wojak Finance',
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
