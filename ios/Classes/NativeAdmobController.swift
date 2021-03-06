//
//  NativeAdmobController.swift
//  flutter_native_admob
//
//  Created by Dao Duy Duong on 3/14/20.
//

import GoogleMobileAds

class NativeAdmobController: NSObject {
    
    enum CallMethod: String {
        case setAdUnitID
        case reloadAd
    }
//    loaded,
//    failedToLoad,
//    clicked,
//    impression,
//    opened,
//    leftApplication,
//    closed,
    enum LoadState: String {
        case loading, loadError, loadCompleted,impression, leftApplication
    }
    
    let id: String
    let channel: FlutterMethodChannel
    
    var nativeAdChanged: ((GADUnifiedNativeAd?) -> Void)?
    var nativeAd: GADUnifiedNativeAd? {
        didSet { invokeLoadCompleted() }
    }
    
    private var adLoader: GADAdLoader?
    private var adUnitID: String?
    
    init(id: String, channel: FlutterMethodChannel) {
        self.id = id
        self.channel = channel
        super.init()
        
        channel.setMethodCallHandler(handle)
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let callMethod = CallMethod(rawValue: call.method) else { return result(FlutterMethodNotImplemented) }
        let params = call.arguments as? [String: Any]
        
        switch callMethod {
        case .setAdUnitID:
            guard let adUnitID = params?["adUnitID"] as? String else {
                return result(nil)
            }
            
            let isChanged = adUnitID != self.adUnitID
            self.adUnitID = adUnitID
            
            if adLoader == nil || isChanged {
                adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: nil, adTypes: [.unifiedNative], options: nil)
                adLoader?.delegate = self
            }
            
            if nativeAd == nil || isChanged {
                loadAd()
            } else {
                invokeLoadCompleted()
            }
            
        case .reloadAd:
            let forceRefresh = params?["forceRefresh"] as? Bool ?? false
            if forceRefresh || nativeAd == nil {
                loadAd()
            } else {
                invokeLoadCompleted()
            }
        }
        
        result(nil)
    }
    
    private func loadAd() {
        channel.invokeMethod(LoadState.loading.rawValue, arguments: nil)
        adLoader?.load(GADRequest())
    }
    
    private func invokeLoadCompleted() {
        nativeAdChanged?(nativeAd)
        channel.invokeMethod(LoadState.loadCompleted.rawValue, arguments: nil)
    }
}

extension NativeAdmobController: GADUnifiedNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("NativeAdmob: failed to load with error: \(error.localizedDescription)")
        channel.invokeMethod(LoadState.loadError.rawValue, arguments: nil)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        print("NativeAdmob: didReceive")
        nativeAd.delegate = self
        self.nativeAd = nativeAd
    }
}

// MARK: - GADUnifiedNativeAdDelegate implementation
extension NativeAdmobController : GADUnifiedNativeAdDelegate {

  func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
    print("nativeAdDidRecordClick called")
  }

  func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
    print("nativeAdDidRecordImpression called")
    channel.invokeMethod(LoadState.impression.rawValue, arguments: nil)
  }

  func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("nativeAdWillPresentScreen called")
  }

  func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("nativeAdWillDismissScreen called")
  }

  func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("nativeAdDidDismissScreen called")
  }

  func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
    print("nativeAdWillLeaveApplication called")
    channel.invokeMethod(LoadState.leftApplication.rawValue, arguments: nil)
  }
}

class NativeAdmobControllerManager {
    
    static let shared = NativeAdmobControllerManager()
    
    private var controllers: [NativeAdmobController] = []
    
    private init() {}
    
    func createController(forID id: String, binaryMessenger: FlutterBinaryMessenger) {
        if getController(forID: id) == nil {
            let methodChannel = FlutterMethodChannel(name: id, binaryMessenger: binaryMessenger)
            let controller = NativeAdmobController(id: id, channel: methodChannel)
            controllers.append(controller)
        }
    }
    
    func getController(forID id: String) -> NativeAdmobController? {
        return controllers.first(where: { $0.id == id })
    }
    
    func removeController(forID id: String) {
        if let index = controllers.firstIndex(where: { $0.id == id }) {
            controllers.remove(at: index)
        }
    }
}
