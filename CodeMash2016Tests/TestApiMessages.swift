//
//  TestMockedMessageStore.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/15/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDTesting
import RSDRESTServices
import RSDSerialization
import OHHTTPStubs
import RSDRESTServices
@testable import CodeMash2016

private let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(user: "ravi", host: "desai.com", displayValue: "Ravi Desai"), image: nil)
private let xander = User(id: NSUUID(), name: "Xander", password: "pass", emailAddress: EmailAddress(user: "xander", host: "desai.com", displayValue: "Xander Desai"), image: nil)
private let emerson = User(id: NSUUID(), name: "Emerson", password: "pass", emailAddress: EmailAddress(user: "emerson", host: "desai.com", displayValue: "Emerson Desai"), image: nil)
private let walker = User(id: NSUUID(), name: "Walker", password: "pass", emailAddress: EmailAddress(user: "walker", host: "desai.com", displayValue: "Walker Desai"), image: nil)
private let rq2 = Game(id: NSUUID(), title: "RQ2", owner: ravi, users: [walker, xander])
private let dd = Game(id: NSUUID(), title: "D&D", owner: walker, users: [ravi, emerson])

private let rq1Message = Message(id: NSUUID(), from: ravi, to: nil, game: rq2, subject: "Supplies", message: "Need paper and pencils", date: NSDate(timeIntervalSince1970: 0))
private let dd1Message = Message(id: NSUUID(), from: walker, to: nil, game: dd, subject: "Next Session", message: "on wednesday", date: NSDate(timeIntervalSince1970: 200000))

class TestApiMessages: AsynchronousTestCase {
    
    var loginSite = APISite(name: "Sample", uri: "https://com.desai.sample/")
    var called = false
    var mockedRest: MockedRESTCalls?

    override func setUp() {
        super.setUp()
        mockedRest = MockedRESTCalls(site: self.loginSite, initialUsers: [ravi,xander,emerson,walker], initialGames: [rq2,dd], initialMessages: [rq1Message, dd1Message])
        self.called = false
        mockedRest?.hijackAll()
        
        Client.sharedClient.authenticate(self.loginSite, username: "ravi", password: "pass", completion: { (nsuuid, error) -> () in
            if (error == nil) {
                self.called = true
            }
        })
        
        XCTAssertTrue(self.waitForResponse { self.called })
        self.called = false
    }
    
    override func tearDown() {
        super.tearDown()
        mockedRest?.unhijackAll()
    }
    
    func testGetRq2Messages() {
        
        self.called = false
        var returnedMessages: [Message]?
        var returnedError: NSError?
        Api.sharedInstance.getMessagesForGame(rq2, completionHandler: {(messages, error) -> () in
            returnedMessages = messages
            returnedError = error
            self.called = true
        })
        
        XCTAssertTrue(self.waitForResponse{ self.called })
        
        XCTAssertTrue(returnedMessages != nil)
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedMessages!.count == 1)
    }
}