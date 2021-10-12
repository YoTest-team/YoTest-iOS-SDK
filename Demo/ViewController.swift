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
    }
    
    func onReady(args: [String : Any]) {
        print("onReady args: \(args)")
    }
    
    func onShow(args: [String : Any]) {
        print("onShow args: \(args)")
    }
    
    func onClose(args: [String : Any]) {
        print("onClose args: \(args)")
        captcha?.close()
    }
    
    func onError(args: [String : Any]) {
        print("onError args: \(args)")
    }
}

