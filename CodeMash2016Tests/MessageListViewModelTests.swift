//
//  MessageListViewModelTests.swift
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

private let admin = User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(user: "admin", host: "desai.com"), image: nil)
private let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(user: "ravi", host: "desai.com"), image: nil)
private let users = [admin, ravi]
private let games = [Game(id: NSUUID(), title: "Glorantha", owner: admin.id!, users: [ravi.id!])]

private let message = Message(id: NSUUID(), from: admin.id!, to: nil, game: games[0].id!, subject: "test", message: "message", date: NSDate(timeIntervalSinceNow: 0))

class MockMessageCell: UITableViewCell {
    var message: Message?
    var users: [User]?
    
    init(message: Message?, users: [User]) {
        self.message = message
        self.users = users
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "messageCell")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class MessageListViewModelTests : AsynchronousTestCase {
    var vm: MessageListViewModel?
    var mockTableView = UITableView()
    var called = false
    var mockApi = MockApi()
    
    override func setUp() {
        super.setUp()
        
        self.vm = MessageListViewModel(cellInstantiator: { (myMessage, tableView, indexPath) -> UITableViewCell in
            return MockMessageCell(message: myMessage, users: users)
        })
        
        self.mockTableView.dataSource = self.vm
        
        Api.injectApiHandler(mockApi)
        
        self.vm?.setMessages(admin, game: games[0], users: users, messages: [message])
        self.called = false
    }
    
    override func tearDown() {
        self.vm = nil
        Api.resetApiHandler()
        super.tearDown()
    }
    
    func testInitialLoad() {
        XCTAssertTrue(self.vm!.isLoaded)
        XCTAssertTrue(self.vm!.numberOfSectionsInTableView(self.mockTableView) == 1)
        XCTAssertTrue(self.vm!.tableView(self.mockTableView, numberOfRowsInSection: 0) == 1)
        let cell = self.vm!.tableView(self.mockTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? MockMessageCell
        XCTAssertTrue(cell != nil)
        XCTAssertTrue(cell!.message == .Some(message))
        XCTAssertTrue(cell!.users! == users)
    }
}