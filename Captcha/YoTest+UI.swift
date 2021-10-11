//
//  YoTest+UI.swift
//  Captcha
//
//  Created by zwh on 2021/10/10.
//

import Foundation
import UIKit

extension YoTest {
    
    /// 点击蒙层
    @objc func click() {
        cancel()
        pass.onClose(args: .init())
    }
    
    /// 显示 loading
    func showLoading() {
        guard loading == nil, mask == nil else { return }
        
        let mask = UIButton()
        mask.frame = YoTest.keyWindow.bounds
        mask.backgroundColor = .black.withAlphaComponent(0.3)
        YoTest.keyWindow.addSubview(mask)
        mask.addTarget(self,
                       action: #selector(click),
                       for: .touchUpInside)
        self.mask = mask
        
        let loading = UIImageView()
        loading.translatesAutoresizingMaskIntoConstraints = false
        let width = NSLayoutConstraint(item: loading,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 0,
                                       constant: 100)
        width.isActive = true
        
        let height = NSLayoutConstraint(item: loading,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 0,
                                        constant: 100)
        height.isActive = true
        
        YoTest.keyWindow.addSubview(loading)
        
        let centerX = NSLayoutConstraint(item: loading,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: loading.superview!,
                                         attribute: .centerX,
                                         multiplier: 1,
                                         constant: 0)
        centerX.isActive = true
        
        let centerY = NSLayoutConstraint(item: loading,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: loading.superview!,
                                         attribute: .centerY,
                                         multiplier: 1,
                                         constant: 0)
        centerY.isActive = true
        
        loading.contentMode = .scaleAspectFit
        var images = [UIImage]()
        let framework = Bundle(for: YoTest.self)
        let path = framework.path(forResource: "Loading",
                                  ofType: "bundle")!
        let bundle = Bundle(path: path)!
        for i in 0 ..< 24 {
            if let image = UIImage(named: String(format: "%03d.png", i),
                                   in: bundle,
                                   compatibleWith: nil) {
                images.append(image)
            }
        }
        loading.animationImages = images
        loading.animationDuration = TimeInterval(images.count) / TimeInterval(24)
        loading.startAnimating()
        self.loading = loading
    }
    
    /// 隐藏 loading
    func hideLoading() {
        guard let loading = loading, let mask = mask else { return }
        loading.stopAnimating()
        loading.removeFromSuperview()
        mask.removeFromSuperview()
        self.mask = nil
        self.loading = nil
    }
    
    /// 弹吐司提示
    /// - Parameters:
    ///   - message: 提示信息
    ///   - after: 多长时间后隐藏
    static func toast(message: String,
                      hide after: TimeInterval = 2) {
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = .black.withAlphaComponent(0.8)
        background.layer.cornerRadius = 10
        background.layer.masksToBounds = true
        YoTest.keyWindow.addSubview(background)
        
        NSLayoutConstraint(item: background,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: background.superview!,
                           attribute: .centerX,
                           multiplier: 1,
                           constant: 0).isActive = true
        
        NSLayoutConstraint(item: background,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: background.superview!,
                           attribute: .centerY,
                           multiplier: 1,
                           constant: 0).isActive = true
        
        let label = UILabel()
        background.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.backgroundColor = .black.withAlphaComponent(0.3)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.text = message
        
        label.setContentCompressionResistancePriority(.required,
                                                      for: .horizontal)
        label.setContentCompressionResistancePriority(.required,
                                                      for: .vertical)
        NSLayoutConstraint(item: label,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: label.superview!,
                           attribute: .top,
                           multiplier: 1,
                           constant: 20).isActive = true
        
        NSLayoutConstraint(item: label,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: label.superview!,
                           attribute: .left,
                           multiplier: 1,
                           constant: 20).isActive = true
        
        NSLayoutConstraint(item: label,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: label.superview!,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: -20).isActive = true
        
        NSLayoutConstraint(item: label,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: label.superview!,
                           attribute: .right,
                           multiplier: 1,
                           constant: -20).isActive = true
        
        NSLayoutConstraint(item: label,
                           attribute: .width,
                           relatedBy: .lessThanOrEqual,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: UIScreen.main.bounds.width - 80).isActive = true
        
        UIView.animate(withDuration: 0.35,
                       delay: after,
                       options: .curveEaseOut) {
            background.alpha = 0
        } completion: { _ in
            background.removeFromSuperview()
        }
    }
    
    /// 回调代理透传，某些代理事件需要先处理一些事情
    class Pass: NSObject, YoTestDelegate {
        weak var host: YoTest?
        weak var delegate: YoTestDelegate?
        func onReady(args: [String : Any]) {
            delegate?.onReady(args: args)
        }
        
        func onSuccess(args: [String : Any]) {
            host?.hideLoading()
            YoTest.toast(message: "已通过友验智能验证")
            delegate?.onSuccess(args: args)
        }
        
        func onShow(args: [String : Any]) {
            host?.hideLoading()
            delegate?.onShow(args: args)
        }
        
        func onError(args: [String : Any]) {
            host?.hideLoading()
            delegate?.onError(args: args)
        }
        
        func onClose(args: [String : Any]) {
            host?.hideLoading()
            delegate?.onClose(args: args)
        }
    }
}
