//
//  ShowUsersControllerTests.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDTesting
import RSDRESTServices
import RSDSerialization
import OHHTTPStubs
@testable import CodeMash2016

class ShowUsersControllerTests: ControllerTestsBase {
    var controller: ShowUsersController?
    var called = false

    func getStoryboard(name: String) -> UIStoryboard? {
        let storyboardBundle = NSBundle(forClass: ShowUsersController.classForCoder())
        return UIStoryboard(name: name, bundle: storyboardBundle)
    }
    
    class override func setUp() {
        super.setUp()
        Swizzler<ShowUsersController>.swizzlePrepareForSegue()
        Swizzler<ShowUsersController>.swizzlePresentViewControllerAnimated()
        Swizzler<ShowUsersController>.swizzleDismissViewControllerAnimated()
    }
    
    class override func tearDown() {
        Swizzler<ShowUsersController>.swizzlePrepareForSegue()
        Swizzler<ShowUsersController>.swizzlePresentViewControllerAnimated()
        Swizzler<ShowUsersController>.swizzleDismissViewControllerAnimated()
        
        super.tearDown()
    }
    
    override func setUp() {
        super.setUp()
        let storyboard = self.getStoryboard("Main")
        self.controller = storyboard?.instantiateViewControllerWithIdentifier("showUsersController") as? ShowUsersController
        
        self.controller?.view.hidden = false
        
        self.called = false
    }
    
    override func tearDown() {
        self.controller = nil
        self.called = false
        super.tearDown()
    }
    
    func testInitialDisplay() {
        self.controller!.loadData(self.getFakeUsers(), loggedInUser: self.getLoginUser())
        
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 5)
        var userCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? UserTableViewCell
        XCTAssertTrue(userCell != nil)
        XCTAssertTrue(userCell?.nameLabel?.text == .Some("Admin"))
        
        userCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? UserTableViewCell
        XCTAssertTrue(userCell != nil)
        XCTAssertTrue(userCell?.nameLabel?.text == .Some("One"))

        userCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as? UserTableViewCell
        XCTAssertTrue(userCell != nil)
        XCTAssertTrue(userCell?.nameLabel?.text == .Some("Two"))

        userCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as? UserTableViewCell
        XCTAssertTrue(userCell != nil)
        XCTAssertTrue(userCell?.nameLabel?.text == .Some("Three"))

        userCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0)) as? UserTableViewCell
        XCTAssertTrue(userCell != nil)
        XCTAssertTrue(userCell?.nameLabel?.text == .Some("Four"))
    }

    func causeSegueToUpdateUserController(indexPath: NSIndexPath) -> (UpdateUserController?, User?) {
        var updateUserController: UpdateUserController?
        self.controller!.prepareForSegueInterceptCallback = PrepareForSegueInterceptCallbackWrapper({(segue) -> Bool in
            updateUserController = segue.destinationViewController as? UpdateUserController
            return true
        })
        
        let userAtIndexPath = self.controller!.viewModel!.getUserAtIndexPath(indexPath)
        self.controller!.tableView!.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        
        self.controller!.performSegueWithIdentifier("ModifyUser", sender: self.controller!)
        return (updateUserController, userAtIndexPath)
    }
    
    func testModifyUserCausesSegueToUpdateScreen() {
        self.controller!.loadData(self.getFakeUsers(), loggedInUser: self.getLoginUser())

        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let (updateUserController, userAtIndexPath) = self.causeSegueToUpdateUserController(indexPath)
        
        XCTAssertTrue(updateUserController != nil)
        XCTAssertTrue(updateUserController!.viewModel!.user == userAtIndexPath)
    }

    func testModifyUserThenIssueDelete() {
        self.controller!.loadData(self.getFakeUsers(), loggedInUser: self.getLoginUser())
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 5)
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let (updateUserController, userAtIndexPath) = self.causeSegueToUpdateUserController(indexPath)
        
        XCTAssertTrue(updateUserController != nil)
        XCTAssertTrue(updateUserController!.viewModel!.user == userAtIndexPath)
        updateUserController!.userModificationHandler?(.Deleted, userAtIndexPath)
        
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 4)
    }
    
    func testModifyUsersThenIssueUpdate() {
        self.controller!.loadData(self.getFakeUsers(), loggedInUser: self.getLoginUser())
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 5)
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let (updateUserController, userAtIndexPath) = causeSegueToUpdateUserController(indexPath)
        
        XCTAssertTrue(updateUserController != nil)
        XCTAssertTrue(updateUserController!.viewModel!.user == userAtIndexPath)
        var updateToUserAtIndexPath = userAtIndexPath
        updateToUserAtIndexPath!.emailAddress = EmailAddress(string: "updated@address.info")
        updateUserController!.userModificationHandler?(.Saved, updateToUserAtIndexPath)
        
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 5)
        let updateTest = self.controller!.viewModel!.getUserAtIndexPath(indexPath)
        XCTAssertTrue(updateToUserAtIndexPath == updateTest)
    }


}
