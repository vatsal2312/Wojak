import 'package:flutter/material.dart';
import 'package:wojak_finance/widgets/appdata.dart';
import 'package:wojak_finance/widgets/widget.dart';

class Reward extends StatefulWidget {
  @override
  _RewardState createState() => _RewardState();
}

class _RewardState extends State<Reward> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppData.linearGradient),
        child: Column(
          children: [
            statusBar(context),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(35),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.clear,
                            size: 40,
                            color: AppData.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    Text(
                      'HOW DOES IT WORK ?',
                      style: TextStyle(
                          color: AppData.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                    SizedBox(height: 15),
                    iconDetails(
                        image: 'assets/images/gift-box.png',
                        detail:
                            'WOJ REWARDS ITS HOLDERS WITH A 1% TAX ON EACH TRANSACTION.'),
                    iconDetails(
                        image: 'assets/images/fire.png',
                        detail:
                            'EACH TRANSACTION TRIGGERS A BURN RATE OF 1% WHICH DECREASES THE SUPPLY OVERTIME.'),
                    iconDetails(
                        image: 'assets/images/lock.png',
                        detail:
                            'WOJ IS FULLY DECENTRALISED THERE ARE NO OWNER DECISIONS ARE MADE BY YOU.'),
                    iconDetails(
                        image: 'assets/images/increase.png',
                        detail:
                            'AS THE SUPPLY DECREASES THE SCARCITY INCREASES NO BURNING LIMIT MEANS MORE FUN.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container iconDetails({String image, String detail}) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Image.asset(
              image,
              height: 75,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            flex: 9,
            child: Text(
              detail,
              maxLines: 5,
              style: TextStyle(color: AppData.white, fontSize: 12, height: 2),
            ),
          ),
        ],
      ),
    );
  }
}
