//
//  JSFile.swift
//  Pods-SwiftJSBridge_Example
//
//  Created by hhfa on 2018/6/23.
//

import Foundation
public let jsbrigeInject = """
;(function() {
if (window.SwiftJSBridge) {
return;
}

window.SwiftJSBridge = {
addJSBridge: addJSBridge,
callNativeBridge: callNativeBridge,
_setHash: function(value){ hashValue = value },
_fetchCommandQueue: _fetchCommandQueue,
_callFromSwift: _callFromSwift,
_callbackFromSwift: _callbackFromSwift
};

var hashValue = "";
var JSCallSwiftQueue = [];
var CallFromSwiftHandlers = {};
var JSResponseCallbacks = {};

setTimeout(function() {
var callbacks = window.SwiftJSBridgeReadyCallbacks;
delete window.SwiftJSBridgeReadyCallbacks;
for (var i=0; i<callbacks.length; i++) {
callbacks[i](SwiftJSBridge);
}
}, 0);

function addJSBridge(name, jsBridge) {
CallFromSwiftHandlers[name] = jsBridge;
}

function callNativeBridge(name, data, callback) {
if (arguments.length == 2 && typeof data == 'function') {
callback = data;
data = null;
}
var callbackID
if (callback)  {
callbackID = name + Math.random()
JSResponseCallbacks[callbackID] = callback;
}

PostSwiftCall({ name:name, data:data, callbackID:callbackID });
}

function PostSwiftCall(message) {
JSCallSwiftQueue.push(message);
if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.SwiftJSBridge)  {
window.webkit.messageHandlers.SwiftJSBridge.postMessage(JSCallSwiftQueue)
JSCallSwiftQueue = []
} else {
var req = new XMLHttpRequest
req.open("GET", "https://SwiftJSBridge/" + Math.random() + "/?hash=" + hashValue)
req.send()
}
}

function _fetchCommandQueue() {
var messageQueueString = JSON.stringify(JSCallSwiftQueue);
JSCallSwiftQueue = [];
return messageQueueString;
}

function _callFromSwift(messageJSON) {
var message = JSON.parse(messageJSON)
var responseCallback
if (message.callbackID) {
responseCallback = function(callbackData) {
PostSwiftCall({ name:message.name, responseID:message.callbackID, data:callbackData });
};
}

var handler = CallFromSwiftHandlers[message.name];
if (!handler) {
console.log("SwiftJSBridge: WARNING: no bridge for message from Native:", message);
} else {
handler(message.data, responseCallback);
}
}

function _callbackFromSwift(messageJSON) {
var message = JSON.parse(messageJSON)
if (message.responseID) {
var responseCallback = JSResponseCallbacks[message.responseID];
if (!responseCallback) {
return;
}
responseCallback(message.data);
delete JSResponseCallbacks[message.responseID];
}
}

})();
"""
