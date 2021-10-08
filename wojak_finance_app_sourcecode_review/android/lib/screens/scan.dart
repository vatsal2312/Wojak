import 'dart:async';
import 'dart:convert';
import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:wojak_finance/models/wallet_database.dart';
import 'package:wojak_finance/screens/bottombar.dart';
import 'package:wojak_finance/widgets/appdata.dart';
import 'package:wojak_finance/widgets/widget.dart';

class ScaningPage extends StatefulWidget {
  final String walletAdd;
  final String name;

  const ScaningPage({this.walletAdd, this.name});
  @override
  _ScaningPageState createState() => _ScaningPageState();
}

class _ScaningPageState extends State<ScaningPage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();
  final DbWalletManager dbmanager = new DbWalletManager();
  TextEditingController reciverController = TextEditingController();
  TextEditingController name = TextEditingController();
  String contractAddress = "0x8b766d9f9322d7ecf4c1c3a450096a2b19bc1d58";
  String apiKey = "6V8CK9QKFPU136DVAPF61SJH93PXPYIK43";
  TextEditingController walletAddress = TextEditingController();
  String barcode = "Scan The Barcode!";
  Wallet _wallet;
  String balance = '';
  String type = '0';
  bool _isButtonDisabled = false;
  List<Wallet> walletList;

  @override
  void initState() {
    super.initState();
    walletAddress.text = widget.walletAdd;
    name.text = widget.name;
  }

  Future getBalance() async {
    String url =
        'https://api.bscscan.com/api?module=account&action=tokenbalance&contractaddress=$contractAddress&address=${walletAddress.text}&tag=latest&apikey=$apiKey';
    var response = await http.post(url);
    var data = json.decode(response.body);
    setState(() {
      balance = ((double.parse(data['result'])) / 1000000000).toString();
    });
    return balance;
  }

  Future _query() async {
    Database db = await openDatabase("ss.db");
    List<Map> result = await db.rawQuery(
        'SELECT * FROM wallet WHERE walletAddress LIKE ?',
        ['${walletAddress.text}']);
    print("final value :     " + result.toString());
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        decoration: BoxDecoration(gradient: AppData.linearGradient),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              statusBar(context),
              customAppBar(
                  title: 'Create Wallet',
                  onTab: () {
                    Navigator.pop(context);
                  },
                  icon: Icons.menu),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    addScanProperty(
                        txt: 'Wallet name',
                        controller: name,
                        hinttxt: 'Enter wallet name',
                        radius: 25),
                    addScanProperty(
                        txt: 'Wallet address',
                        controller: walletAddress,
                        hinttxt: 'Enter wallet address',
                        suffixicon: Icons.qr_code_scanner_rounded,
                        radius: 25,
                        onTap: scan),
                    SizedBox(height: 30),
                    newButton(
                      title: 'Confirm',
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (name.text.isNotEmpty &&
                            walletAddress.text.isNotEmpty) {
                          if (walletAddress.text.length == 42) {
                            _query().then((value) {
                              print('value : ' + value.length.toString());

                              if (value.length == 0) {
                                _isButtonDisabled != true
                                    ? getBalance().then((value) {
                                        print("final " + value.toString());
                                        submitwallet(context, value);
                                      })
                                    : null;
                                setState(() {
                                  _isButtonDisabled = true;
                                  print("===========" +
                                      _isButtonDisabled.toString());
                                });
                                showTextMsg(context,
                                    msg: 'Successfully Created',
                                    color: AppData.Primary);
                              } else {
                                showTextMsg(context,
                                    msg:
                                        'This address already exist, Please add another.',
                                    color: AppData.red);
                              }
                            });
                          } else {
                            showTextMsg(context,
                                msg:
                                    'InValid Address, Please check your address',
                                color: AppData.red);
                          }
                        } else {
                          showTextMsg(context,
                              msg: 'Fill all required Details',
                              color: AppData.red);
                        }
                        // print('value : ' +)
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitwallet(BuildContext context, value) {
    if (_formKey.currentState.validate()) {
      if (_wallet == null) {
        // print('jems:' + value);
        Wallet nWallet = new Wallet(
          name: name.text,
          walletAddress: walletAddress.text,
          balance: balance,
        );
        dbmanager.insertWallet(nWallet).then((id) => {
              print('wallet Added to Db ${name.text}'),
              print('wallet Added to Db $balance'),
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => BottomBarPage())),
            });
      }
    }
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      print('======-=========$barcode');
      setState(() {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ScaningPage(walletAdd: barcode, name: name.text)));
        walletAddress.text = barcode;
        name.text = name.text;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The wallet did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() {
        setState(() => this.barcode =
            'null (wallet returned using the "back"-button before scanning anything. Result)');
      });
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}
