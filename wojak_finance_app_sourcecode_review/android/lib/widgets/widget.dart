import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'appdata.dart';

Widget statusBar(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).padding.top,
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      color: AppData.Bg,
    ),
  );
}

Widget customMainAppBar({Function onTab, IconData icon, String title}) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
    decoration: BoxDecoration(
      // color: AppData.PrimaryAssent,
      color: AppData.Bg,
      // boxShadow: [
      //   BoxShadow(color: Colors.grey, blurRadius: 5, spreadRadius: 2)
      // ],
    ),
    child: ListTile(
      title: Padding(
        padding: const EdgeInsets.only(right: 40),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            color: AppData.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 15),
      trailing: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTab,
          child: Icon(icon, color: AppData.white, size: 35),
        ),
      ),
      leading: Material(
        color: Colors.transparent,
        // color: Colors.white,
        child: Container(
            height: 50,
            width: 50,
            // margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              // color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              // boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey[300])],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.asset(Assets.logo, fit: BoxFit.cover),
            )),
      ),
    ),
  );
}

Widget customAppBar({Function onTab, IconData icon, String title}) {
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.transparent,
      boxShadow: [BoxShadow(color: Colors.transparent, blurRadius: 5)],
    ),
    child: ListTile(
        title: Padding(
          padding: const EdgeInsets.only(right: 40),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: AppData.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15),
        leading: InkWell(
            onTap: onTab,
            child: Icon(Icons.arrow_back_ios_rounded, color: AppData.white))),
  );
}

Widget floatBtnContainer(
    {Widget childField, Function onTab, String tag, double top}) {
  return Container(
    padding: EdgeInsets.only(top: top ?? 50),
    child: FloatingActionButton(
      heroTag: tag,
      onPressed: onTab,
      child: Container(
        alignment: Alignment.center,
        width: 60,
        height: 60,
        child: childField,
        decoration: BoxDecoration(
            shape: BoxShape.circle, gradient: AppData.linearButton),
      ),
      backgroundColor: Colors.green,
    ),
  );
}

Widget subValueContainer({String value, Color color}) {
  return Text(
    value.toUpperCase(),
    style: TextStyle(
        color: color ?? Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5),
  );
}

Widget subTitleContainer({String name}) {
  return Text(
    name.toUpperCase(),
    style: TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5),
  );
}

Widget titleContainer({String name, double size, double spacing}) {
  return Text(name,
      style: TextStyle(
          color: AppData.Primary,
          fontSize: size ?? 16,
          letterSpacing: spacing ?? 1.5,
          fontWeight: FontWeight.bold));
}

Widget mainContainer(BuildContext context, {Widget childField}) {
  return Container(
    width: MediaQuery.of(context).size.width,
    margin: EdgeInsets.all(10),
    padding: EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(8),
    ),
    child: childField,
  );
}

Widget addPropertyTxtField(
    {String txt,
    IconData icon,
    String hinttxt,
    IconData suffixicon,
    TextEditingController controller,
    Function onTap,
    TextInputType keyboard,
    int maxLines,
    int minLines,
    bool readOnly}) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 8, top: 8),
        child: Container(
            alignment: Alignment.topLeft,
            child: Text(txt,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
      ),
      Theme(
        data: ThemeData(primaryColor: Colors.black),
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: TextField(
              controller: controller,
              readOnly: readOnly ?? false,
              maxLines: maxLines ?? 1,
              minLines: minLines ?? 1,
              decoration: InputDecoration(
                  prefixIcon: Icon(icon),
                  hintText: hinttxt,
                  suffixIcon: Icon(suffixicon)),
              keyboardType: keyboard,
              onTap: onTap),
        ),
      )
    ],
  );
}

Widget newButton({String title, Function onPressed, context}) {
  return ButtonTheme(
    height: 40,
    minWidth: 100,
    // ignore: deprecated_member_use
    child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        color: AppData.Primary,
        splashColor: Colors.black,
        child: Text(
          title,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5),
        ),
        onPressed: onPressed),
  );
}

Widget addScanProperty({
  String txt,
  String hinttxt,
  IconData suffixicon,
  TextEditingController controller,
  Function onTap,
  TextInputType keyboard,
  double radius,
}) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 8, top: 8),
        child: Container(
            alignment: Alignment.center,
            child: Text(txt,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white54))),
      ),
      Theme(
        data: ThemeData(primaryColor: Colors.white),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: TextField(
            style: TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            controller: controller,
            maxLines: 1,
            minLines: 1,
            keyboardType: keyboard ?? TextInputType.text,
            decoration: InputDecoration(
                // suffix: Icon(Icons.qr_code_scanner_rounded,color: AppData.white,),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(radius)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius)),
                hintText: hinttxt,
                hintStyle: TextStyle(color: Colors.white54),
                suffixIcon: InkWell(
                    onTap: onTap,
                    child: Icon(suffixicon ?? null, color: AppData.white))),
          ),
        ),
      )
    ],
  );
}

void showTextMsg(BuildContext context, {String msg, Color color}) {
  Toast.show(
    msg,
    context,
    textColor: AppData.white,
    backgroundColor: color == null ? Colors.black.withOpacity(0.3) : color,
    backgroundRadius: 5,
    duration: 3,
  );
}

Future<void> launchUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    );
  } else {
    throw 'Could not launch $url';
  }
}
