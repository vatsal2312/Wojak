import 'dart:convert';
import 'dart:ui';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:wojak_finance/widgets/appdata.dart';
import 'package:http/http.dart' as http;

class CoinView extends StatefulWidget {
  var coin;
  CoinView({this.coin});

  @override
  _CoinViewState createState() => _CoinViewState();
}

class _CoinViewState extends State<CoinView> {
  dynamic h1TotalVolUsd = 0.00;
  dynamic h4TotalVolUsd = 0.00;
  dynamic h12TotalVolUsd = 0.00;
  dynamic h24TotalVolUsd = 0.00;
  int index = 0;
  final fromDate = DateTime.now().subtract(Duration(hours: 24));
  final toDate = DateTime.now();
  List chartdata = [];
  String chatTime = "10";
  bool isClick = false;
  bool m15 = true;
  bool m30 = false;
  bool h4 = false;
  bool h12 = false;

  // var old;
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    loadJsonData();
    getOneMinutes(chatTime);
  }

  Future loadJsonData() async {
    String url =
        'https://fapi.bybt.com/api/futures/liquidation/info?timeType=$chatTime&symbol=${widget.coin['symbol']}';
    var response = await http.get(url);
    var data = json.decode(response.body);
    print("final price:  " + data.toString());
    print("final price:  " + data['data']['info']['symbol'].toString());
    setState(() {
      h1TotalVolUsd = data['data']['info']['h1TotalVolUsd'];
      h4TotalVolUsd = data['data']['info']['h4TotalVolUsd'];
      h12TotalVolUsd = data['data']['info']['h12TotalVolUsd'];
      h24TotalVolUsd = data['data']['info']['h24TotalVolUsd'];
    });
  }

  getOneMinutes(chatTime) async {
    String url =
        'https://fapi.bybt.com/api/futures/liquidation/chart?symbol=${widget.coin['symbol']}&timeType=$chatTime';
    var response = await http.get(Uri.parse(url));
    var model = json.decode(response.body)['data'];
    print('model---------------------------------------------$model');

    for (var item in model) {
      setState(() {
        var rate = (item['buyVolUsd']);
        String val = rate.toString();
        double rupe = double.parse(val);
        isClick = true;
        chartdata.add({
          "time": DateTime.fromMillisecondsSinceEpoch(item['createTime']),
          "rate": rupe,
        });
        print(
            'chartdata                                      ${chartdata.last}');
        print("                                 \n\n\n ");
      });
    }
    return model;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.white)),
        centerTitle: true,
        title: Text(widget.coin["name"]),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(gradient: AppData.linearGradient),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(widget.coin["logo"]),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Total Liquidations",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppData.Primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "${widget.coin['symbol']} 1H Rekt",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            h1TotalVolUsd > 1000000
                                ? "\$ ${(h1TotalVolUsd / 1000000).toStringAsFixed(2)} M"
                                : h1TotalVolUsd > 1000
                                    ? "\$ ${(h1TotalVolUsd / 1000).toStringAsFixed(2)} K"
                                    : "\$ ${h1TotalVolUsd.toStringAsFixed(2)}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "\$ ${h1TotalVolUsd.toStringAsFixed(3)}",
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppData.Primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "${widget.coin['symbol']} 4H Rekt",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            h4TotalVolUsd > 1000000
                                ? "\$ ${(h4TotalVolUsd / 1000000).toStringAsFixed(2)} M"
                                : h4TotalVolUsd > 1000
                                    ? "\$ ${(h4TotalVolUsd / 1000).toStringAsFixed(2)} K"
                                    : "\$ ${h4TotalVolUsd.toStringAsFixed(2)}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "\$ ${h4TotalVolUsd.toStringAsFixed(3)}",
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppData.Primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "${widget.coin['symbol']} 12H Rekt",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            h12TotalVolUsd > 1000000
                                ? "\$ ${(h12TotalVolUsd / 1000000).toStringAsFixed(2)} M"
                                : h12TotalVolUsd > 1000
                                    ? "\$ ${(h12TotalVolUsd / 1000).toStringAsFixed(2)} K"
                                    : "\$ ${h12TotalVolUsd.toStringAsFixed(2)}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "\$ ${h12TotalVolUsd.toStringAsFixed(3)}",
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppData.Primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "${widget.coin['symbol']} 24H Rekt",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            h24TotalVolUsd > 1000000
                                ? "\$ ${(h24TotalVolUsd / 1000000).toStringAsFixed(2)} M"
                                : h24TotalVolUsd > 1000
                                    ? "\$ ${(h24TotalVolUsd / 1000).toStringAsFixed(2)} K"
                                    : "\$ ${h24TotalVolUsd.toStringAsFixed(2)}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "\$ ${h24TotalVolUsd.toStringAsFixed(3)}",
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              isClick == false
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator())
                  : Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(5),
                      child: BezierChart(
                        bezierChartScale: BezierChartScale.HOURLY,
                        fromDate: fromDate,
                        toDate: toDate,
                        series: [
                          BezierLine(
                            lineColor: Colors.grey,
                            lineStrokeWidth: 1,
                            data: chartdata.map((value) {
                              return DataPoint<DateTime>(
                                  value: value['rate'], xAxis: value['time']);
                            }).toList(),
                          ),
                        ],
                        config: BezierChartConfig(
                            verticalIndicatorStrokeWidth: 1,
                            verticalIndicatorColor: Colors.grey,
                            verticalIndicatorFixedPosition: true,
                            bubbleIndicatorTitleStyle: TextStyle(fontSize: 15),
                            bubbleIndicatorValueStyle:
                                TextStyle(color: Colors.grey),
                            bubbleIndicatorLabelStyle: TextStyle(
                                color: Colors.black,
                                backgroundColor: Colors.black),
                            showVerticalIndicator: true,

                            // displayLinesXAxis: true,
                            displayYAxis: true,
                            stepsYAxis: 25000000,
                            yAxisTextStyle:
                                TextStyle(color: Colors.grey, fontSize: 7),
                            xAxisTextStyle:
                                TextStyle(color: Colors.grey, fontSize: 7),
                            // xLinesColor: Colors.red,
                            backgroundColor: Colors.transparent,
                            snap: false),
                      ),
                    ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isClick = false;
                        m15 = true;
                        m30 = false;
                        h4 = false;
                        h12 = false;
                      });
                      getOneMinutes("10");
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: m15 ? AppData.Bg : AppData.Primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "15M",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isClick = false;
                        m30 = true;
                        m15 = false;
                        h4 = false;
                        h12 = false;
                      });
                      getOneMinutes("11");
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: m30 ? AppData.Bg : AppData.Primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "30M",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isClick = false;
                        m15 = false;
                        m30 = false;
                        h4 = true;
                        h12 = false;
                      });
                      getOneMinutes("1");
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: h4 ? AppData.Bg : AppData.Primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "4H",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isClick = false;
                        m15 = false;
                        m30 = false;
                        h4 = false;
                        h12 = true;
                      });
                      getOneMinutes("4");
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: h12 ? AppData.Bg : AppData.Primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "12H",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
