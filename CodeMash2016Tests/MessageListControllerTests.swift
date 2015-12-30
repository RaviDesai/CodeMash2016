//
//  MessageListController.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/30/15.
//  Copyright © 2015 RSD. All rights reserved.
//


import UIKit
import XCTest
import RSDTesting
import RSDRESTServices
import RSDSerialization
import OHHTTPStubs
@testable import CodeMash2016

class MessageListControllerTests: ControllerTestsBase {
    var controller: MessageListController?
    var called = false
    
    func getStoryboard(name: String) -> UIStoryboard? {
        let storyboardBundle = NSBundle(forClass: MessageListController.classForCoder())
        return UIStoryboard(name: name, bundle: storyboardBundle)
    }
    
    class override func setUp() {
        super.setUp()
        Swizzler<MessageListController>.swizzleNavigationControllerProperty()
        Swizzler<MessageListController>.swizzlePresentViewControllerAnimated()
        SwizzlerForNavigationController.swizzlePopViewControllerAnimated()
    }
    
    class override func tearDown() {
        Swizzler<MessageListController>.swizzleNavigationControllerProperty()
        Swizzler<MessageListController>.swizzlePresentViewControllerAnimated()
        SwizzlerForNavigationController.swizzlePopViewControllerAnimated()
        super.tearDown()
    }
    
    override func setUp() {
        super.setUp()
        
        ActionFactory.Action = {(title: String, style: UIAlertActionStyle, handler: ((UIAlertAction)->()))->UIAlertAction in
            return MockAlertAction(title: title, style: style, handler: handler)
        }

        let storyboard = self.getStoryboard("Main")
        self.controller = storyboard?.instantiateViewControllerWithIdentifier("messageListController") as? MessageListController
        
        self.controller?.view.hidden = false
        
        self.called = false
    }
    
    override func tearDown() {
        ActionFactory.restoreDefault()
        self.controller = nil
        self.called = false
        super.tearDown()
    }
    
    func testInitialDisplay() {
        let game = self.getFakeGames()[0]
        let messages = self.getFakeMessages(game)
        let users = self.getFakeUsers()
        self.controller!.setMessages(self.getLoginUser(), game: game, users: users, messages: messages, error: nil)
        
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 4)
        let cell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? MessageCell
        
        XCTAssertTrue(cell!.message == messages[0])
        XCTAssertTrue(cell!.users! == users)
        let fromUser = users.filter { $0.id == messages[0].from }.first
        XCTAssertTrue(fromUser != nil)
        XCTAssertTrue(cell!.fromLabel.text == fromUser?.name)
        XCTAssertTrue(cell!.subjectLabel.text == messages[0].subject)
        XCTAssertTrue(cell!.dateLabel.text == messages[0].date.toLocalString())
        XCTAssertTrue(cell!.messageLabel.text == messages[0].message)
    }
    
    func testPopBackToCallerWithError() {
        let game = self.getFakeGames()[0]
        let messages = self.getFakeMessages(game)
        let users = self.getFakeUsers()
        let response = NetworkResponse.HTTPStatusCodeFailure(401, "unauthorized")
        let error = response.getError()

        let mockNavigator = UINavigationController()
        var popWasCalled = false
        mockNavigator.popViewControllerAnimatedInterceptCallback = PopViewControllerAnimatedInterceptCallbackWrapper({(animated) -> Bool in
            self.called = true
            popWasCalled = true
            return false
        })
        
        self.controller!.navigationControllerInterceptCallback = NavigationControllerInterceptCallbackWrapper({()->UINavigationController in
            return mockNavigator
        })
        
        var alertController: UIAlertController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated) -> Bool in
            alertController = viewController as? UIAlertController
            self.called = true
            return false
        })
        
        self.controller!.setMessages(self.getLoginUser(), game: game, users: users, messages: messages, error: error)
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(alertController != nil)
        
        self.called = false
        let action = alertController!.actions[0] as? MockAlertAction
        action!.call()
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(popWasCalled)
    }
}
