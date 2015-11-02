//
//  WebViewEditor.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/1/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import WebKit

@objc protocol IWebViewEditorDelegate {
    optional func presentAlert(editor: WebViewEditor, alert: UIAlertController)
    optional func editorDidLoad(editor: WebViewEditor, error: NSError?)
    optional func editorDidChangeMessage(editor: WebViewEditor, messageText: String, error: NSError?)
    optional func editorDidSetEditability(editor: WebViewEditor, editable: Bool, error: NSError?)
    optional func processUserContent(editor: WebViewEditor, body: String)
}

class WebViewEditor: UIView, WKScriptMessageHandler {
    var webView: WKWebView?
    private var _editableMessage: String?
    
    var delegate: IWebViewEditorDelegate?
    
    convenience init(frame: CGRect, delegate: IWebViewEditorDelegate) {
        self.init(frame: frame)
        self.delegate = delegate;
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        addWebView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addWebView()
    }
    
    private static func getEditorHtml(name: String) -> String? {
        let myBundle = NSBundle(forClass: self)
        if let jsonFilePath = myBundle.pathForResource(name, ofType: "html") {
            if let data = NSData(contentsOfFile: jsonFilePath) {
                return String(data: data, encoding: NSUTF8StringEncoding)
            }
        }
        return nil
    }
    
    private func addWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addScriptMessageHandler(self, name: "editor")
        self.webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        
        webView!.translatesAutoresizingMaskIntoConstraints = false
        webView!.backgroundColor = UIColor.lightGrayColor()
        self.addSubview(webView!)
        
        let topConstraint = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0)
        
        self.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint]);
    }
    
    func loadEditorResources() {
        if let editorHtml = WebViewEditor.getEditorHtml("editor") {
            self.load(editorHtml);
        }
    }
    
    static func stringEscapedForJavascript(string:String) -> String? {
        var escapedString: String?
        let arrayForEncoding = [string as NSString] as NSArray
        if let data: NSData = try? NSJSONSerialization.dataWithJSONObject(arrayForEncoding, options: NSJSONWritingOptions()) {
            if let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding) {
                escapedString = jsonString.substringWithRange(NSMakeRange(2, jsonString.length-4))
            }
        }
        return escapedString
    }
    
    func evaluate(javascript: String, completionHandler: (AnyObject?, NSError?)->()) {
        if let escapedJavascript = WebViewEditor.stringEscapedForJavascript(javascript) {
            self.webView?.evaluateJavaScript(escapedJavascript, completionHandler: completionHandler)
        } else {
            let userInfo = [NSLocalizedDescriptionKey: "Could not execute javascript", NSLocalizedFailureReasonErrorKey: "Invalid javascript passed to web view"]
            
            completionHandler(nil, NSError(domain: "com.careevolution.direct", code: 48103009, userInfo: userInfo))
        }
        
    }
    
    private func load(html: String) {
        self.webView?.loadHTMLString(html, baseURL: nil);
    }
    
    func webViewDidLoad() {
        self.evaluate("document.getElementById('editor').focus();", completionHandler: { (object, error) -> () in
            self.delegate?.editorDidLoad!(self, error: error)
        })
    }
    
    var editableMessage: String {
        get { return _editableMessage ?? ""; }
        set {
            _editableMessage = newValue
            let js = "setEditableMessage('\(newValue)');"
            self.webView?.evaluateJavaScript(js, completionHandler: { (obj, error) -> Void in
                self.delegate?.editorDidChangeMessage?(self, messageText: newValue, error: error)
            })
        }
    }
    
    func presentError(error: NSError) {
        let alert = UIAlertController(title: error.localizedDescription, message: error.localizedFailureReason, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
        })
        alert.addAction(ok)
        self.delegate?.presentAlert?(self, alert: alert)
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let body = message.body as? String {
            if (body == "loaded:") {
                self.webViewDidLoad();
            } else if (body.hasPrefix("message:")) {
                self._editableMessage = body.substringFromIndex(body.startIndex.advancedBy(8))
                self.delegate?.editorDidChangeMessage?(self, messageText: self._editableMessage!, error: nil)
            } else {
                self.delegate?.processUserContent?(self, body: body)
            }
        }
    }
    
    
    func setEditability(editable: Bool) {
        let editableString = (editable) ? "true" : "false"
        let js = "setEditability('\(editableString)');"
        self.webView?.evaluateJavaScript(js, completionHandler: { (obj, error) -> Void in
            self.delegate?.editorDidSetEditability?(self, editable: editable, error: error)
        })
    }
}