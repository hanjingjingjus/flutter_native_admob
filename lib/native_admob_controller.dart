import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AdLoadState { loading, loadError, loadCompleted }

class NativeAdmobController {
  final _key = UniqueKey();
  final bool isAutoReload;
  final int autoReloadTime;
  int remainReloadTime;
  String get id => _key.toString();

  final _stateChanged = StreamController<AdLoadState>.broadcast();
  Stream<AdLoadState> get stateChanged => _stateChanged.stream;

  final MethodChannel _pluginChannel =
      const MethodChannel("flutter_native_admob");
  MethodChannel _channel;
  String _adUnitID;

  NativeAdmobController({this.isAutoReload: false, this.autoReloadTime: 3}) {
    _channel = MethodChannel(id);
    _channel.setMethodCallHandler(_handleMessages);
    remainReloadTime=autoReloadTime;
    // Let the plugin know there is a new controller
    _pluginChannel.invokeMethod("initController", {
      "controllerID": id,
    });
  }

  void dispose() {}

  Future<Null> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case "loading":
        _stateChanged.add(AdLoadState.loading);
        break;

      case "loadError":
        _stateChanged.add(AdLoadState.loadError);
        //失败自动重新加载
        if (isAutoReload && remainReloadTime > 0) {
          remainReloadTime--;
          if (_adUnitID != null) {
            _channel.invokeMethod("reloadAd", {
              "forceRefresh": true,
            });
          }
        }
        break;

      case "loadCompleted":
        remainReloadTime = autoReloadTime;
        _stateChanged.add(AdLoadState.loadCompleted);
        break;
    }
  }

  /// Change the ad unit ID
  void setAdUnitID(String adUnitID) {
    _adUnitID = adUnitID;
    _channel.invokeMethod("setAdUnitID", {
      "adUnitID": adUnitID,
    });
  }

  /// Reload new ad with specific native ad id
  ///
  ///  * [forceRefresh], force reload a new ad or using cache ad
  void reloadAd({bool forceRefresh = false}) {
    remainReloadTime = autoReloadTime;
    if (_adUnitID == null) return;

    _channel.invokeMethod("reloadAd", {
      "forceRefresh": forceRefresh,
    });
  }
}
