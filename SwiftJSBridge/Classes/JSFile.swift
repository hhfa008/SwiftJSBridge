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

if (!window.onerror) {
window.onerror = function(msg, url, line) {
console.log("SwiftJSBridge: ERROR:" + msg + "@" + url + ":" + line);
}
}
window.SwiftJSBridge = {
registerHandler: registerHandler,
callHandler: callHandler,
disableJavscriptAlertBoxSafetyTimeout: disableJavscriptAlertBoxSafetyTimeout,
_setHash: _setHash,
_fetchQueue: _fetchQueue,
_callFromSwift: _callFromSwift
};

var messagingIframe;
var hashValue = "";
var JSCallSwiftQueue = [];
var CallFromSwiftHandlers = {};

var CUSTOM_PROTOCOL_SCHEME = 'SwiftJSBridge';
var QUEUE_HAS_MESSAGE = '__wvjb_queue_message__';

var responseCallbacks = {};
var uniqueId = 1;
var dispatchMessagesWithTimeoutSafety = true;

initJSBridge();

registerHandler("_disableJavascriptAlertBoxSafetyTimeout", disableJavscriptAlertBoxSafetyTimeout);

setTimeout(_callWVJBCallbacks, 0);
function _callWVJBCallbacks() {
var callbacks = window.WVJBCallbacks;
delete window.WVJBCallbacks;
for (var i=0; i<callbacks.length; i++) {
callbacks[i](SwiftJSBridge);
}
}

function _setHash(value) {
hashValue  = value
}

function registerHandler(handlerName, handler) {
CallFromSwiftHandlers[handlerName] = handler;
}

function callHandler(handlerName, data, responseCallback) {
if (arguments.length == 2 && typeof data == 'function') {
responseCallback = data;
data = null;
}
PostSwiftCall({ name:handlerName, data:data }, responseCallback);
}
function disableJavscriptAlertBoxSafetyTimeout() {
dispatchMessagesWithTimeoutSafety = false;
}


function PostSwiftCall(message, responseCallback) {
if (responseCallback) {
var callbackID = 'cb_'+(uniqueId++)+'_'+new Date().getTime();
responseCallbacks[callbackID] = responseCallback;
message['callbackID'] = callbackID;
}
JSCallSwiftQueue.push(message);
SwiftCall()

}

function _fetchQueue() {
var messageQueueString = JSON.stringify(JSCallSwiftQueue);
JSCallSwiftQueue = [];
return messageQueueString;
}

function _dispatchMessageFromNative(messageJSON) {
if (dispatchMessagesWithTimeoutSafety) {
setTimeout(_doDispatchMessageFromNative);
} else {
_doDispatchMessageFromNative();
}

function _doDispatchMessageFromNative() {

var messageHandler;
var responseCallback;

if (message.responseId) {
responseCallback = responseCallbacks[message.responseId];
if (!responseCallback) {
return;
}
responseCallback(message.responseData);
delete responseCallbacks[message.responseId];
} else {

}
}
}

function isWebKit() {
return window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.SwiftJSBridge;
}

function SwiftCall() {
console.log("SwiftCall" )
if (isWebKit())  {
window.webkit.messageHandlers.SwiftJSBridge.postMessage(JSCallSwiftQueue)
JSCallSwiftQueue = []
} else {
var src = "https" + '://' + CUSTOM_PROTOCOL_SCHEME + "/" + QUEUE_HAS_MESSAGE + "/" + Math.random() + "/?hash=" + hashValue
var req = new XMLHttpRequest
req.open("GET", src)
req.send()
// messagingIframe.src = src;
console.log(messagingIframe )
console.log(src )
}
}


function initJSBridge() {
// if (!isWebKit()) {
//     messagingIframe = document.createElement('iframe');
//     messagingIframe.style.display = 'none';
//     messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
//     document.documentElement.appendChild(messagingIframe);
// }
// var e = document.createEvent('Events');
// e.initEvent("JSBridgeLoaded", true, false);
// document.dispatchEvent(e);

var event; // The custom event that will be created

if (document.createEvent) {
event = document.createEvent("HTMLEvents");
event.initEvent("dataavailable", true, true);
} else {
event = document.createEventObject();
event.eventType = "dataavailable";
}

event.eventName = "dataavailable";

if (document.createEvent) {
element.dispatchEvent(event);
} else {
alert("ccc")
element.fireEvent("on" + event.eventType, event);
}
}

function _callFromSwift(messageJSON) {
var message = JSON.parse(messageJSON)
var responseCallback
if (message.callbackID) {
var callbackResponseId = message.callbackID;
responseCallback = function(responseData) {
PostSwiftCall({ handlerName:message.name, responseId:callbackResponseId, responseData:responseData });
};
}

var handler = CallFromSwiftHandlers[message.name];
if (!handler) {
console.log("SwiftJSBridge: WARNING: no handler for message from ObjC:", message);
} else {
handler(message.data, responseCallback);
}
}

})();
"""
