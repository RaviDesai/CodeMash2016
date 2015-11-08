//
//  LoginViewModelTests.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/7/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDTesting
import RSDRESTServices
import RSDSerialization
import OHHTTPStubs
@testable import CodeMash2016

class MockCell: UITableViewCell {
    var cellIdentifier: LoginTableCellIdentifier?
    var value: String?
    init(cellIdentifier: LoginTableCellIdentifier, value: String) {
        self.value = value
        self.cellIdentifier = cellIdentifier
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier.rawValue)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class LoginViewModelTests: AsynchronousTestCase {
    var vm: LoginViewModel?
    var mockTableView = UITableView()
    
    override func setUp() {
        self.vm = LoginViewModel(cellInstantiator: { (cellIdentifier, valueForCell, tableView, indexPath) -> UITableViewCell in
            return MockCell(cellIdentifier: cellIdentifier, value: valueForCell)
        })
        
        self.mockTableView.dataSource = self.vm
    }
    
    override func tearDown() {
        self.vm = nil
    }
    
    func testTableLayout() {
        XCTAssertTrue(self.vm!.numberOfSectionsInTableView(self.mockTableView) == 1)
        XCTAssertTrue(self.vm!.tableView(self.mockTableView, numberOfRowsInSection: 0) == 3)
        
        let userCell = self.vm!.tableView(self.mockTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? MockCell
        XCTAssertTrue(userCell != nil)
        XCTAssertTrue(userCell!.value == "admin")
        XCTAssertTrue(userCell!.cellIdentifier == LoginTableCellIdentifier.UsernameCell)

        let passwordCell = self.vm!.tableView(self.mockTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as? MockCell
        XCTAssertTrue(passwordCell != nil)
        XCTAssertTrue(passwordCell!.value == "admin")
        XCTAssertTrue(passwordCell!.cellIdentifier == LoginTableCellIdentifier.PasswordCell)

        let loginCell = self.vm!.tableView(self.mockTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)) as? MockCell
        XCTAssertTrue(loginCell != nil)
        XCTAssertTrue(loginCell!.value == "Login")
        XCTAssertTrue(loginCell!.cellIdentifier == LoginTableCellIdentifier.LoginCell)
    }
    
    func testSetUsername() {
        self.vm!.username = "user"
        
        let userCell = self.vm!.tableView(self.mockTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? MockCell
        XCTAssertTrue(userCell != nil)
        XCTAssertTrue(userCell!.value == "user")
        XCTAssertTrue(userCell!.cellIdentifier == LoginTableCellIdentifier.UsernameCell)
    }

    func testSetPassword() {
        self.vm!.password = "pa$$w0rd"
        
        let passwordCell = self.vm!.tableView(self.mockTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as? MockCell
        XCTAssertTrue(passwordCell != nil)
        XCTAssertTrue(passwordCell!.value == "pa$$w0rd")
        XCTAssertTrue(passwordCell!.cellIdentifier == LoginTableCellIdentifier.PasswordCell)
    }

    func testSetLogin() {
        self.vm!.loginButtonLabel = "Click Me"
        
        let loginCell = self.vm!.tableView(self.mockTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 0)) as? MockCell
        XCTAssertTrue(loginCell != nil)
        XCTAssertTrue(loginCell!.value == "Click Me")
        XCTAssertTrue(loginCell!.cellIdentifier == LoginTableCellIdentifier.LoginCell)
    }

}