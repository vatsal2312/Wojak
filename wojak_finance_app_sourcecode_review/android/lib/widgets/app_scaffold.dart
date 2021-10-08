import 'package:flutter/material.dart';

import 'appdata.dart';

class AppScaffold extends StatelessWidget {
  final String bgImage;
  final Widget child;
  const AppScaffold({this.bgImage, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [background(context), body(context)],
    );
  }

  Widget statusBar(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).padding.top,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: AppData.light),
    );
  }

  Widget body(BuildContext context) {
    return Column(
      children: [
        statusBar(context),
        Expanded(child: child ?? Container()),
      ],
    );
  }

  Widget background(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: AppData.linearGradient,
        // image: DecorationImage(image: AssetImage(bgImage), fit: BoxFit.cover),
      ),
    );
  }
}
