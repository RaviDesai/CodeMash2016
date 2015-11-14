//
//  LoginControllerTests.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/14/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDTesting
import RSDRESTServices
import RSDSerialization
import OHHTTPStubs
@testable import CodeMash2016

class LoginControllerTests: AsynchronousTestCase {
    var controller: LoginController?
    var mockViewModel: PartialMockLoginViewModel?
    var called = false
    
    func getStoryboard(name: String) -> UIStoryboard? {
        let storyboardBundle = NSBundle(forClass: LoginController.classForCoder())
        return UIStoryboard(name: name, bundle: storyboardBundle)
    }
    
    func getFakeUsers() -> [User] {
        return [
            User(id: NSUUID(), name: "One", emailAddress: EmailAddress(user: "one", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberOne")),
            User(id: NSUUID(), name: "Two", emailAddress: EmailAddress(user: "two", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberTwo")),
            User(id: NSUUID(), name: "Three", emailAddress: EmailAddress(user: "three", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberThree")),
            User(id: NSUUID(), name: "Four", emailAddress: EmailAddress(user: "four", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberFourxr"))]
    }
    
    class override func setUp() {
        super.setUp()
        Swizzler<LoginController>.swizzlePerformSegueWithIdentifier()
    }

    class override func tearDown() {
        Swizzler<LoginController>.swizzlePerformSegueWithIdentifier()
        super.tearDown()
    }
    
    override func setUp() {
        super.setUp()
        let storyboard = self.getStoryboard("Main")
        self.controller = storyboard?.instantiateViewControllerWithIdentifier("loginController") as? LoginController
        
        self.controller?.view.hidden = false

        mockViewModel = PartialMockLoginViewModel(vm: self.controller!.viewModel! as! LoginViewModel, fakedUsers: getFakeUsers(), loginSucceeds: true)
        
        self.controller?.viewModel = mockViewModel
    }
    
    override func tearDown() {
        self.controller = nil
        super.tearDown()
    }
    
    func testLoginScreenDisplaysInitialized() {
        self.mockViewModel!.username = "system"
        self.mockViewModel!.password = "password"
        self.mockViewModel!.loginButtonLabel = "letmein"
        
        self.controller!.tableView.reloadData()

        XCTAssertTrue(self.controller != nil)
        XCTAssertTrue(self.controller!.numberOfSectionsInTableView(
            self.controller!.tableView) == 1)
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 3)

        let userCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        let userText = userCell?.viewWithTag(100) as? UITextField
        XCTAssertTrue(userText != nil)
        XCTAssertTrue(userText!.text == "system")
        
        let passCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        let passText = passCell?.viewWithTag(100) as? UITextField
        XCTAssertTrue(passText != nil)
        XCTAssertTrue(passText!.text == "password")
        
        let loginButtonCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
        let loginButton = loginButtonCell?.viewWithTag(100) as? UIButton
        XCTAssertTrue(loginButton != nil)
        XCTAssertTrue(loginButton!.titleForState(UIControlState.Normal) == "letmein")
    }
    
    func testLoginSuccess() {
        self.mockViewModel!.username = "system"
        self.mockViewModel!.password = "password"
        self.mockViewModel!.loginButtonLabel = "letmein"
        self.mockViewModel!.loginSucceeds = true
        
        self.controller!.tableView.reloadData()
        
        let loginButtonCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
        let loginButton = loginButtonCell?.viewWithTag(100) as? UIButton
        XCTAssertTrue(loginButton != nil)

        var segueCalled: String?
        self.controller!.performSegueWithIdentifierInterceptCallback = PerformSegueWithIdentifierInterceptCallbackWrapper({(identifier)->Bool in
            segueCalled = identifier
            self.called = true
            return false
        })
        loginButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(segueCalled == .Some("ShowUsers"))
    }
}