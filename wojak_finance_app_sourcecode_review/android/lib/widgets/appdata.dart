import 'package:flutter/material.dart';

class AppData {
  static const Color Primary = Color(0xffff827c);
  static const Color PrimaryDark = Color(0xfff95951);
  static const Color PrimaryAssent = Color(0xff93c9eb);
  static const Color Bg = Color(0xff290050);
  static const Color BgDark = Color(0xff020207);
  static const Color white = Color(0xffffffff);

  static const Color light = Color(0x73000000);
  static const Color green = Color(0xff4CAF50);
  static const Color red = Color(0xffF44336);
  static const Color blue = Color(0xff122569);
  static const Color blueAssent = Color(0xff13253d);
  //
  static const LinearGradient linearGradient = LinearGradient(
    colors: [Bg, BgDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient linearButton = LinearGradient(
    colors: [Primary, PrimaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static String getBalance =
      'https://api.bscscan.com/api?module=account&action=tokenbalance&';
  static String getMarketCap =
      'https://api.coingecko.com/api/v3/simple/price?ids=tardigrades-finance&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true&include_last_updated_at=true';
  static String getPrice = 'https://api.pancakeswap.info/api/tokens/';
}

class Assets {
  static const String simple_bg = "assets/images/simple_bg.png";
  static const String main_bg = "assets/images/main_bg.png";
  static const String logo = "assets/images/logo.png";
  static const String question = "assets/images/question.png";
  static const String slider = "assets/images/slider.png";
  static const String Twitter = "assets/images/twitter.png";
  static const String Telegram = "assets/images/telegram.png";
  static const String Medium = "assets/images/medium.png";
  static const String Discord = "assets/images/discord.png";
  static const String Instagram = "assets/images/Instagram.png";
  static const String Youtube = "assets/images/youtube.png";
  static const String Facebook = "assets/images/facebook.png";
  static const String Github = "assets/images/github.png";
  static const String Reddit = "assets/images/reddit.png";
}
