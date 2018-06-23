//
//  SwiftJSBridge.swift
//  SwiftJSBridge
//
//  Created by hhfa on 2018/6/23.
//

import Foundation

class CallbackJSON: Codable {
//    enum CodingKeys : String, CodingKey {
//        case name
//        case data
//        case callbackID
//    }
//    func encode(to encoder: Encoder) throws {
//     var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//        container.encode(data, forKey: .data)
//        try container.encode(callbackID, forKey: .callbackID)
//    }
    var name: String?
    var data: [String: String]?
    var callbackID: String?
}

open class SwiftJSBridge: SwiftJSBridgeProtocol {
    var nativeHandler: [String: Hander] = [:]
    var callbackHandler: [String: Callback] = [:]
    var webview: WebView
    var hash: String = UUID().uuidString
    public required init(for webview: WebView) {
        self.webview = webview
        self.webview.setup(setting: ["base": self])

        _ = injectJS()
        _ = setHash()
//        let deadlineTime = DispatchTime.now() + .seconds(5)
//        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
//             _ = self.setHash()
//        }
    }

    public func addSwift(hander: @escaping Hander, name: String) -> Bool {
        nativeHandler[name] = hander
        return true
    }

    func callFormJS(data: Data) -> Bool {
        print("xxx:" + hash)
        let json = try? JSONDecoder().decode([CallbackJSON].self, from: data)
        guard let a = json else {
            return false
        }
        _ = callFormJS(array: a)

        return true
    }

    func callFormJS(array: [CallbackJSON]?) -> Bool {
        print("callFormJS array")
        guard let array = array else {
            return false
        }
        for json in array {
            _ = callFormJS(json: json)
        }
        return true
    }

    func callFormJS(json: CallbackJSON) -> Bool {
        guard let name = json.name else {
            return false
        }

        var callback: Callback?

        if let callbackID = json.callbackID {
            callback = callbackHandler[callbackID]
        }

        return callFormJS(name: name, data: json.data, callback: callback)
    }

    public func callFormJS(name: String, data: [String: String]?, callback: Callback?) -> Bool {
        let hander = nativeHandler[name]
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
            callbackHandler[callbackID] = callback
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
//        return true
    }

    deinit {
        print("deinit SwiftJSBridge")
    }
}
