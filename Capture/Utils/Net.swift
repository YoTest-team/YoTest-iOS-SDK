//
//  Net.swift
//  Capture
//
//  Created by zwh on 2021/9/29.
//

import Foundation
import XNet
import WebKit
import MobileCoreServices

func mime(typeOf path: URL) -> String {
    let ext = path.pathExtension
    let type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)
    defer { type?.release() }
    if let type = type {
        let mime = type.takeUnretainedValue() as String
        if mime.lengthOfBytes(using: .utf8) == 0 {
            return "text/html"
        }
        return mime
    }
    return "text/html"
}

extension YoTest {
    /// Man In The Middle
    class MITM: URLProtocol {
        
        /// handled key
        static let HandledKey = "com.yotest.request.handled"
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let result = YoTest.authResult,
                    let url = request.url?.absoluteString else { return false }
            
            if request.httpMethod == "POST" {
                if let handled: Bool = cast(URLProtocol.property(forKey: HandledKey,
                                                              in: request)) {
                    return !handled
                }
                return true
            }
            
            if url.hasSuffix(result.webview) ||
                url.hasSuffix(result.lib) ||
                url.hasSuffix(result.binary) {
                
                if let handled: Bool = cast(URLProtocol.property(forKey: HandledKey,
                                                                 in: request)) {
                    return !handled
                }
                return true
            }
            return false
        }
        
        override class func canInit(with task: URLSessionTask) -> Bool {
            if let _ = task as? URLSessionDownloadTask {
                // 下载相关的请求不处理
                return false
            }
            guard let request = task.currentRequest else { return false }
            return self.canInit(with: request)
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            let copy = request as! NSMutableURLRequest
            URLProtocol.setProperty(true,
                                    forKey: HandledKey,
                                    in: copy)
            return copy as URLRequest
        }
        
        override func startLoading() {
            let file = request.url!.lastPathComponent
            let path = YoTest.workspace + file
            if FileManager.default.fileExists(atPath: path) {
                let data = try! Data(contentsOf: URL(fileURLWithPath: path))
                let response = URLResponse(url: request.url!,
                                           mimeType: mime(typeOf: request.url!),
                                           expectedContentLength: data.count,
                                           textEncodingName: nil)
                client?.urlProtocol(self,
                                    didReceive: response,
                                    cacheStoragePolicy: .allowed)
                client?.urlProtocol(self,
                                    didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    self.client?.urlProtocol(self, didFailWithError: error)
                    return
                }
                guard let data = data, let response = response else {
                    let error = NSError(domain: NSURLErrorDomain,
                                        code: NSURLErrorCannotParseResponse,
                                        userInfo: nil)
                    self.client?.urlProtocol(self,
                                             didFailWithError: error)
                    return
                }
                if !FileManager.default.fileExists(atPath: path) {
                    do {
                        try data.write(to: URL(fileURLWithPath: path))
                    } catch {
                        self.client?.urlProtocol(self,
                                                 didFailWithError: error)
                    }
                }
                
                self.client?.urlProtocol(self,
                                         didReceive: response,
                                         cacheStoragePolicy: .allowed)
                self.client?.urlProtocol(self,
                                         didLoad: data)
                self.client?.urlProtocolDidFinishLoading(self)
            }.resume()
        }
        
        override func stopLoading() {
            // Just do nothing
        }
    }
}
