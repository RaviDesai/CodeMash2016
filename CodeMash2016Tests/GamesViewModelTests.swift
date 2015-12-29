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

class MockGameCell: UITableViewCell {
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

class MockGamesApi: MockApi {
    var messages: [Message]?
    var createdGame: Game?
    var mockError: NSError?
    
    override func getMessagesForGame(game: Game, completionHandler: ([Message]?, NSError?) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            completionHandler(self.messages, self.mockError)
        })
    }
    
    override func createGame(game: Game, completionHandler: (Game?, NSError?) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            completionHandler(self.createdGame, self.mockError)
        })
    }
    
    override func deleteGame(game: Game, completionHandler: (NSError?) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            completionHandler(self.mockError)
        })
    }
}

private let admin = User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(user: "admin", host: "desai.com"), image: nil)
private let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(user: "ravi", host: "desai.com"), image: nil)
private let users = [admin, ravi]
private let games = [Game(id: NSUUID(), title: "Glorantha", owner: admin.id!, users: [ravi.id!])]

private let message = Message(id: NSUUID(), from: admin.id!, to: nil, game: games[0].id!, subject: "test", message: "message", date: NSDate(timeIntervalSinceNow: 0))
private let message2 = Message(id: NSUUID(), from: admin.id!, to: nil, game: games[0].id!, subject: "test2", message: "message2", date: NSDate(timeIntervalSinceNow: 0))
private let message3 = Message(id: NSUUID(), from: admin.id!, to: nil, game: games[0].id!, subject: "test3", message: "message3", date: NSDate(timeIntervalSinceNow: 0))

class GamesViewModelTests: AsynchronousTestCase {
    var vm: GamesViewModel?
    var mockTableView = UITableView()
    var called = false
    var mockApi = MockGamesApi()
    
    override func setUp() {
        super.setUp()
        
        self.vm = GamesViewModel(cellInstantiator: { (title, name, tableView, indexPath) -> UITableViewCell in
            return MockGameCell(title: title, name: name)
        })
        
        self.mockTableView.dataSource = self.vm
        
        Api.injectApiHandler(mockApi)
        
        self.vm?.setCurrentUserAndGames(admin, games: games, users: users)
        self.called = false
    }
    
    override func tearDown() {
        self.vm = nil
        Api.resetApiHandler()
        super.tearDown()
    }
    
    func testLoad() {
        XCTAssertTrue(self.vm?.numberOfSectionsInTableView(self.mockTableView) == .Some(1))
        XCTAssertTrue(self.vm?.tableView(self.mockTableView, numberOfRowsInSection: 0) == .Some(1))
        
        let cell = self.vm?.tableView(self.mockTableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? MockGameCell
        XCTAssertTrue(cell != nil)
        XCTAssertTrue(cell?.title == .Some("Glorantha"))
        XCTAssertTrue(cell?.name == .Some("Admin"))
    }
    
    func testGetMessages() {
        self.mockApi.messages = [message]
        self.mockApi.mockError = nil
        
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
    
    func testCreateGameSuccess() {
        XCTAssertTrue(self.vm!.totalGames == 1)

        let gameToCreate = Game(id: nil, title: "NewGame", owner: ravi.id!, users: [admin.id!])
        var createdGame = gameToCreate
        createdGame.id = NSUUID()
        self.mockApi.createdGame = createdGame
        self.mockApi.mockError = nil
        
        var resultGame: Game?
        var resultError: NSError?
        var wasOnMainThread: Bool?
        
        self.vm?.createGame(gameToCreate, completionHandler: { (game, error) -> () in
            resultGame = game
            resultError = error
            wasOnMainThread = NSThread.isMainThread()
            self.called = true
        })
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(wasOnMainThread == .Some(true))
        XCTAssertTrue(resultGame != nil)
        XCTAssertTrue(resultError == nil)
        
        XCTAssertTrue(self.vm!.totalGames == 2)
    }

    func testCreateGameFailure() {
        XCTAssertTrue(self.vm!.totalGames == 1)

        let fakeUserInfo = [NSLocalizedDescriptionKey: "Faked Error", NSLocalizedFailureReasonErrorKey: "Faked Error"]
        let fakeError = NSError(domain: "com.careevolution.direct", code: 48103001, userInfo: fakeUserInfo)

        let gameToCreate = Game(id: nil, title: "NewGame", owner: ravi.id!, users: [admin.id!])
        var createdGame = gameToCreate
        createdGame.id = NSUUID()
        self.mockApi.createdGame = nil
        self.mockApi.mockError = fakeError
        
        var resultGame: Game?
        var resultError: NSError?
        var wasOnMainThread: Bool?
        
        self.vm?.createGame(gameToCreate, completionHandler: { (game, error) -> () in
            resultGame = game
            resultError = error
            wasOnMainThread = NSThread.isMainThread()
            self.called = true
        })
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(wasOnMainThread == .Some(true))
        XCTAssertTrue(resultGame == nil)
        XCTAssertTrue(resultError != nil)
        
        XCTAssertTrue(self.vm!.totalGames == 1)
    }

    
    func testDeleteGameSuccess() {
        XCTAssertTrue(self.vm!.totalGames == 1)
        self.mockApi.mockError = nil
        
        var resultError: NSError?
        var wasOnMainThread: Bool?
        
        self.vm?.deleteGameAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), completionHandler: { (error) -> () in
            resultError = error
            wasOnMainThread = NSThread.isMainThread()
            self.called = true
        })
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(wasOnMainThread == .Some(true))
        XCTAssertTrue(resultError == nil)
        XCTAssertTrue(self.vm!.totalGames == 0)
    }
    
    func testDeleteGameFailure() {
        let fakeUserInfo = [NSLocalizedDescriptionKey: "Faked Error", NSLocalizedFailureReasonErrorKey: "Faked Error"]
        let fakeError = NSError(domain: "com.careevolution.direct", code: 48103001, userInfo: fakeUserInfo)

        XCTAssertTrue(self.vm!.totalGames == 1)
        self.mockApi.mockError = fakeError
        
        var resultError: NSError?
        var wasOnMainThread: Bool?
        
        self.vm?.deleteGameAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), completionHandler: { (error) -> () in
            resultError = error
            wasOnMainThread = NSThread.isMainThread()
            self.called = true
        })
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(wasOnMainThread == .Some(true))
        XCTAssertTrue(resultError != nil)
        XCTAssertTrue(self.vm!.totalGames == 1)
    }
    
}