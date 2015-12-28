//
//  TestModelMessage.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/21/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDSerialization
import RSDRESTServices
@testable import CodeMash2016

class TestModelMessage: XCTestCase {
    func testSerializeAndDeserializeWithNils() {
        let game = Game(id: NSUUID(), title: "Glorantha", owner: NSUUID(), users: nil)
        let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(string: "ravi@desai.com"), image: nil)
        
        let message = Message(id: nil, from: ravi.id!, to: nil, game: game.id!, subject: "Hello", message: "There you!", date: NSDate())
        let json = message.convertToJSON()
        XCTAssert(json.count == 5)
        
        let newMessage = Message.createFromJSON(json)
        XCTAssertTrue(newMessage != nil)
        XCTAssertTrue(message == newMessage!)
    }
    
    func testSerializeAndDeserialize() {
        let game = Game(id: NSUUID(), title: "Glorantha", owner: NSUUID(), users: nil)
        let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(string: "ravi@desai.com"), image: nil)
        let other = User(id: NSUUID(), name: "Other", password: "pass", emailAddress: EmailAddress(string: "other@desai.com"), image: nil)
        
        let message = Message(id: NSUUID(), from: ravi.id!, to: [other.id!], game: game.id!, subject: "Hello", message: "There you!", date: NSDate())
        let json = message.convertToJSON()
        XCTAssert(json.count == 7)
        
        let newMessage = Message.createFromJSON(json)
        XCTAssertTrue(newMessage != nil)
        XCTAssertTrue(message == newMessage!)
    }
    
    func testReadAuthorization() {
        let admin = User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(string: "admin@desai.com"), image: nil)
        let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(string: "ravi@desai.com"), image: nil)
        let other = User(id: NSUUID(), name: "Other", password: "pass", emailAddress: EmailAddress(string: "other@desai.com"), image: nil)
        let another = User(id: NSUUID(), name: "Another", password: "pass", emailAddress: EmailAddress(string: "another@desai.com"), image: nil)
        let game = Game(id: NSUUID(), title: "Glorantha", owner: ravi.id!, users: [other.id!])
        let message = Message(id: NSUUID(), from: ravi.id!, to: [other.id!], game: game.id!, subject: "Hello", message: "There you!", date: NSDate())
        
        XCTAssertTrue(message.isAuthorizedForReading([game], authuser: admin))
        XCTAssertTrue(message.isAuthorizedForReading([game], authuser: ravi))
        XCTAssertTrue(message.isAuthorizedForReading([game], authuser: other))
        XCTAssertFalse(message.isAuthorizedForReading([game], authuser: another))
    }
    
    func testWriteAuthorization() {
        let admin = User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(string: "admin@desai.com"), image: nil)
        let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(string: "ravi@desai.com"), image: nil)
        let other = User(id: NSUUID(), name: "Other", password: "pass", emailAddress: EmailAddress(string: "other@desai.com"), image: nil)
        let another = User(id: NSUUID(), name: "Another", password: "pass", emailAddress: EmailAddress(string: "another@desai.com"), image: nil)
        let game = Game(id: NSUUID(), title: "Glorantha", owner: ravi.id!, users: [other.id!])
        let message = Message(id: NSUUID(), from: ravi.id!, to: [other.id!], game: game.id!, subject: "Hello", message: "There you!", date: NSDate())
        
        XCTAssertTrue(message.isAuthorizedForUpdating(admin))
        XCTAssertTrue(message.isAuthorizedForUpdating(ravi))
        XCTAssertFalse(message.isAuthorizedForUpdating(other))
        XCTAssertFalse(message.isAuthorizedForUpdating(another))
    }
    
    func testComparison() {
        let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(string: "ravi@desai.com"), image: nil)
        let other = User(id: NSUUID(), name: "Other", password: "pass", emailAddress: EmailAddress(string: "other@desai.com"), image: nil)
        let game = Game(id: NSUUID(), title: "Glorantha", owner: ravi.id!, users: [other.id!])
        let message1 = Message(id: NSUUID(), from: ravi.id!, to: [other.id!], game: game.id!, subject: "Hello", message: "There you!", date: NSDate(timeIntervalSinceNow: -30000))
        let message2 = Message(id: NSUUID(), from: ravi.id!, to: [other.id!], game: game.id!, subject: "Hello again", message: "There you!", date: NSDate(timeIntervalSinceNow: -20000))
        let message3 = Message(id: NSUUID(), from: ravi.id!, to: [other.id!], game: game.id!, subject: "Hello again again", message: "There you!", date: NSDate(timeIntervalSinceNow: -10000))
        
        let messages = [message3, message1, message2]
        XCTAssertTrue(messages.sort(<) == [message1, message2, message3])
    }
    
    func testNonIDEquality() {
        
    }

}