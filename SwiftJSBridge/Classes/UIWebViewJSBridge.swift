//
//  UIWebViewJSBridge.swift
//  Pods-SwiftJSBridge_Example
//
//  Created by hhfa on 2018/6/23.
//

import Foundation

extension Notification.Name {
    static let MessageFromWebview = Notification.Name("MessageFromNative")
}

extension Notification.Name {
    func post(object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: self, object: object, userInfo: userInfo)
    }

    func observer(object: Any? = nil, cb: @escaping (Notification) -> Void) {
        NotificationCenter.default.addObserver(forName: self, object: object, queue: .main) { notice in
            cb(notice)
        }
    }
}

@objc extension NSObject {
    static var jsBridgeKey = "AssociatedObjectWebView"
    @objc public var jsBridge: Any? {
        get {
            return objc_getAssociatedObject(self, &type(of: self).jsBridgeKey)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &type(of: self).jsBridgeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

protocol WebViewJSBridge {
    associatedtype WebView
    var baseBridge: SwiftJSBridge? { get }
    var webview: WebView? { get }
    init(for webview: WebView, with base: SwiftJSBridge)
}

class UIWebViewJSBridge: NSObject, WebViewJSBridge {
    weak var webview: UIWebView?
    var baseBridge: SwiftJSBridge?

    required init(for webview: UIWebView, with base: SwiftJSBridge) {
        self.webview = webview
        baseBridge = base
        super.init()
        URLProtocol.registerClass(JSBridgeURLProtocol.self)
        Notification.Name.MessageFromWebview.observer { [weak self] notification in
            guard let `self` = self else {
                return
            }
            let userInfo = notification.userInfo
            guard let url = userInfo?.values.first as? URL else {
                return
            }
            self.messageFromWebview(url: url)
        }
    }

    func messageFromWebview(url: URL) {
        print(url)
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let dict = self.covert(url: components), let hash = dict["hash"] {
                if hash != baseBridge?.hash {
                    return
                }
            }
        }
        let fetchQueue = webview?.stringByEvaluatingJavaScript(from: "SwiftJSBridge._fetchQueue()")

        if let data = fetchQueue?.data(using: .utf8) {
//        let json = try? JSONDecoder.init().decode([CallbackJSON].self, from: data)
//        guard let a = json else {
//            return
//        }
//           _ = baseBridge?.callFormJS(array: a)
//        }
            _ = baseBridge?.callFormJS(data: data)
        }

//        print(fetchQueue)
    }

    func covert(url: URLComponents) -> [String: String]? {
        guard let queryItems = url.queryItems else {
            return nil
        }

        var dict = [String: String]()

        for i in queryItems {
            //            print(i.name + i.value!)
            dict[i.name] = i.value
        }
        return dict
    }

    deinit {
        print("deinit")
    }
}

class JSBridgeURLProtocol: URLProtocol {
    open override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else {
            return false
        }
//        let path = url.path
        let scheme = url.host

        guard scheme?.lowercased() == "SwiftJSBridge".lowercased() else {
            return false
        }
        print("JSBridgeURLProtocol")
        DispatchQueue.main.async {
            Notification.Name.MessageFromWebview.post(userInfo: ["url": url])
        }

        return true
    }

    open override func startLoading() {
        client?.urlProtocol(self, didReceive: URLResponse(), cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
        client?.urlProtocolDidFinishLoading(self)
    }

    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return URLRequest(url: request.url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 1)
    }

    open override class func requestIsCacheEquivalent(_: URLRequest, to _: URLRequest) -> Bool {
        return false
    }

    open override func stopLoading() {
    }
}
