//
//  WebKitJSBrige.swift
//  Pods-SwiftJSBridge_Example
//
//  Created by hhfa on 2018/6/23.
//

import Foundation
import WebKit

class WebKitJSBridge: NSObject, WKScriptMessageHandler, WebViewJSBridge {
    var baseBridge: SwiftJSBridge?

    required init(for webview: WKWebView, with base: SwiftJSBridge) {
        self.webview = webview
        baseBridge = base
        super.init()
    }

    weak var webview: WKWebView?

    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
    
        let name = message.name
        
        if name == "SwiftJSBridgeInject" {
            _ = baseBridge?.injectJS()
            return
        }
        
        let body = message.body
        print(name)
        print(body)
        if let data = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted) {
            _ = baseBridge?.callFromJS(data: data)
        }
    }

    deinit {
        print("deinit WebKitJSBridge")
    }
}
