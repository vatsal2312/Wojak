import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wojak_finance/screens/tabs/feed.dart';
import 'package:wojak_finance/screens/tabs/home.dart';
import 'package:wojak_finance/screens/tabs/options.dart';
import 'package:wojak_finance/screens/tabs/liquidation.dart';
import 'package:wojak_finance/widgets/appdata.dart';

class BottomBarPage extends StatefulWidget {
  @override
  _BottomBarPageState createState() => _BottomBarPageState();
}

class _BottomBarPageState extends State<BottomBarPage> {
  bool isLoading = false;
  String type;

  int currentIndex = 0;
  final List<Widget> bottombarItem = [
    HomePage(),
    FeedPage(),
    LiquidationPage(),
    OptionsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppData.Bg,
      body: bottombarItem[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Colors.white24,
              )
            ]),
        child: ClipRRect(
          child: BottomNavigationBar(
            elevation: 20,
            backgroundColor: AppData.Bg,
            currentIndex: currentIndex,
            selectedFontSize: 12,
            unselectedFontSize: 10,
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: Colors.white54,
            showUnselectedLabels: false,
            showSelectedLabels: false,
            unselectedLabelStyle: TextStyle(),
            onTap: (i) => setState(() => currentIndex = i),
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            items: [
              BottomNavigationBarItem(
                label: 'Home',
                icon: Icon(Icons.home, size: 30, color: Colors.white54),
                activeIcon: activeIcon(Icons.home),
              ),
              BottomNavigationBarItem(
                label: 'Wojak Feed',
                icon: Icon(Icons.web, size: 30, color: Colors.white54),
                activeIcon: activeIcon(Icons.web),
              ),
              BottomNavigationBarItem(
                label: 'Liquidation',
                icon: Icon(Icons.bar_chart, size: 30, color: Colors.white54),
                activeIcon: activeIcon(Icons.bar_chart),
              ),
              BottomNavigationBarItem(
                label: 'Options',
                icon: Icon(Icons.person, size: 30, color: Colors.white54),
                activeIcon: activeIcon(Icons.person),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget activeIcon(IconData icon) {
  return Column(
    children: [
      Icon(
        icon,
        size: 30,
        color: AppData.Primary,
      ),
      Icon(
        Icons.circle,
        size: 8,
        color: AppData.Primary,
      ),
    ],
  );
}
