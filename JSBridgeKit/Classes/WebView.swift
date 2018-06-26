//
//  WebView.swift
//  Pods-SwiftJSBridge_Example
//
//  Created by hhfa on 2018/6/23.
//

import Foundation
import WebKit

extension WKWebView: WebView {
    public func loadFileURL(url: URL) -> Bool {
        let readAccessUrl = url.deletingLastPathComponent()

        if #available(iOS 9.0, *) {
            self.loadFileURL(url, allowingReadAccessTo: readAccessUrl)
        } else {
            // Fallback on earlier versions
        }
        return true
    }

    public func contentView() -> UIView {
        return self
    }

    public func setup(setting: Dictionary<String, Any>) {
        guard let base = setting["base"] as? SwiftJSBridge else {
            return
        }
        let config = configuration
        let bridge = WebKitJSBridge(for: self, with: base)
        config.userContentController.add(bridge, name: "SwiftJSBridge")
        config.userContentController.add(bridge, name: "SwiftJSBridgeInject")
        jsBridge = bridge
//        self.configuration = config
    }

    public func evaluate(javascript: String) -> Bool {
        evaluateJavaScript(javascript)
        return true
    }
}

extension UIWebView: WebView {
    public func loadFileURL(url: URL) -> Bool {
        let req = URLRequest(url: url)
        loadRequest(req)
        //        if #available(iOS 9.0, *) {
        //            webview?.loadFileURL(file, allowingReadAccessTo: readAccessUrl)
        //        } else {
        //            // Fallback on earlier versions
        //        }
        return true
    }

    public func contentView() -> UIView {
        return self
    }

    public func setup(setting: Dictionary<String, Any>) {
        guard let base = setting["base"] as? SwiftJSBridge else {
            return
        }

        jsBridge = UIWebViewJSBridge(for: self, with: base)
    }

    public func evaluate(javascript: String) -> Bool {
        print("javascript:" + javascript)
        stringByEvaluatingJavaScript(from: javascript)
        return true
    }
}
