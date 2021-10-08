//
//  Bridge.swift
//  Capture
//
//  Created by zwh on 2021/9/27.
//

import Foundation
import JavaScriptCore
import WebKit

/// JS 调用原生
protocol JS2Native: JSExport {
    /// JS 调用原生统一入口
    /// - Parameter json: 调用参数的 JSON 字典
    func call(json: String) -> Void
}

/// 原生调用 JS
protocol Native2JS {
    /// 原生调用 JS
    /// - Parameter method: JS 方法名
    /// - Parameter args: JS 方法参数
    func callback(to method: String,
                  args: [String: Any]) -> Void
}

protocol JSResponder {
    /// 接收到 JS 调用
    /// - Parameter data: 参数 JSON 字典
    func receiveJSCall(data: [String: Any]) -> Void
    
    var action: String { get }
}


class JS {
    
    fileprivate static let action = "action"
    fileprivate static let data = "data"
    
    class Bridge: NSObject, JS2Native, Native2JS, WKScriptMessageHandler {
        
        private let JSEntrance = "call"
        
        /// 调用者名称
        private(set) var bridger: String
        /// WKWebView
        private(set) weak var webview: WKWebView?
        /// 是否注入成功
        var injectionSucceed: Bool = false
        
        /// 初始化
        /// - Parameter webview: WKWebView
        /// - Parameter bridger: 调用者名称
        init(webview: WKWebView,
             bridger: String) {
            self.webview = webview
            self.bridger = bridger
            super.init()
            injectJavaScript()
        }
        
        /// 不再使用时调用, NS_REQUIRES_SUPER
        func stop() {
            guard let webview = webview else { return }
            webview.configuration.userContentController.removeScriptMessageHandler(forName: JSEntrance)
        }
        
        /// For subclass hook. NS_REQUIRES_SUPER
        func injectJavaScript() {
            guard let webview = webview else { return }
            webview.configuration.userContentController = .init()
            webview.configuration.userContentController.removeScriptMessageHandler(forName: JSEntrance)
            webview.configuration.userContentController.add(self, name: JSEntrance)
        }
        
        /// Subclass should implement
        func call(json: String) { }
        
        func callback(to method: String,
                      args: [String : Any]) {
            guard method.lengthOfBytes(using: .utf8) > 0 else {
                logE("JS 方法不能为空")
                return
            }
            
            guard let webview = webview else {
                logE("webview 为空")
                return
            }
            
            let jsonData: Data
            do {
                jsonData = try JSONSerialization.data(withJSONObject: args,
                                                          options: .prettyPrinted)
            } catch {
                logE("args 错误: \(error)")
                return
            }
            
            guard jsonData.count > 0 else {
                logE("args 为空")
                return
            }
            
            guard let string = String(data: jsonData,
                                      encoding: .utf8) else {
                logE("JSON data 转 String 错误")
                return
            }
            var json = string
            json = json.replacingOccurrences(of: "\n",
                                             with: " ")
            json = json.replacingOccurrences(of: " ",
                                             with: "")
            let script = "\(method)(\(json))"
            webview.evaluateJavaScript(script) { a, error in
                logV("a: \(String(describing: a)), error: \(String(describing: error))")
                if let error = error {
                    logE("回调 JS 错误: \(error)")
                }
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == JSEntrance,
            let json = message.body as? String else { return }
            
            call(json: json)
        }
        
        deinit {
            stop()
        }
    }
    
    class DispatchBridge: Bridge {
        
        private var responders = [String: JSResponder]()
        
        override func stop() {
            removeAll()
            super.stop()
        }
        
        func add(JS responder: JSResponder) {
            responders[responder.action] = responder
        }
        
        func remove(JS responder: JSResponder) {
            responders.removeValue(forKey: responder.action)
        }
        
        func removeAll() {
            responders.removeAll()
        }
        
        override func call(json: String) {
            logV("call json: \(json)")
            var data: [String: Any]?
            do {
                guard let d = json.data(using: .utf8) else { return }
                data = try JSONSerialization.jsonObject(with: d,
                                                        options: .fragmentsAllowed) as? [String: Any]
            } catch {
                return
            }
            guard let data = data,
                  let action = data[JS.action] as? String,
                  let responder = responders[action] else { return }
            
            let args: [String: Any]
            if let x: [String: Any] = cast(data) {
                args = x
            } else {
                args = [String: Any]()
            }
            DispatchQueue.main.async {
                responder.receiveJSCall(data: args)
            }
        }
    }
}
