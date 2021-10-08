import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wojak_finance/models/wallet_database.dart';
import 'package:wojak_finance/screens/bottombar.dart';
import 'package:wojak_finance/widgets/appdata.dart';
import 'package:wojak_finance/widgets/widget.dart';
import '../reward.dart';
import '../scan.dart';

class HomePage extends StatefulWidget {
  final String type;
  final int id;
  final String address;
  final String balance;
  HomePage({this.type, this.id, this.address, this.balance});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final DbWalletManager dbmanager = new DbWalletManager();
  TextEditingController name = TextEditingController();
  TextEditingController rewardController = TextEditingController();
  String contractAddress = "0x8b766d9f9322d7ecf4c1c3a450096a2b19bc1d58";
  String totalAddress = "0x000000000000000000000000000000000000dead";
  String address = "";
  String rewardDays = "1000";
  String apiKey = "6V8CK9QKFPU136DVAPF61SJH93PXPYIK43";
  final value = NumberFormat("#,##0.000", "en_US");
  final val = NumberFormat("#,##0.0000000000", "en_US");
  final priceValue = NumberFormat("#,##0.000000000000000", "en_US");
  String toLaunch = 'https://www.coingecko.com/en/coins/tardigrades-finance';
  Wallet _wallet;
  int btnwalletid;
  List<Wallet> walletList;
  int updateIndex;
  double balance = 0.0;
  double totalBalance = 0.0;
  double oldBalance = 0.0;
  double reward = 0.0;
  double finalReward = 0.0;
  double marketCap = 0.0;
  double hoursVal = 0.0;
  var price = "0.0";
  double dollarValue = 0.0;
  Timer _getBalanceTimer;
  double currentBalance = 0.0;
  int index = 0;
  bool isClick = true;

  @override
  void initState() {
    super.initState();
    getBalance();
    getTotalBalance();
    getMarketCap();
    getPrice();
    widget.type == "0" ? getWallet() : null;
    rewardController.text = rewardDays;
  }

  Future getBalance() async {
    String url =
        '${AppData.getBalance}contractaddress=$contractAddress&address=$address&tag=latest&apikey=$apiKey';
    var response = await http.post(url);
    var data = json.decode(response.body);
    setState(() {
      balance = (double.parse(data['result'])) / 1000000000;
    });
    return balance;
  }

  Future getPrice() async {
    String url = '${AppData.getPrice}$contractAddress';
    var response = await http.get(url);
    var data = json.decode(response.body);
    print("final price:  " + data['data']['price'].toString());
    setState(() {
      price = data['data']['price'];
      print("final price  old :  " + price.toString());
    });
  }

  Future getMarketCap() async {
    String url = '${AppData.getMarketCap}';
    var response = await http.get(url);
    var data = json.decode(response.body);
    print('market Cap   :  ' +
        data['tardigrades-finance']['usd_market_cap'].toString());
    setState(() {
      marketCap = data['tardigrades-finance']['usd_market_cap'];
      hoursVal = data['tardigrades-finance']['usd_24h_vol'];
    });
    print("24 vol     : " + hoursVal.toString());
  }

  Future getTotalBalance() async {
    String url =
        '${AppData.getBalance}contractaddress=$contractAddress&address=$totalAddress&tag=latest&apikey=$apiKey';
    var response = await http.post(url);
    var data = json.decode(response.body);
    setState(() {
      totalBalance = (double.parse(data['result'])) / 1000000000;
      print("jemstotal:  " + totalBalance.toString());
    });
    return totalBalance;
  }

  Future getWallet() async {
    setState(() {
      btnwalletid = widget.id;
      address = widget.address;
    });
    _getBalanceTimer?.cancel();
    dbmanager.getWalletList();
    oldBalance = 0.0;
    oldBalance = double.parse(widget.balance);
    getBalance().then((value) {
      print("oldBalance: $oldBalance");
      print("value: $value");
      setState(() {
        if (oldBalance != 0.0) {
          reward = value - oldBalance;
          finalReward = reward * int.parse(rewardController.text);
          dollarValue = balance * double.parse(price);
          // rewardController.text = '+$reward';
        }
      });
    });
    _getBalanceTimer = Timer.periodic(
        Duration(seconds: 10),
        (Timer t) => getBalance().then((value) {
              oldBalance = double.parse(widget.balance);
              print("oldBalance 1: $oldBalance");
              print("value 1: $value");
              // String val = ((value.toString()) - (oldBalance.toString()));
              setState(() {
                reward = value - oldBalance;
                finalReward = reward * int.parse(rewardController.text);
                dollarValue = balance * double.parse(price);
                getTotalBalance();
                getMarketCap();
                getPrice();
              });
              print('final :  ${finalReward.toString()}');
            }));
  }

  @override
  void dispose() {
    _getBalanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppData.primaryAssent,
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          "WOJ Tokens",
          style: TextStyle(letterSpacing: 0.5),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.asset(Assets.logo),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppData.linearGradient),
        child: Column(
          // alignment: Alignment.topCenter,
          children: [
            wallet(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    mainContainer(
                      context,
                      childField: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                titleContainer(name: 'DASHBOARD'),
                                SizedBox(height: 10),
                                subTitleContainer(name: 'WOJAK BALANCE'),
                                SizedBox(height: 5),
                                subValueContainer(
                                    value: '${value.format(balance)}' ?? ""),
                                SizedBox(height: 15),
                                subTitleContainer(
                                    name: 'REWARD SINCE LAST BUY/SELL'),
                                SizedBox(height: 5),
                                subValueContainer(
                                    value: '+${value.format(reward)}' ?? "",
                                    color: AppData.Primary),
                                SizedBox(height: 15),
                                subTitleContainer(name: 'DOLLAR VALUE'),
                                SizedBox(height: 5),
                                subValueContainer(
                                    value:
                                        '\$ ${val.format(dollarValue).toString()}'),
                                SizedBox(height: 15),
                                subTitleContainer(name: 'TOKEN BURNT'),
                                SizedBox(height: 5),
                                subValueContainer(
                                    value:
                                        '${value.format(totalBalance)}' ?? ""),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: floatBtnContainer(
                              tag: 'scan',
                              childField: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 30,
                              ),
                              onTab: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ScaningPage()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    mainContainer(
                      context,
                      childField: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleContainer(name: 'MARKET INFORMATION'),
                          SizedBox(height: 10),
                          subTitleContainer(name: 'MARKET CAP'),
                          SizedBox(height: 5),
                          subValueContainer(
                              value: '\$ ${marketCap.toString()}'),
                          SizedBox(height: 15),
                          subTitleContainer(name: '24 HOUR VOLUME'),
                          SizedBox(height: 5),
                          subValueContainer(
                              value: '\$ ${val.format(hoursVal).toString()}'),
                          SizedBox(height: 15),
                          subTitleContainer(name: 'CURRENT WOJ PRICE'),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              subValueContainer(
                                  value:
                                      '\$ ${priceValue.format(double.parse(price))}'),
                              Icon(
                                Icons.arrow_upward_rounded,
                                size: 20,
                                color: AppData.Primary,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    mainContainer(
                      context,
                      childField: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              titleContainer(name: 'REWARDS'),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  subTitleContainer(name: 'IN  '),
                                  InkWell(
                                    onTap: () {
                                      openRewardBox();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppData.Primary,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: subValueContainer(
                                        value: "$rewardDays",
                                        color: AppData.white,
                                      ),
                                    ),
                                  ),
                                  subTitleContainer(
                                      name: '  DAYS YOU WILL HAVE EARNED'),
                                ],
                              ),
                              SizedBox(height: 5),
                              subValueContainer(
                                  value: "", color: AppData.green),
                              SizedBox(height: 25),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  titleContainer(
                                      name: 'AND THAT, JUST BY ',
                                      size: 12,
                                      spacing: 0),
                                  titleContainer(
                                      name: 'HOLDING.', size: 20, spacing: 0),
                                ],
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: floatBtnContainer(
                                tag: 'reward',
                                childField:
                                    Image.asset(Assets.question, width: 25),
                                onTab: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Reward()));
                                }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget wallet() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: AppData.Bg,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: Container(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ScaningPage()));
                        },
                        child: Container(
                          height: 33,
                          width: 33,
                          decoration: BoxDecoration(
                              color: AppData.Primary,
                              borderRadius: BorderRadius.circular(6)),
                          child: Icon(Icons.add, color: Colors.white, size: 23),
                        ),
                      ),
                      SizedBox(width: 3),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: FutureBuilder(
                            future: dbmanager.getWalletList(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                walletList = snapshot.data;
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: walletList == null
                                      ? 0
                                      : walletList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Wallet walletm = walletList[index];
                                    return InkWell(
                                      onLongPress: () {
                                        name.text = walletm.name;
                                        _wallet = walletm;
                                        updateIndex = index;
                                        openAlertBox(walletm, index);
                                      },
                                      onTap: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        setState(() {
                                          btnwalletid = walletm.id;
                                          address = walletm.walletAddress;
                                        });
                                        _getBalanceTimer?.cancel();

                                        oldBalance = 0.0;
                                        oldBalance =
                                            double.parse(walletm.balance);
                                        getBalance().then((value) {
                                          print("oldBalance: $oldBalance");
                                          print("value: $value");
                                          setState(() {
                                            if (oldBalance != 0.0) {
                                              reward = value - oldBalance;
                                              finalReward = reward *
                                                  int.parse(
                                                      rewardController.text);
                                              dollarValue =
                                                  balance * double.parse(price);
                                            }
                                          });
                                        });
                                      },
                                      child: Container(
                                        height: 33,
                                        margin: EdgeInsets.all(5),
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: Colors.white30,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Text(
                                          '${walletm.name}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: (walletm.id == btnwalletid)
                                                ? AppData.Primary
                                                : Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                // print('hello');
                                return Text(
                                  'No Wallets',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                );
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  child: Row(
                    children: [
                      Text('WOJ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  openAlertBox(walletm, index) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppData.Bg,
            title: Text(
              'Update Wallet Name',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppData.white, fontSize: 16),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            // title: Text('Update'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  addScanProperty(
                      txt: 'Change Name',
                      controller: name,
                      hinttxt: 'Wallet Name',
                      radius: 12),
                  QrImage(
                    data: walletm.walletAddress ?? '',
                    version: QrVersions.auto,
                    size: 125.0,
                    foregroundColor: Colors.white,
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    alignment: Alignment.center,
                    child: Text(
                      'Wallet Address',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white54),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.55,
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          walletm.walletAddress,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.white),
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(
                                text: walletm.walletAddress ?? ''));
                            showTextMsg(context,
                                msg: 'Copy', color: AppData.Primary);
                          },
                          child: Icon(
                            Icons.copy_rounded,
                            color: AppData.white,
                            size: 20,
                          )),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      newButton(
                        title: 'Confirm',
                        onPressed: () {
                          if (name.text.isNotEmpty) {
                            Navigator.of(context).pop();
                            _wallet.name = name.text;
                            dbmanager.updateWallet(_wallet).then((id) => {
                                  setState(() {
                                    walletList[updateIndex].name = name.text;
                                  }),
                                  name.clear(),
                                  _wallet = null,
                                });
                            showTextMsg(context,
                                msg: 'Successfully Updated',
                                color: AppData.Primary);
                            print("jems: " + name.text);
                          } else {
                            showTextMsg(context,
                                msg: 'Fill required Detail',
                                color: AppData.red);
                          }
                        },
                      ),
                      SizedBox(width: 20),
                      newButton(
                        title: 'Delete',
                        onPressed: () {
                          openDeleteBox(walletm, index);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  openDeleteBox(walletm, index) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppData.Bg,
            title: Text(
              'Confirm',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppData.Primary),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Are you sure you want to delete your wallet',
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      newButton(
                        title: 'No',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 20),
                      newButton(
                        title: 'Yes',
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BottomBarPage()));
                          dbmanager.deleteWallet(walletm.id);
                          setState(() {
                            walletList.removeAt(index);
                          });
                          showTextMsg(context,
                              msg: 'Successfully Delete',
                              color: AppData.Primary);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  openRewardBox() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppData.Bg,
            title: Text(
              'Update Reward Days',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppData.white, fontSize: 16),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            // title: Text('Update'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  addScanProperty(
                      txt: 'Change Days',
                      controller: rewardController,
                      hinttxt: 'Days',
                      keyboard: TextInputType.number,
                      radius: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      newButton(
                        title: 'No',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 20),
                      newButton(
                        title: 'Yes',
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            if (int.parse(rewardController.text) <= 1000) {
                              rewardDays = rewardController.text;
                              finalReward = reward * int.parse(rewardDays);
                              print("final value:  " + finalReward.toString());
                              Navigator.pop(context);
                            } else {
                              rewardController.text = rewardDays;
                              showTextMsg(context,
                                  msg: 'Please Write less then 1000 Number',
                                  color: AppData.red);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  save(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
}
