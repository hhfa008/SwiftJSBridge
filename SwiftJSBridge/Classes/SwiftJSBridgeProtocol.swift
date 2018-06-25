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
    func loadFileURL(url: URL) -> Bool
}

public typealias Callback = (_ responseData: [String:String]?) -> Void

public typealias Bridge = (_ data: [String:String]?, _ callback: Callback?) -> Void

public protocol SwiftJSBridgeProtocol {
    init(for webbiew: WebView)
    func addSwift(bridge: @escaping Bridge, name: String) -> Bool
    func callJS(name: String, data: [String: String]?, callback: Callback?) -> Bool
}
