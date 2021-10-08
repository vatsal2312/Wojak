import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wojak_finance/screens/tabs/coinview.dart';
import 'package:wojak_finance/widgets/appdata.dart';

class LiquidationPage extends StatefulWidget {
  @override
  _LiquidationPageState createState() => _LiquidationPageState();
}

class _LiquidationPageState extends State<LiquidationPage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String jsonStringValues;
  var currencyList;

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future loadJsonData() async {
    jsonStringValues = await rootBundle.loadString('assets/currency.json');
    List mappedJson = json.decode(jsonStringValues);
    setState(() => currencyList = mappedJson);
    print("That's the JSON Data:- " + currencyList.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Icon(Icons.bar_chart, color: Colors.white),
        title: Text(
          "Liquidation",
          style: TextStyle(letterSpacing: 0.5),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: AppData.Bg),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: currencyList != null
              ? GridView.builder(
                  itemCount: currencyList.length,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: (1.6 / 1),
                  ),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return stateListView(
                      context,
                      color: Colors.white12,
                      image: currencyList[index]["logo"],
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CoinView(coin: currencyList[index])));
                      },
                      title: currencyList[index]["name"],
                      symbol: currencyList[index]["symbol"],
                    );
                  },
                )
              : Container(
                  margin: EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    color: AppData.Primary,
                    strokeWidth: 5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget stateListView(BuildContext context,
      {Color color,
      Function onTap,
      String title,
      String symbol,
      String image}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 30, right: 10, left: 10),
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 80,
                    child: Column(
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          symbol,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  color: Colors.white,
                  image: DecorationImage(image: AssetImage(image))),
              height: 50,
              width: 50,
            ),
          ],
        ),
      ),
    );
  }
}
