//
//  Responder.swift
//  Captcha
//
//  Created by zwh on 2021/10/2.
//

import Foundation

final class Responder {
    class Base {
        weak var delegate: YoTestDelegate?
        init(_ delegate: YoTestDelegate?) {
            self.delegate = delegate
        }
    }
    
    class Ready: Base, JSResponder {
        func receiveJSCall(data: [String : Any]) {
            delegate?.onReady(args: data)
        }
        
        let action: String = "onReady"
    }
    
    class Success: Base, JSResponder {
        func receiveJSCall(data: [String : Any]) {
            delegate?.onSuccess(args: data)
        }
        
        let action: String = "onSuccess"
    }
    
    class Show: Base, JSResponder {
        func receiveJSCall(data: [String : Any]) {
            delegate?.onShow(args: data)
        }
        
        let action: String = "onShow"
    }
    
    class Error: Base, JSResponder {
        func receiveJSCall(data: [String : Any]) {
            delegate?.onError(args: data)
        }
        
        let action: String = "onError"
    }
    
    class Close: Base, JSResponder {
        func receiveJSCall(data: [String : Any]) {
            delegate?.onClose(args: data)
        }
        
        let action: String = "onClose"
    }
}
