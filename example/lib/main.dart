import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _adUnitID = "ca-app-pub-3940256099942544/8135179316";

  final _controller = NativeAdmobController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            NativeAdmob(
              adUnitID: _adUnitID,
              controller: _controller,
            ),
            RaisedButton(
              onPressed: (){_controller.reloadAd(forceRefresh: true);},
            )
          ],
        ),
      ),
    );
  }
}
