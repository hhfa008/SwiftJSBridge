//
//  SwiftJSBridge.swift
//  SwiftJSBridge
//
//  Created by hhfa on 2018/6/23.
//

import Foundation

class CallbackJSON: Codable {
    var name: String?
    var data: [String: String]?
    var callbackID: String?
    var responseID: String?
}

typealias ResponseJSON = CallbackJSON

open class SwiftJSBridge: SwiftJSBridgeProtocol {
    var bridges: [String: Bridge] = [:]
    var callbacks: [String: Callback] = [:]
    var responseHandler: [String: Callback] = [:]
    var webview: WebView
    var hash: String = UUID().uuidString
    
    public required init(for webview: WebView) {
        self.webview = webview
        self.webview.setup(setting: ["base": self])

        _ = injectJS()
        _ = setHash()
    }

    public func addSwift(bridge: @escaping Bridge, name: String) -> Bool {
        bridges[name] = bridge
        return true
    }

    func callFromJS(data: Data) -> Bool {
        let json = try? JSONDecoder().decode([CallbackJSON].self, from: data)
        guard let a = json else {
            return false
        }
        _ = callFromJS(array: a)

        return true
    }

    func callFromJS(array: [CallbackJSON]?) -> Bool {
        guard let array = array else {
            return false
        }
        for json in array {
            
            _ = json.responseID == nil ? callFromJS(json: json) :callbackFromJS(json: json)
        }
        return true
    }

    public func callFromJS(name: String, data: [String: String]?, callback: Callback?) -> Bool {
        let hander = bridges[name]
        if let hander = hander {
            hander(data, callback)
        }
        return true
    }

    public func callJS(name: String, data: [String: String]? = nil, callback: Callback? = nil) -> Bool {
        let json: CallbackJSON = CallbackJSON()

        json.name = name
        if let callback = callback {
            let callbackID = NSUUID().uuidString
            callbacks[callbackID] = callback
            json.callbackID = callbackID
        }

        if let data = data {
            json.data = data
        }
        let decoder = JSONEncoder()
        guard let rawdata = try? decoder.encode(json), let jsonString = String(data: rawdata, encoding: .utf8) else {
            return false
        }
        print(jsonString)
        return webview.evaluate(javascript: "window.SwiftJSBridge._callFromSwift(\'\(jsonString)\')")
    }

    func setHash() -> Bool {
        return webview.evaluate(javascript: "window.SwiftJSBridge._setHash(\"\(hash)\")")
    }

    func injectJS() -> Bool {
        return webview.evaluate(javascript: jsbrigeInject)
    }
}

extension SwiftJSBridge {
    
    func callbackFromJS(json: ResponseJSON) -> Bool {
        guard let responseID = json.responseID, let callback = callbacks[responseID]  else {
            return false
        }
        callback(json.data)
        callbacks[responseID] = nil
        
        return true
    }
    
    func callFromJS(json: CallbackJSON) -> Bool {
        guard let name = json.name else {
            return false
        }
        var callback: Callback?
        if let callbackID = json.callbackID {
            
            callback = { [weak self] data in
                guard let `self` = self else {
                    return
                }
                _ = self.callbackToJS(callbackID: callbackID,data: data)
                self.responseHandler[callbackID] = nil
            }
            responseHandler[callbackID] = callback
        }

        return callFromJS(name: name, data: json.data, callback: callback)
    }
}

extension SwiftJSBridge {
     public func callbackToJS(callbackID: String, data: [String: String]? = nil) -> Bool {
        let json: ResponseJSON = ResponseJSON()
        json.responseID = callbackID
        
        if let data = data {
            json.data = data
        }
        let decoder = JSONEncoder()
        guard let rawdata = try? decoder.encode(json), let jsonString = String(data: rawdata, encoding: .utf8) else {
            return false
        }
        
        return webview.evaluate(javascript: "window.SwiftJSBridge._callbackFromSwift(\'\(jsonString)\')")
    }
}
