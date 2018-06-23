//
//  SwiftJSBridgeProtocol.swift
//  Pods-SwiftJSBridge_Example
//
//  Created by hhfa on 2018/6/23.
//

import Foundation

public protocol WebView {
    func setup(setting: Dictionary<String, Any>)
    func evaluate(javascript: String) -> Bool
    func contentView() -> UIView
    func load(url: URL) -> Bool
}

public typealias Callback = (_ responseData: Any) -> Void

public typealias Hander = (_ data: Any, _ callback: Callback?) -> Void

public protocol SwiftJSBridgeProtocol {
    init(for webbiew: WebView)
    func addSwift(hander: @escaping Hander, name: String) -> Bool
    func callJS(name: String, data: [String: String]?, callback: Callback?) -> Bool
}
