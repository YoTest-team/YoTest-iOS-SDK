import Foundation
import UIKit

extension YoTest {
    
    @objc func click() {
        cancel()
        pass.onClose(args: .init())
    }
    
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
                                       constant: 85)
        width.isActive = true
        
        let height = NSLayoutConstraint(item: loading,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 0,
                                        constant: 85)
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
    
    func hideLoading() {
        guard let loading = loading, let mask = mask else { return }
        loading.stopAnimating()
        loading.removeFromSuperview()
        mask.removeFromSuperview()
        self.mask = nil
        self.loading = nil
    }
    
    static func toast(message: String,
                      hide after: TimeInterval = 2) {
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = .init(red: 0.94,
                                           green: 0.94,
                                           blue: 0.94,
                                           alpha: 0.9)
        background.layer.cornerRadius = 20
        background.layer.masksToBounds = true
        YoTest.keyWindow.addSubview(background)
        
        NSLayoutConstraint(item: background,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: background.superview!,
                           attribute: .centerX,
                           multiplier: 1,
                           constant: 0).isActive = true
        
        var bottom: CGFloat = -30;
        if #available(iOS 11.0, *) {
            if YoTest.keyWindow.safeAreaInsets.top > 0 {
                bottom -= 34
            }
        }
        NSLayoutConstraint(item: background,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: background.superview!,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: bottom).isActive = true
        
        let label = UILabel()
        background.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
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
                           constant: 15).isActive = true
        
        NSLayoutConstraint(item: label,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: label.superview!,
                           attribute: .left,
                           multiplier: 1,
                           constant: 25).isActive = true
        
        NSLayoutConstraint(item: label,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: label.superview!,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: -15).isActive = true
        
        NSLayoutConstraint(item: label,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: label.superview!,
                           attribute: .right,
                           multiplier: 1,
                           constant: -25).isActive = true
        
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
    
    class Pass: NSObject, YoTestDelegate {
        weak var host: YoTest?
        weak var delegate: YoTestDelegate?
        func onReady(args: [String : Any]) {
            delegate?.onReady(args: args)
        }
        
        func onSuccess(args: [String : Any]) {
            host?.hideLoading()
            let show = host?.autoShowToast ?? false
            if show {
                YoTest.toast(message: "已通过友验智能验证")
            }
            
            delegate?.onSuccess(args: args)
        }
        
        func onShow(args: [String : Any]) {
            host?.hideLoading()
            YoTest.webview.superview?.isHidden = false
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
