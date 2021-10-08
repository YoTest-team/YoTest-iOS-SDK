//
//  Window.swift
//  Capture
//
//  Created by zwh on 2021/9/28.
//

import Foundation
import UIKit

extension YoTest {
    static let keyWindow: UIWindow = {
        if let delegate = UIApplication.shared.delegate,
           let window = delegate.window as? UIWindow {
            return window
        }
        if #available(iOS 13.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = scene.windows.first {
                    return window
                }
            }
        }
        return UIApplication.shared.windows.first!
    }()
}
