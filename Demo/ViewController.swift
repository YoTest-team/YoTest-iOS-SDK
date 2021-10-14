//
//  ViewController.swift
//  Demo
//
//  Created by zwh on 2021/9/28.
//

import UIKit

class ViewController: UIViewController, YoTestDelegate {
    var captcha: YoTest?
    
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var console: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        login.layer.masksToBounds = true
        login.layer.cornerRadius = 10
    }
    
    @IBAction func verify() {
        if captcha == nil {
            do {
                captcha = try YoTest(with: self)
            } catch {
                print("error: \(error)")
            }
        }
        captcha?.verify()
    }
    
    func onSuccess(args: [String : Any]) {
        print("onSuccess args: \(args)")
        printLog(action: "onSuccess",
                 args: args)
    }
    
    func onReady(args: [String : Any]) {
        print("onReady args: \(args)")
        printLog(action: "onReady",
                 args: args)
    }
    
    func onShow(args: [String : Any]) {
        print("onShow args: \(args)")
        printLog(action: "onShow",
                 args: args)
    }
    
    func onClose(args: [String : Any]) {
        print("onClose args: \(args)")
        printLog(action: "onClose",
                 args: args)
        captcha?.close()
    }
    
    func onError(args: [String : Any]) {
        print("onError args: \(args)")
        printLog(action: "onError",
                 args: args)
    }
    
    func printLog(action: String,
                  args: [String: Any]) {
        var text = console.text!
        if text != "" { text += "\n" }
        text += action + ": "
        var log = "\(args)"
        log = log.replacingOccurrences(of: "\n",
                                       with: " ")
        text += log
        console.text = text
    }
}

