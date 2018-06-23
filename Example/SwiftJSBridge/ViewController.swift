//
//  ViewController.swift
//  SwiftJSBridge
//
//  Created by hhfa008 on 06/23/2018.
//  Copyright (c) 2018 hhfa008. All rights reserved.
//

import UIKit
import WebKit
import SwiftJSBridge


class ViewController: UIViewController, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message)
        print(message.name)
        print(message.body)
    }
    var webview:WebView?
    var timer:Timer?

    @objc func test() -> Void {
        self.JSBridge?.callJS(name: "ttt", data: ["key":"123"]) { (data) in
            
        }
    }
    var JSBridge:SwiftJSBridge?
    override func viewDidLoad() {
    
        
        super.viewDidLoad()
        webview = getuiwebview()
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(test), userInfo: nil, repeats: true)
        
//        webview = getwebview()
//        webview?.setup(setting: ["test":"test"])
        view.addSubview((webview?.contentView())!)
        let JSBridge = SwiftJSBridge.init(for: webview!)
        self.JSBridge = JSBridge
        
        test()
        
        _ = JSBridge.addSwift(hander: { (data, cb) in
           print("addSwift2\(data)")
        }, name: "name2")
        
        _ = JSBridge.addSwift(hander: { (data, cb) in
              print("addSwift1\(data)")
        }, name: "name")
        
        let path = Bundle.main.path(forResource: "test", ofType: "html")
        let file = URL.init(fileURLWithPath: path!)
        
        webview?.load(url: file)
//        if #available(iOS 9.0, *) {
//            webview?.loadFileURL(file, allowingReadAccessTo: readAccessUrl)
//        } else {
//            // Fallback on earlier versions
//        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getwebview()->WKWebView {
        let config = WKWebViewConfiguration.init()
//
//        config.userContentController.add(self, name: "SwiftJSBridge")
////        config.
        
        let web = WKWebView.init(frame: self.view.frame, configuration: config)
        return web;
    }
    
    func getuiwebview()->UIWebView {
        let web = UIWebView.init(frame: self.view.frame)
        return web;
    }


}

