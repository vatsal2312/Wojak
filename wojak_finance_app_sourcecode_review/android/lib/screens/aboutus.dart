import 'package:flutter/material.dart';
import 'package:wojak_finance/widgets/appdata.dart';

class AboutPage extends StatefulWidget {
  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white)),
        title: Text(
          "About",
          style: TextStyle(letterSpacing: 0.5),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: AppData.Bg),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(5),
              child: Text(
                "Wojak is one of the most recognizable memic characters in the crypto world, named after the Polish word for soldier.",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(5),
              child: Text(
                "1% is the tax fee that we may use for burn events. Burning reduces the circulating supply and increases the value of the token.\n2% is the Wojak platform development fee, which will be used for improving the ecosystem. It may be utilized for various services like marketing campaigns, development costs, rewards, and so on.",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
