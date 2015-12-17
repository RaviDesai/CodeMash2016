//
//  TestShowUsersViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/16/15.
//  Copyright © 2015 RSD. All rights reserved.
//
import UIKit
import XCTest
import RSDTesting
import RSDRESTServices
import RSDSerialization
import OHHTTPStubs
@testable import CodeMash2016

class MockMessageCell: UITableViewCell {
    var title: String?
    var name: String?
    init(title: String?, name: String?) {
        self.title = title
        self.name = name
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "messageCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class MockMessagesApi: MockApi {
    var messages: [Message]
    init(messages: [Message]) {
        self.messages = messages
    }
    
    override func getMessagesForGame(game: Game, completionHandler: ([Message]?, NSError?) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            completionHandler(self.messages, nil)
        })
    }
}

private let admin = User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(user: "admin", host: "desai.com", displayValue: "Admin"), image: nil)
private let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(user: "ravi", host: "desai.com", displayValue: "Ravi"), image: nil)
private let games = [Game(id: NSUUID(), title: "Glorantha", owner: admin, users: [ravi])]

private let message = Message(id: NSUUID(), from: admin, to: nil, game: games[0], subject: "test", message: "message", date: NSDate(timeIntervalSinceNow: 0))

class GamesViewModelTests: AsynchronousTestCase {
    var vm: GamesViewModel?
    var mockTableView = UITableView()
    var called = false
    
    let mockApi = MockMessagesApi(messages: [message])
    
    override func setUp() {
        super.setUp()
        
        self.vm = GamesViewModel(cellInstantiator: { (title, name, tableView, indexPath) -> UITableViewCell in
            return MockMessageCell(title: title, name: name)
        })
        
        self.mockTableView.dataSource = self.vm
        
        Api.injectApiHandler(mockApi)
        
        self.vm?.setCurrentUserAndGames(admin, games: games)
        self.called = false
    }
    
    override func tearDown() {
        self.vm = nil
        Api.resetApiHandler()
        super.tearDown()
    }
    
    func testGamesGetMessages() {
        var resultMessages: [Message]?
        var resultError: NSError?
        var wasOnMainThead: Bool? = nil
        self.vm?.getMessagesForGame(NSIndexPath(forRow: 0, inSection: 0), completionHandler: { (messages, error) -> () in
            resultMessages = messages
            resultError = error
            wasOnMainThead = NSThread.isMainThread()
            self.called = true
        })
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(wasOnMainThead == .Some(true))
        XCTAssertTrue(resultMessages != nil)
        XCTAssertTrue(resultError == nil)
    }
}