//
//  NativeAdView.swift
//  flutter_native_admob
//
//  Created by Dao Duy Duong on 3/8/20.
//

import UIKit
import GoogleMobileAds

class NativeAdView: GADUnifiedNativeAdView {
    //左上角Ad
    let adLabelLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 0, green: 0.67, blue: 0.53, alpha: 1)
        label.text = "Ad"
        return label
    }()
    
    lazy var adLabelView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.layer.borderColor = UIColor(red: 0, green: 0.67, blue: 0.53, alpha: 1).cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        view.addSubview(adLabelLbl)
        view.autoSetDimensions(to: CGSize(width: 22, height: 14))
        adLabelLbl.autoCenterInSuperview()
        return view
    }()
    
    //左边图标
    let adIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.autoSetDimensions(to: CGSize(width: 40, height: 40))
        imageView.layer.cornerRadius=6
        return imageView
    }()
    
    //标题
    let adHeadLineLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Roboto Medium", size: 16)
        label.textColor=UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        label.numberOfLines = 1
        return label
    }()
    
    //内容 只显示一行
    let adBodyLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Roboto Regular", size: 12)
        label.textColor=UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1)
        label.numberOfLines = 1
        return label
    }()
    
    //打开按钮
    let callToActionBtn: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(.from(color: .fromHex("#00AB88")), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius=6
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        //        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        //        button.autoSetDimension(.height, toSize: 32)
        button.autoSetDimensions(to: CGSize(width: 71,height: 32))
        return button
    }()
    
    var options = NativeAdmobOptions() {
        didSet { updateOptions() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setNativeAd(_ nativeAd: GADUnifiedNativeAd?) {
        guard let nativeAd = nativeAd else { return }
        self.nativeAd = nativeAd
        
        // Set the mediaContent on the GADMediaView to populate it with available
        // video/image asset.
        //        adMediaView.mediaContent = nativeAd.mediaContent
        
        // Populate the native ad view with the native ad assets.
        // The headline is guaranteed to be present in every native ad.
        adHeadLineLbl.text = nativeAd.headline
        
        // These assets are not guaranteed to be present. Check that they are before
        // showing or hiding them.
        adBodyLbl.text = nativeAd.body
        adBodyLbl.isHidden = nativeAd.body.isNilOrEmpty
        
        callToActionBtn.setTitle(nativeAd.callToAction, for: .normal)
        callToActionBtn.isHidden = nativeAd.callToAction.isNilOrEmpty
        
        adIconView.image = nativeAd.icon?.image
        adIconView.isHidden = nativeAd.icon == nil
        
        // In order for the SDK to process touch events properly, user interaction
        // should be disabled.
        callToActionBtn.isUserInteractionEnabled = false
    }
}

private extension NativeAdView {
    
    func setupView() {
        //        self.mediaView = adMediaView
        //标题
        self.headlineView = adHeadLineLbl
        //按钮
        self.callToActionView = callToActionBtn
        //图标
        self.iconView = adIconView
        //内容
        self.bodyView = adBodyLbl
        
        let infoLayout = StackLayout().direction(.horizontal).children([
            adIconView,
            StackViewItem(view:  StackLayout().direction(.vertical).children([
                adHeadLineLbl,
                adBodyLbl
            ]),attribute: .fill(insets: UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 12))),
            
            StackViewItem(view: callToActionBtn,attribute: .center(insets: .zero)),
        ])
        
        let holderView = UIView()
        holderView.addSubview(adLabelView)
        infoLayout.autoSetDimensions(to: CGSize(width: .zero, height: 40))
        
        let mainLayout = StackLayout()
            .direction(.vertical)
            .children([
                holderView,
                StackViewItem(view:infoLayout,attribute: .fill(insets: UIEdgeInsets(top: 2, left: 0, bottom: 4, right: 0))),
                
            ])
        addSubview(mainLayout)
        mainLayout.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 16))
    }
    
    func updateOptions() {
    }
}
