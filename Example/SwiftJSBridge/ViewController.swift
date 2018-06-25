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


class ViewController: UIViewController {
   
    var webview:WebView?
    var timer:Timer?
    
    @objc func test() -> Void {
        _ = self.JSBridge?.callJS(name: "sendMessageToJS", data: ["message":"Hi, I am native"]) { (data) in
            print("data")
            if let data = data  {
                  print(data)
            }
          
        }
    }
    var JSBridge:SwiftJSBridge?
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        webview = getuiwebview()
//        webview = getwebview()
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(test), userInfo: nil, repeats: true)
        
    
        view.addSubview((webview?.contentView())!)
        let JSBridge = SwiftJSBridge(for: webview)
        self.JSBridge = JSBridge
        
        test()
        
        _ = JSBridge.addSwift(bridge: { (data, cb) in
            
            cb?(["appVersion":"1.0"])
        }, name: "getAppVersion")
        
        let path = Bundle.main.path(forResource: "test", ofType: "html")
        let file = URL.init(fileURLWithPath: path!)
        
        _ = webview?.loadFileURL(url: file)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getwebview()->WKWebView {
        let config = WKWebViewConfiguration()
        
        let web = WKWebView(frame: self.view.frame, configuration: config)
        return web;
    }
    
    func getuiwebview()->UIWebView {
        let web = UIWebView(frame: self.view.frame)
        return web;
    }
    
    
}

