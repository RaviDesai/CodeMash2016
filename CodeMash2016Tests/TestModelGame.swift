//
//  TestModelGame.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/19/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDSerialization
import RSDRESTServices
@testable import CodeMash2016

class TestModelGame: XCTestCase {
    func testSerializeAndDeserializeWithNils() {
        let game = Game(id: nil, title: "Glorantha", owner: NSUUID(), users: nil)
        let json = game.convertToJSON()
        XCTAssert(json.count == 2)
        
        let newGame = Game.createFromJSON(json)
        XCTAssertTrue(newGame != nil)
        XCTAssertTrue(game == newGame!)
    }
    
    func testSerializeAndDeserialize() {
        let game = Game(id: NSUUID(), title: "Glorantha", owner: NSUUID(), users: [NSUUID(), NSUUID()])
        let json = game.convertToJSON()
        XCTAssert(json.count == 4)
        
        let newGame = Game.createFromJSON(json)
        XCTAssertTrue(newGame != nil)
        XCTAssertTrue(game == newGame!)
    }
    
    func testReadAuthorization() {
        let admin = User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(string: "admin@desai.com"), image: nil)
        let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(string: "ravi@desai.com"), image: nil)
        let other = User(id: NSUUID(), name: "Other", password: "pass", emailAddress: EmailAddress(string: "dude@dude.com"), image: nil)
        let nobody = User(id: NSUUID(), name: "Nobody", password: "pass", emailAddress: EmailAddress(string: "nobody@nowhere.com"), image: nil)
        let game = Game(id: NSUUID(), title: "Glorantha", owner: ravi.id!, users: [other.id!])
        XCTAssertTrue(game.isAuthorizedForReading(admin))
        XCTAssertTrue(game.isAuthorizedForReading(ravi))
        XCTAssertTrue(game.isAuthorizedForReading(other))
        XCTAssertTrue(!game.isAuthorizedForReading(nobody))
    }

    func testWriteAuthorization() {
        let admin = User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(string: "admin@desai.com"), image: nil)
        let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(string: "ravi@desai.com"), image: nil)
        let other = User(id: NSUUID(), name: "Other", password: "pass", emailAddress: EmailAddress(string: "dude@dude.com"), image: nil)
        let nobody = User(id: NSUUID(), name: "Nobody", password: "pass", emailAddress: EmailAddress(string: "nobody@nowhere.com"), image: nil)
        let game = Game(id: NSUUID(), title: "Glorantha", owner: ravi.id!, users: [other.id!])
        XCTAssertTrue(game.isAuthorizedForUpdating(admin))
        XCTAssertTrue(game.isAuthorizedForUpdating(ravi))
        XCTAssertTrue(!game.isAuthorizedForUpdating(other))
        XCTAssertTrue(!game.isAuthorizedForUpdating(nobody))
    }
    
    func testComparison() {
        let game1 = Game(id: NSUUID(), title: "Glorantha", owner: NSUUID(), users: [NSUUID(), NSUUID()])
        let game2 = Game(id: NSUUID(), title: "Ankh-Morpork", owner: NSUUID(), users: [NSUUID(), NSUUID()])
        let game3 = Game(id: NSUUID(), title: "R'lyeh", owner: NSUUID(), users: [NSUUID(), NSUUID(), NSUUID()])
        
        let games = [game3, game2, game1]
        XCTAssertTrue(games.sort(<) == [game2, game1, game3])
    }
    
    func testNonIDEquality() {
        let game1 = Game(id: NSUUID(), title: "Glorantha", owner: NSUUID(), users: [NSUUID(), NSUUID()])
        let game2 = Game(id: NSUUID(), title: "Glorantha", owner: game1.owner, users: [game1.users![0], game1.users![1]])
        let game3 = Game(id: game1.id, title: "R'lyeh", owner: game1.owner, users: [game1.users![0], game1.users![1]])
        
        XCTAssertTrue(game1 ==% game2)
        XCTAssertTrue(game1 == game3)
        XCTAssertFalse(game1 ==% game3)
    }
}
