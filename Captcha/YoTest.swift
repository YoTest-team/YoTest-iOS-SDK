import Foundation
import WebKit

public protocol YoTestDelegate: AnyObject {
    func onReady(args: [String: Any]) -> Void
    func onSuccess(args: [String: Any]) -> Void
    func onShow(args: [String: Any]) -> Void
    func onError(args: [String: Any]) -> Void
    func onClose(args: [String: Any]) -> Void
}

public final class YoTest: NSObject {
    
    static let authorizeURL = "https://api.fastyotest.com/api/init"
    public struct Auth {
        var accessId: String
        public init(accessId: String) {
            self.accessId = accessId
        }
    }
    
    class AuthResult {
        let binary: String
        let lib: String
        let webview: String
        let version: String
        
        var userAgent: String? = nil
        
        init?(with json: [String: Any]) {
            guard let b: String = cast(json["binary"]),
            let l: String = cast(json["lib"]),
            let w: String = cast(json["webview"]),
            let v: String = cast(json["version"]) else {
                return nil
            }
            
            binary = b
            lib = l
            webview = w
            version = v
        }
    }
    
    static var authorize = Auth(accessId: "")
    static var available = false
    static var requesting = false
    static var authResult: AuthResult? = nil
    
    public static var logLevel: Log.Level = .none
    
    static var back_webview: WKWebView? = nil
    
    static var webview: WKWebView = {
        if let webview = back_webview {
            return webview
        }
        back_webview = WKWebView()
        if let ua = authResult?.userAgent {
            back_webview?.customUserAgent = ua
        }
        back_webview?.backgroundColor = .clear
        back_webview?.isOpaque = false
        return back_webview!
    }()
    
    public static func registSDK(auth token: Auth,
                                 on result: @escaping (Bool) -> Void) {
        guard !requesting else {
            result(false)
            return
        }
        guard authResult == nil else {
            result(true)
            return
        }
        
        var userAgent: String = ""
        var wv: WKWebView? = WKWebView()
        let semaphore = DispatchSemaphore(value: 0)
        wv?.evaluateJavaScript("navigator.userAgent") { obj, error in
            defer { semaphore.signal() }
            guard let ua = obj as? String else { return }
            userAgent = ua
            wv = nil
        }
        DispatchQueue.global().async {
            semaphore.wait()
            available = false
            authorize = token
            guard let url = URL(string: YoTest.authorizeURL) else {
                logE("鉴权 URL 错误")
                result(false)
                return
            }
            auth(url: url,
                 try: 3) { flag in
                DispatchQueue.main.async {
                    if flag { setup(ua: userAgent) }
                    result(flag)
                }
            }
        }
    }
    
    static func setup(ua: String) {
        guard let result = authResult else { return }
        result.userAgent = "\(ua) YoTest_iOS/\(result.version)"
        webview.customUserAgent = result.userAgent
    }
    
    static func auth(url: URL,
                     try times: Int,
                     on result: @escaping (Bool) -> Void) {
        requesting = true
        guard times > 0 else {
            logE("鉴权重试多次仍失败")
            requesting = false
            result(false)
            return
        }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                logE("鉴权失败: \(error)")
                if times - 1 > 0 {
                    logI("重试鉴权，剩余次数: \(times - 1)")
                }
                
                auth(url: url,
                     try: times - 1,
                     on: result)
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                  let data = data else {
                      logE("鉴权失败: \(String(describing: response))")
                      if times - 1 > 0 {
                          logI("重试鉴权，剩余次数: \(times - 1)")
                      }
                      auth(url: url,
                           try: times - 1,
                           on: result)
                      return
                  }
            
            guard let responseString = String(data: data, encoding: .utf8),
                  responseString != " ",
                  let newData = responseString.data(using: .utf8),
                  newData.count > 0 else {
                      logE("鉴权失败，数据异常")
                      if times - 1 > 0 {
                          logI("重试鉴权，剩余次数: \(times - 1)")
                      }
                      auth(url: url,
                           try: times - 1,
                           on: result)
                      return
                  }
            
            do {
                if let info = try JSONSerialization.jsonObject(with: newData,
                                                               options: .init(rawValue: 0)) as? [String: Any] {
                    let message: String
                    if let msg: String = cast(info["message"]) {
                        message = msg
                    } else {
                        message = "No message"
                    }
                    
                    if let code: Int = cast(info["code"]),
                       code == 200,
                       let authData: [String: Any] = cast(info["data"]) {
                        guard let auResult = AuthResult(with: authData) else {
                            logE("鉴权结果解析失败")
                            requesting = false
                            result(false)
                            return
                        }
                        logI("鉴权成功：\(message)")
                        authResult = auResult
                        available = true
                        requesting = false
                        result(true)
                    } else {
                        logE("鉴权失败: \(message)")
                        requesting = false
                        result(false)
                    }
                }
            } catch {
                logE("鉴权数据解析失败: \(error)")
                if times - 1 > 0 {
                    logI("重试鉴权，剩余次数: \(times - 1)")
                }
                auth(url: url,
                     try: times - 1,
                     on: result)
            }
        }.resume()
    }
    
    static public func destroy() {
        YoTest.back_webview = nil
    }
    
    public struct YTError: Error {
        public enum Code {
            case requesting
            case unavailable
        }
        
        public let code: Code
    }
    
    var mask: UIButton?
    var loading: UIImageView?
    
    public weak var delegate: YoTestDelegate? {
        get {
            return pass.delegate
        }
        set {
            pass.delegate = newValue
        }
    }
    let pass = Pass()
    let bridge: JS.DispatchBridge
    
    public var autoShowLoading: Bool = true
    public var autoShowToast: Bool = true
    
    public init(with delegate: YoTestDelegate?) throws {
        guard Thread.isMainThread else { fatalError("只能在主线程调用") }
        guard !YoTest.requesting else {
            throw YTError(code: .requesting)
        }
        guard YoTest.available, YoTest.authResult != nil else {
            throw YTError(code: .unavailable)
        }
        
        pass.delegate = delegate
        bridge = JS.DispatchBridge(webview: YoTest.webview,
                                   bridger: "YoTestCaptcha")
        
        bridge.add(JS: Responder.Ready(pass))
        bridge.add(JS: Responder.Success(pass))
        bridge.add(JS: Responder.Show(pass))
        bridge.add(JS: Responder.Error(pass))
        bridge.add(JS: Responder.Close(pass))
        
        super.init()
        YoTest.webview.navigationDelegate = self
        pass.host = self
    }
    
    public func verify() {
        guard Thread.isMainThread else { fatalError("只能在主线程调用") }
        guard let result = YoTest.authResult else {
            logE("未授权成功")
            return
        }
        var wurl = result.webview
        if !wurl.hasPrefix("http") {
            wurl = "https:" + wurl
        }
        guard let url = URL(string: wurl) else { return }
        
        let mask = UIView()
        mask.backgroundColor = .black.withAlphaComponent(0.3)
        mask.frame = YoTest.keyWindow.bounds
        mask.isHidden = true
        YoTest.keyWindow.addSubview(mask)
        
        let webview = YoTest.webview
        webview.removeFromSuperview()
        webview.frame = YoTest.keyWindow.bounds
        mask.addSubview(webview)
        webview.load(URLRequest(url: url))
        
        if autoShowLoading {
            showLoading()
        }
    }
    
    public func close() {
        YoTest.back_webview?.stopLoading()
        YoTest.back_webview?.superview?.removeFromSuperview()
        YoTest.back_webview?.removeFromSuperview()
    }
    
    public func cancel() {
        close()
        hideLoading()
    }
    
    deinit {
        close()
        bridge.stop()
    }
}

extension YoTest: WKNavigationDelegate {
    public func webView(_ webView: WKWebView,
                        didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.bridge.callback(to: "verify",
                                 args: ["accessId": YoTest.authorize.accessId,
                                        "platform": "ios",
                                        "product": "bind"])
        }
    }
}

extension YoTest {
    static let workspace: String = {
        let dir = "\(NSTemporaryDirectory())YoTest/"
        if !FileManager.default.fileExists(atPath: dir) {
            do {
                try FileManager.default.createDirectory(atPath: dir,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
            }
        }
        return dir
    }()
}
