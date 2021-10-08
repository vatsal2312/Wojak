import 'package:flutter/material.dart';
import 'package:wojak_finance/screens/aboutus.dart';
import 'package:wojak_finance/widgets/appdata.dart';
import 'package:wojak_finance/widgets/widget.dart';

class OptionsPage extends StatefulWidget {
  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String twitter = "https://twitter.com/wojfinance";
  String telegram = "https://t.me/wojtoken";
  String medium = "https://wojakfinance.medium.com/";
  String discord = "https://discord.com/invite/9gg9jhVP";
  String instagram = "https://www.instagram.com/wojtoken/";
  String youtube = "https://www.youtube.com/c/wojtoken";
  String facebook =
      "https://www.facebook.com/people/Woj-Token/100070044607209/";
  String github = "https://woj.finance/";
  String reddit = "https://woj.finance/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Icon(Icons.person, color: Colors.white),
        title: Text(
          "Options",
          style: TextStyle(letterSpacing: 0.5),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: AppData.Bg),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Help",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppData.Primary),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white10,
                  ),
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.support_agent),
                      SizedBox(width: 5),
                      Text("Help & Support"),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AboutPage()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white10,
                  ),
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(5),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 5),
                        Text("About"),
                      ]),
                ),
              ),
              SizedBox(height: 50),
              Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Our Social Media",
                    style: TextStyle(color: Colors.white38),
                  )),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        launchUrl(discord);
                      },
                      icon: Image.asset(
                        Assets.Discord,
                        height: 25,
                        width: 25,
                      )),
                  IconButton(
                      onPressed: () {
                        launchUrl(facebook);
                      },
                      icon: Image.asset(
                        Assets.Facebook,
                        height: 25,
                        width: 25,
                      )),
                  IconButton(
                      onPressed: () {
                        launchUrl(github);
                      },
                      icon: Image.asset(
                        Assets.Github,
                        height: 25,
                        width: 25,
                      )),
                  IconButton(
                      onPressed: () {
                        launchUrl(instagram);
                      },
                      icon: Image.asset(
                        Assets.Instagram,
                        height: 25,
                        width: 25,
                      )),
                  IconButton(
                      onPressed: () {
                        launchUrl(medium);
                      },
                      icon: Image.asset(
                        Assets.Medium,
                        height: 25,
                        width: 25,
                      )),
                  IconButton(
                      onPressed: () {
                        launchUrl(reddit);
                      },
                      icon: Image.asset(
                        Assets.Reddit,
                        height: 25,
                        width: 25,
                      )),
                  IconButton(
                      onPressed: () {
                        launchUrl(telegram);
                      },
                      icon: Image.asset(
                        Assets.Telegram,
                        height: 25,
                        width: 25,
                      )),
                  IconButton(
                      onPressed: () {
                        launchUrl(twitter);
                      },
                      icon: Image.asset(
                        Assets.Twitter,
                        height: 25,
                        width: 25,
                      )),
                  IconButton(
                      onPressed: () {
                        launchUrl(youtube);
                      },
                      icon: Image.asset(
                        Assets.Youtube,
                        height: 25,
                        width: 25,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
