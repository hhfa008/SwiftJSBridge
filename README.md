# SwiftJSBridge
  
SwiftJSBridge is a handy JavaScript Bridge, written in Swift, support WKWebView and UIWebView



## Example
1. Swift 
```swift
let JSBridge = SwiftJSBridge(for: webview)
JSBridge.addSwift(bridge: { (data, cb) in
            cb?(["appVersion":"1.0"])
 }, name: "getAppVersion")

JSBridge?.callJS(name: "sendMessageToJS", data: ["message":"Hi, I am native"]) { (data) in
  
}

```
2. JS

``` JS
 function setupSwiftJSBridge(callback) {
            if (window.SwiftJSBridge) { return callback(SwiftJSBridge); }
            if (window.SwiftJSBridgeReadyCallbacks) { return window.SwiftJSBridgeReadyCallbacks.push(callback); }
            window.SwiftJSBridgeReadyCallbacks = [callback];
            SwiftJSBridgeInject()
        }

        function isWebKit() {
            return window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.SwiftJSBridgeInject;
        }

        function SwiftJSBridgeInject() {
            console.log("SwiftJSBridgeInject" )
            if (isWebKit())  {
                window.webkit.messageHandlers.SwiftJSBridgeInject.postMessage("SwiftJSBridgeInject")
            } else {
                var src = "https://SwiftJSBridgeInject/" + Math.random()
                var req = new XMLHttpRequest
                req.open("GET", src)
                req.send()
            }
        }

        setupSwiftJSBridge(function(bridge) {
            function log(message, data) {
                console.log(message+data)
            }

            bridge.addJSBridge('sendMessageToJS', function(data, responseCallback) {
                log('Native called sendMessageToJS with', data)
                var responseData = { message:'Hi, I am JS' }
                log('JS responding with', responseData)
                responseCallback(responseData)
            })
        })
        function test() {

            SwiftJSBridge.callNativeBridge("getAppVersion",{"data":"v1"},function(data){
                console.log("callback")
                console.log(data)
            })


        }
```
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SwiftJSBridge is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JSBridgeKit'
```

## Author

hhfa008, hhfa008@gmail.com

## License

SwiftJSBridge is available under the MIT license. See the LICENSE file for more info.
