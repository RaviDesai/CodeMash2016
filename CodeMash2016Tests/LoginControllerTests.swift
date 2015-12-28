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
    
    func getLoginUser() -> User {
        return User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(user: "admin", host: "desai.com"), image: nil)
    }
    
    func getFakeUsers() -> [User] {
        return [
            User(id: NSUUID(), name: "One", password: "pass", emailAddress: EmailAddress(user: "one", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberOne")),
            User(id: NSUUID(), name: "Two", password: "pass", emailAddress: EmailAddress(user: "two", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberTwo")),
            User(id: NSUUID(), name: "Three", password: "pass", emailAddress: EmailAddress(user: "three", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberThree")),
            User(id: NSUUID(), name: "Four", password: "pass", emailAddress: EmailAddress(user: "four", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberFourxr"))]
    }
    
    func getFakeGames() -> [Game] {
        let users = getFakeUsers()
        return [Game(id: NSUUID(), title: "D&D", owner: users[0].id!, users: [users[1].id!, users[3].id!])]
    }
    
    class override func setUp() {
        super.setUp()
        Swizzler<LoginController>.swizzlePrepareForSegue()
        Swizzler<LoginController>.swizzlePerformSegueWithIdentifier()
        Swizzler<LoginController>.swizzlePresentViewControllerAnimated()
    }

    class override func tearDown() {
        Swizzler<LoginController>.swizzlePrepareForSegue()
        Swizzler<LoginController>.swizzlePerformSegueWithIdentifier()
        Swizzler<LoginController>.swizzlePresentViewControllerAnimated()
        super.tearDown()
    }
    
    override func setUp() {
        super.setUp()
        let storyboard = self.getStoryboard("Main")
        self.controller = storyboard?.instantiateViewControllerWithIdentifier("loginController") as? LoginController
        
        self.controller?.view.hidden = false

        mockViewModel = PartialMockLoginViewModel(vm: self.controller!.viewModel! as! LoginViewModel)
        
        self.controller?.viewModel = mockViewModel
        self.called = false
    }
    
    override func tearDown() {
        self.controller = nil
        self.called = false
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
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 4)

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
    
    func testLoginSuccessNoSegue() {
        self.mockViewModel!.username = "system"
        self.mockViewModel!.password = "password"
        self.mockViewModel!.loginButtonLabel = "letmein"
        self.mockViewModel!.loginCallback = {() -> (User?, NSError?) in
            return (self.getLoginUser(), nil)
        }
        
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
        XCTAssertTrue(segueCalled == .Some("TabController"))
    }

    func testLoginSuccessWithSegue() {
        self.mockViewModel!.username = "system"
        self.mockViewModel!.password = "password"
        self.mockViewModel!.loginButtonLabel = "letmein"
        self.mockViewModel!.loginCallback = {() -> (User?, NSError?) in
            return (self.getLoginUser(), nil)
        }
        self.mockViewModel!.getAllUsersCallback = {() -> ([User]?, NSError?) in
            return (self.getFakeUsers(), nil)
        }
        self.mockViewModel!.getAllGamesCallback = {() -> ([Game]?, NSError?) in
            return (self.getFakeGames(), nil)
        }
        
        self.controller!.tableView.reloadData()
        
        let loginButtonCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
        let loginButton = loginButtonCell?.viewWithTag(100) as? UIButton
        XCTAssertTrue(loginButton != nil)
        
        var tabController: TabController?
        self.controller!.prepareForSegueInterceptCallback = PrepareForSegueInterceptCallbackWrapper({(segue)->Bool in
            tabController = segue.destinationViewController as? TabController
            self.called = true
            return true
        })
        
        loginButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(tabController != nil)
        
        XCTAssertTrue(self.waitForResponse { tabController!.viewControllers?.count == .Some(2) })

        let showUsersController = tabController!.viewControllers![0] as? ShowUsersController
        let gamesController = tabController!.viewControllers![1] as? GamesController
        XCTAssertTrue(showUsersController != nil)
        XCTAssertTrue(gamesController != nil)
        
        tabController!.view.hidden = false
        
        XCTAssertTrue(gamesController!.viewModel != nil)
        XCTAssertTrue(showUsersController!.viewModel != nil)
        
        let showUsersViewModel = showUsersController!.viewModel
        let gamesViewModel = gamesController!.viewModel
        XCTAssertTrue(showUsersViewModel != nil)
        XCTAssertTrue(gamesViewModel != nil)
        XCTAssertTrue(showUsersViewModel!.totalUsers == 4)
        XCTAssertTrue(gamesViewModel!.totalGames == 1)
                
        XCTAssertTrue(tabController!.title == "Users")
        tabController!.selectedViewController = gamesController
        tabController!.tabBarController(tabController!, didSelectViewController: gamesController!)
        XCTAssertTrue(tabController!.title == "Games")
    }

    func testLoginFailureUnauthorized() {
        self.mockViewModel!.username = "system"
        self.mockViewModel!.password = "password"
        self.mockViewModel!.loginButtonLabel = "letmein"
        self.mockViewModel!.loginCallback = {() -> (User?, NSError?) in
            return (nil, self.mockViewModel!.generateError(401, message: "unauthorized"))
        }
        
        self.controller!.tableView.reloadData()
        
        let loginButtonCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
        let loginButton = loginButtonCell?.viewWithTag(100) as? UIButton
        XCTAssertTrue(loginButton != nil)
        
        var alertView: UIViewController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated) -> Bool in
            alertView = viewController
            self.called = true
            return false
        })
        
        loginButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(alertView != nil)
        let alertController = alertView as? UIAlertController
        XCTAssertTrue(alertController != nil)
        XCTAssertTrue(alertController!.message == .Some("You will be logged off."))
    }
    
    func testCreateUserCausesSegue() {
        self.controller!.tableView.reloadData()

        let createUserButtonCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))
        let createUserButton = createUserButtonCell?.viewWithTag(100) as? UIButton
        XCTAssertTrue(createUserButton != nil)

        var segueIdentifier: String?
        self.controller?.prepareForSegueInterceptCallback = PrepareForSegueInterceptCallbackWrapper({(segue) -> Bool in
            segueIdentifier = segue.identifier
            self.called = true
            return false
        })
        
        createUserButton!.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(segueIdentifier == "CreateUser")
    }
}