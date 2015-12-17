//
//  MessageController.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/1/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import TITokenField

class MessageController: UIViewController, TITokenFieldDelegate, IWebViewEditorDelegate {
    var addToButton: UIButton?
    var addCCButton: UIButton?
    var toTokenFieldView: TITokenFieldView?
    var ccTokenFieldView: TITokenFieldView?
    var subjectLabel: UILabel?
    var subjectText: UITextField?
    var viewModel: MessageViewModel?
    var editorIsLoaded: Bool = false
    var webView: WebViewEditor?
    
    func ensureViewModelIsCreated() {
        if (self.viewModel != nil) { return }
        self.viewModel = MessageViewModel()
    }
    
    func initializeComponentsFromViewModel() {
        if (!self.viewModel!.isLoaded) { return }
        if (!self.isViewLoaded()) { return }
        if (!editorIsLoaded) { return }
        
        self.navigationItem.title = "Compose"
        
        self.webView?.editableMessage = self.viewModel!.messageHtml;
        
        toTokenFieldView?.tokenField.removeAllTokens()
        toTokenFieldView?.sourceArray = self.viewModel!.contacts.map { Box($0) }
        for token in self.viewModel!.toTokens {
            let tiToken = TIToken(title: token.description, representedObject: Box(token))
            tiToken.isAccessibilityElement = true
            tiToken.accessibilityTraits = UIAccessibilityTraitButton
            tiToken.accessibilityValue = "\(token.user)@\(token.host)"
            tiToken.accessibilityLabel = tiToken.accessibilityValue
            tiToken.accessibilityIdentifier = tiToken.accessibilityValue
            toTokenFieldView?.tokenField.addToken(tiToken)
        }
        toTokenFieldView?.forcePickSearchResult = true
        toTokenFieldView?.tokenField.accessibilityValue = EmailAddress.getCollapsedEmailAddressDisplayText(self.viewModel!.toTokens)
        
        toTokenFieldView?.tokenField.becomeFirstResponder()
        toTokenFieldView?.tokenField.endEditing(true)

    }
    
    override func loadView() {
        super.loadView()
        
        self.edgesForExtendedLayout = UIRectEdge.None

        let toFieldView = TITokenFieldView(frame: self.view.bounds)
        let toField = toFieldView.tokenField
        toField.delegate = self
        toFieldView.scrollEnabled = true
        toFieldView.translatesAutoresizingMaskIntoConstraints = false
        
        let event = UIControlEvents(rawValue: UInt(TITokenFieldControlEventFrameDidChange.rawValue))
        toField.addTarget(self, action: Selector("tokenFieldFrameDidChange:"), forControlEvents: event)
        toField.tokenizingCharacters = NSCharacterSet(charactersInString: ",;.")
        toField.setPromptText("To:")
        toField.placeholder = "Type a name"
        toField.removesTokensOnEndEditing = true
        
        let addToButton = UIButton(type: UIButtonType.ContactAdd)
        addToButton.addTarget(self, action: Selector("showToAddressPicker:"), forControlEvents: UIControlEvents.TouchUpInside)
        toField.rightView = addToButton
        self.addToButton = addToButton
        
        toField.addTarget(self, action: Selector("tokenFieldChangedEditing:"), forControlEvents: UIControlEvents.EditingDidBegin)
        toField.addTarget(self, action: Selector("tokenFieldChangedEditing:"), forControlEvents: UIControlEvents.EditingDidEnd)
        toField.rightViewMode = UITextFieldViewMode.Always
        
        self.view.addSubview(toFieldView)
        self.toTokenFieldView = toFieldView
        
        let toFieldTop = NSLayoutConstraint(item: toFieldView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0)
        let toFieldBottom = NSLayoutConstraint(item: toFieldView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
        let toFieldLeft = NSLayoutConstraint(item: toFieldView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0)
        let toFieldRight = NSLayoutConstraint(item: toFieldView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
        
        self.view.addConstraints([toFieldTop, toFieldBottom,toFieldLeft, toFieldRight])
        
        let subjectLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        let subjectText = UITextField(frame: CGRect(x: 100, y: 0, width: 300, height: 20))
        subjectLabel.setContentCompressionResistancePriority(752, forAxis: UILayoutConstraintAxis.Horizontal)
        
        toFieldView.contentView.addSubview(subjectLabel)
        toFieldView.contentView.addSubview(subjectText)
        
        let subjectLabelTop = NSLayoutConstraint(item: subjectLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: toFieldView.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0)
        let subjectLabelLeft = NSLayoutConstraint(item: subjectLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: toFieldView.contentView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0)
        let subjectTextTop = NSLayoutConstraint(item: subjectText, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: toFieldView.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0)
        let subjectTextLeft = NSLayoutConstraint(item: subjectText, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: subjectLabel, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
        let subjectTextRight = NSLayoutConstraint(item: subjectText, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: toFieldView.contentView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
        
        toFieldView.contentView.addConstraints([subjectLabelTop, subjectLabelLeft, subjectTextTop, subjectTextLeft, subjectTextRight])
        
        
        self.editorIsLoaded = false
        let webView = WebViewEditor(frame: toFieldView.contentView.bounds, delegate: self);
        webView.translatesAutoresizingMaskIntoConstraints = false
        toFieldView.contentView.addSubview(webView);
        self.webView = webView
        
        let webViewTop = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: subjectText, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
        let webViewLeft = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: toFieldView.contentView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0)
        let webViewRight = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: toFieldView.contentView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
        let webViewBottom = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: toFieldView.contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
        
        toFieldView.contentView.addConstraints([webViewTop, webViewLeft, webViewRight, webViewBottom])
        
        webView.loadEditorResources()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.ensureViewModelIsCreated()
        self.initializeComponentsFromViewModel()

    }
    
    func editorDidLoad(editor: WebViewEditor, error: NSError?) {
        if (error == nil) {
            self.editorIsLoaded = true
            self.initializeComponentsFromViewModel()
        } else {
            self.notifyUserOfError(error!, withCallbackOnDismissal: {})
        }
    }

    func editorDidChangeMessage(editor: WebViewEditor, messageText: String, error: NSError?) {
        self.viewModel!.messageHtml = messageText
    }

    
    func setContacts(contacts: [EmailAddress]?) {
        self.ensureViewModelIsCreated()
        self.viewModel?.setContacts(contacts)
        self.initializeComponentsFromViewModel()
    }
    
    func tokenFieldFrameDidChange(tokenField: TITokenField!) {
    }
    
    func tokenFieldChangedEditing(tokenField: TITokenField!) {
        
    }
    
    func showToAddressPicker(sender: UIButton!) {
    }
    
    func showCCAddressPicker(sender: UIButton!) {
    }
    
    func tokenField(tokenField: TITokenField!, didAddToken token: TIToken!) {
        if let address = token.representedObject as? Box {
            if (tokenField == toTokenFieldView!.tokenField) {
                self.viewModel?.addToToken(address.unbox)
                tokenField.accessibilityValue = EmailAddress.getCollapsedEmailAddressDisplayText(self.viewModel?.toTokens ?? [])
            } else {
                self.viewModel?.addCCToken(address.unbox)
                tokenField.accessibilityValue = EmailAddress.getCollapsedEmailAddressDisplayText(self.viewModel?.ccTokens ?? [])
            }
        }
    }
    
    func tokenField(tokenField: TITokenField!, didRemoveToken token: TIToken!) {
        if let address = token.representedObject as? Box {
            if (tokenField == toTokenFieldView!.tokenField) {
                self.viewModel?.removeToToken(address.unbox)
                tokenField.accessibilityValue = EmailAddress.getCollapsedEmailAddressDisplayText(self.viewModel?.toTokens ?? [])
            } else {
                self.viewModel?.removeCCToken(address.unbox)
                tokenField.accessibilityValue = EmailAddress.getCollapsedEmailAddressDisplayText(self.viewModel?.ccTokens ?? [])
            }
        }
    }


}