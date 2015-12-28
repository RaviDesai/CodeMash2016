//
//  ControllerTestsBase.swift
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

private var loginUser = User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(user: "admin", host: "desai.com"), image: nil)
private var userOne = User(id: NSUUID(), name: "One", password: "pass", emailAddress: EmailAddress(user: "one", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberOne"))
private var userTwo = User(id: NSUUID(), name: "Two", password: "pass", emailAddress: EmailAddress(user: "two", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberTwo"))
private var userThree = User(id: NSUUID(), name: "Three", password: "pass", emailAddress: EmailAddress(user: "three", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberThree"))
private var userFour = User(id: NSUUID(), name: "Four", password: "pass", emailAddress: EmailAddress(user: "four", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberFour"))
private var gameDD = Game(id: NSUUID(), title: "D&D", owner: userOne.id!, users: [userTwo.id!, userFour.id!])
private var messageDDOne = Message(id: NSUUID(), from: userOne.id!, to: nil, game: gameDD.id!, subject: "What night?", message: "Friday or Sunday?", date: NSDate(timeIntervalSince1970: 10000))
private var messageDDTwo = Message(id: NSUUID(), from: userTwo.id!, to: nil, game: gameDD.id!, subject: "Re: What night?", message: "Friday is better", date: NSDate(timeIntervalSince1970: 20000))
private var messageDDThree = Message(id: NSUUID(), from: userFour.id!, to: nil, game: gameDD.id!, subject: "Re: What night?", message: "I like Friday too", date: NSDate(timeIntervalSince1970: 30000))
private var messageDDFour = Message(id: NSUUID(), from: userOne.id!, to: nil, game: gameDD.id!, subject: "Re: What night?", message: "Friday it is", date: NSDate(timeIntervalSince1970: 40000))

class ControllerTestsBase: AsynchronousTestCase {
    func getLoginUser() -> User {
        return User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(user: "admin", host: "desai.com"), image: nil)
    }
    
    func getFakeUsers() -> [User] {
        return [userOne, userTwo, userThree, userFour]
    }
    
    func getFakeGames() -> [Game] {
        return [gameDD]
    }
    
    func getFakeMessages(game: Game) -> [Message] {
        if (game == gameDD) {
            return [messageDDOne, messageDDTwo, messageDDThree, messageDDFour]
        }
        return []
    }
}