# SwiftJSBridge
  
SwiftJSBridge is a handy JavaScript Bridge, written in Swift, support WKWebView and UIWebView



## Example
```swift
let JSBridge = SwiftJSBridge(for: webview)
JSBridge.addSwift(bridge: { (data, cb) in
            cb?(["appVersion":"1.0"])
 }, name: "getAppVersion")

JSBridge?.callJS(name: "sendMessageToJS", data: ["message":"Hi, I am native"]) { (data) in
  
}

```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SwiftJSBridge is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BetterSwiftJSBridge'
```

## Author

hhfa008, hhfa008@gmail.com

## License

SwiftJSBridge is available under the MIT license. See the LICENSE file for more info.
