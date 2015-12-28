//
//  TestApiGames.swift
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

private var user0 = User(id: NSUUID(), name: "One", password: "pass", emailAddress: EmailAddress(user: "one", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberOne"))
private var user1 = User(id: NSUUID(), name: "Two", password: "pass", emailAddress: EmailAddress(user: "two", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberTwo"))
private var user2 = User(id: NSUUID(), name: "Three", password: "pass", emailAddress: EmailAddress(user: "three", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberThree"))
private var user3 = User(id: NSUUID(), name: "Four", password: "pass", emailAddress: EmailAddress(user: "four", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberFour"))

private var game0 = Game(id: NSUUID(), title: "RuneQuest", owner: user0.id!, users: [user1.id!, user2.id!])
private var game1 = Game(id: NSUUID(), title: "ElfQuest", owner: user3.id!, users: [user0.id!, user2.id!])

private var mess0 = Message(id: NSUUID(), from: game0.owner, to: nil, game: game0.id!, subject: "hello", message: "hey all", date: NSDate(timeIntervalSince1970: 10000))
private var mess1 = Message(id: NSUUID(), from: game0.users![0], to: nil, game: game0.id!, subject: "hello", message: "what up?", date: NSDate(timeIntervalSince1970: 20000))
private var mess2 = Message(id: NSUUID(), from: game0.users![1], to: nil, game: game0.id!, subject: "hello", message: "the sky!", date: NSDate(timeIntervalSince1970: 30000))
private var mess3 = Message(id: NSUUID(), from: game1.owner, to: nil, game: game1.id!, subject: "hello", message: "first msg for EQ", date: NSDate(timeIntervalSince1970: 40000))
private var mess4 = Message(id: NSUUID(), from: game1.users![0], to: nil, game: game1.id!, subject: "hello", message: "second msg for EQ", date: NSDate(timeIntervalSince1970: 50000))
private var mess5 = Message(id: NSUUID(), from: game1.users![1], to: nil, game: game1.id!, subject: "hello", message: "third msg for EQ", date: NSDate(timeIntervalSince1970: 50000))


class TestApiGames: AsynchronousTestCase {
    var loginSite = APISite(name: "Sample", uri: "http://com.desai.sample/")
    var called = false
    var mockedRest: MockedRESTCalls?
    
    func getFakeUsers() -> [User] {
        return [user0, user1, user2, user3]
    }
    
    func getFakeGames() -> [Game] {
        return [ game0, game1 ]
    }
    
    func getFakeMessages() -> [Message] {
        return [ mess0, mess1, mess2, mess3, mess4, mess5]
    }
    
    override func setUp() {
        super.setUp()
        mockedRest = MockedRESTCalls(site: self.loginSite, initialUsers: getFakeUsers(), initialGames: getFakeGames(), initialMessages: getFakeMessages())
        self.called = false
        mockedRest?.hijackAll()
        
        Client.sharedClient.authenticate(self.loginSite, username: "One", password: "pass", completion: { (nsuuid, error) -> () in
            if (error == nil) {
                self.called = true
            }
        })
        
        XCTAssertTrue(self.waitForResponse { self.called })
        self.called = false
    }
    
    override func tearDown() {
        self.called = false
        mockedRest?.unhijackAll()
        mockedRest = nil
        super.tearDown()
    }
    
    private func gamesFromStore() -> [Game]? {
        return self.mockedRest?.gamesStore.store.sort()
    }
    
    func testGetAllGames() {
        var resultGames: [Game]?
        var resultError: NSError?
        
        Api.sharedInstance.getAllGames(user0){(games, error) -> () in
            resultGames = games
            resultError = error;
            self.called = true
        }
        
        XCTAssertTrue(self.waitForResponse { self.called });
        
        XCTAssertTrue(resultGames != nil);
        XCTAssertTrue(resultError == nil);
        XCTAssertTrue(resultGames! == self.gamesFromStore()!)
    }

    func testCreateGame() {
        XCTAssertTrue(self.mockedRest!.gamesStore.store.count == 2)
        var resultGame: Game?
        var resultError: NSError?
        let gameToCreate = Game(id: nil, title: "NewGame", owner: user0.id!, users: [user1.id!])
        
        Api.sharedInstance.createGame(gameToCreate) { (game, error) -> () in
            resultGame = game
            resultError = error
            self.called = true
        }

        XCTAssertTrue(self.waitForResponse { self.called })
        
        XCTAssertTrue(resultGame != nil);
        XCTAssertTrue(resultError == nil);
        XCTAssertTrue(resultGame! ==% gameToCreate)
        XCTAssertTrue(resultGame!.id != nil)
        XCTAssertTrue(self.mockedRest!.gamesStore.store.count == 3)
    }
    
    func testDeleteGame() {
        XCTAssertTrue(self.mockedRest!.gamesStore.store.count == 2)
        var resultError: NSError?
        let gameToDelete = game0
        
        Api.sharedInstance.deleteGame(gameToDelete) { (error) -> () in
            resultError = error
            self.called = true
        }
        
        XCTAssertTrue(self.waitForResponse { self.called })
        
        XCTAssertTrue(resultError == nil)
        XCTAssertTrue(self.mockedRest!.gamesStore.store.count == 1)
    }
    
    func testGetMessagesForGame() {
        var resultError: NSError?
        var resultMessages: [Message]?
        
        Api.sharedInstance.getMessagesForGame(game0) { (messages, error) -> () in
            resultMessages = messages
            resultError = error
            self.called = true
        }
        
        XCTAssertTrue(self.waitForResponse { self.called })
        
        XCTAssertTrue(resultError == nil)
        XCTAssertTrue(resultMessages?.count == .Some(3))
    }

}
