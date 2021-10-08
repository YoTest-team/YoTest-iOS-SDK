//
//  ViewController.swift
//  Demo
//
//  Created by zwh on 2021/9/28.
//

import UIKit

//fileprivate let link = "https://download-qn.okchang.com/wesingcache/001vMHwZ1kXRCx/4e5b4b6fe5a7c94f064ac88df1eb4983_new.txt"
class ViewController: UIViewController, YoTestDelegate {
    var capture: YoTest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        YoTest.logLevel = .verbose
    }

    @IBAction func regist() {
        YoTest.registSDK(auth: .init(accessId: "4297f44b13955235245b2497399d7a93")) { success in
            print("success: \(success)")
            do {
                self.capture = try YoTest(with: self)
            } catch {
                print("error: \(error)")
            }
        }
    }
    
    @IBAction func verify() {
        capture?.verify()
    }
    
    func onSuccess(args: [String : Any]) {
        logV("onSuccess args: \(args)")
    }
    
    func onReady(args: [String : Any]) {
        logV("onReady args: \(args)")
    }
    
    func onClose(args: [String : Any]) {
        logV("onClose args: \(args)")
        capture?.close()
//        YoTest.destroy()
    }
    
    func onError(args: [String : Any]) {
        logV("onError args: \(args)")
    }
}

