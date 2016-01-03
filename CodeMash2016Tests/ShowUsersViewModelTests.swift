//
//  ShowUsersViewModelTests.swift
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

class MockUserCell: UITableViewCell {
    var user: User?
    init(user: User?) {
        self.user = user
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "messageCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

private let admin = User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(user: "admin", host: "desai.com"), image: nil)
private let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(user: "ravi", host: "desai.com"), image: nil)
private let users = [admin, ravi]
private let games = [Game(id: NSUUID(), title: "Glorantha", owner: admin.id!, users: [ravi.id!])]

class ShowUsersViewModelTests: AsynchronousTestCase {
    var vm: ShowUsersViewModel?
    var mockTableView = UITableView()
    var called = false
    var mockApi = MockApi()

    override func setUp() {
        super.setUp()
        
        Api.injectApiHandler(mockApi)
        
        self.vm = ShowUsersViewModel(cellInstantiator: { (user, tableView, indexPath) -> UITableViewCell in
            return MockUserCell(user: user)
        })
        
        self.mockTableView.dataSource = self.vm
        
        self.vm?.loadData(users, loggedInUser: admin)
        self.called = false
    }
    
    override func tearDown() {
        self.vm = nil
        Api.resetApiHandler()
        super.tearDown()
    }
    
    func testLoad() {
        XCTAssertTrue(self.vm?.numberOfSectionsInTableView(self.mockTableView) == .Some(1))
        XCTAssertTrue(self.vm?.tableView(self.mockTableView, numberOfRowsInSection: 0) == .Some(2))
        
        let indexPath0 = NSIndexPath(forRow: 0, inSection: 0)
        let cell0 = self.vm?.tableView(self.mockTableView, cellForRowAtIndexPath: indexPath0) as? MockUserCell
        XCTAssertTrue(cell0 != nil)
        XCTAssertTrue(cell0?.user == self.vm?.getUserAtIndexPath(indexPath0))

        let indexPath1 = NSIndexPath(forRow: 1, inSection: 0)
        let cell1 = self.vm?.tableView(self.mockTableView, cellForRowAtIndexPath:indexPath1) as? MockUserCell
        XCTAssertTrue(cell1 != nil)
        XCTAssertTrue(cell1?.user == self.vm?.getUserAtIndexPath(indexPath1))
    }
    
    func testGetUser() {
        let user0 = self.vm!.getUserAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        let user1 = self.vm!.getUserAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        
        XCTAssertTrue(user0!.name == "Admin")
        XCTAssertTrue(user1!.name == "Ravi")
    }

    func testGetUserWithBadIndexPath() {
        let user = self.vm!.getUserAtIndexPath(NSIndexPath(forRow: 12, inSection: 0))
        
        XCTAssertTrue(user == nil)
    }

    func testUpdateUser() {
        var user = ravi
        user.name = "Ravindranath"
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        self.vm!.userWasUpdated(user, atIndexPath: indexPath)
        
        let testUser = self.vm?.getUserAtIndexPath(indexPath)
        XCTAssertTrue(user == testUser)
    }

    func testUpdateUserWithBadIndexPath() {
        var user = ravi
        user.name = "Ravindranath"
        let indexPath = NSIndexPath(forRow: 12, inSection: 0)
        self.vm!.userWasUpdated(user, atIndexPath: indexPath)
        
        let user0 = self.vm?.getUserAtIndexPath(NSIndexPath(forRow: 0, inSection: 0) )
        let user1 = self.vm?.getUserAtIndexPath(NSIndexPath(forRow: 1, inSection: 0) )
        XCTAssertTrue(user0!.name == "Admin")
        XCTAssertTrue(user1!.name == "Ravi")
    }
    
    func testDeleteUser() {
        XCTAssertTrue(self.vm!.totalUsers == 2)
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        self.vm!.userWasDeleted(indexPath)
        XCTAssertTrue(self.vm!.totalUsers == 1)
        XCTAssertTrue(self.vm!.getUserAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) == admin)
    }

    func testDeleteUserWithBadIndexPath() {
        XCTAssertTrue(self.vm!.totalUsers == 2)
        let indexPath = NSIndexPath(forRow: 12, inSection: 0)
        self.vm!.userWasDeleted(indexPath)
        XCTAssertTrue(self.vm!.totalUsers == 2)
    }
}