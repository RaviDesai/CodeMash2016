//
//  TestModelUser.swift
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

class TestModelUser: XCTestCase {
    func testSerializeAndDeserializeWithNils() {
        let user = User(id: nil, name: "ravi", password: "pass", emailAddress: nil, image: nil)
        let json = user.convertToJSON()
        XCTAssert(json.count == 2)
        
        let newUser = User.createFromJSON(json)
        XCTAssertTrue(newUser != nil)
        XCTAssertTrue(user == newUser!)
    }
    
    func testSerializeAndDeserialize() {
        let user = User(id: NSUUID(), name: "ravi", password: "pass", emailAddress: EmailAddress(user: "ravi", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberOne"))
        let json = user.convertToJSON()
        XCTAssert(json.count == 5)
        
        let newUser = User.createFromJSON(json)
        XCTAssertTrue(newUser != nil)
        XCTAssertTrue(user == newUser!)
    }
    
    func testComparison() {
        let user1 = User(id: NSUUID(), name: "Stafford", password: "pass", emailAddress: EmailAddress(string: "stafford@chaosium.com"), image: nil)
        let user2 = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(string: "ravi@desai.com"), image: nil)
        let user3 = User(id: NSUUID(), name: "Gygax", password: "pass", emailAddress: EmailAddress(string: "gygax@tsr.com"), image: nil)
        
        let users = [user1, user2, user3]
        
        XCTAssertTrue(users.sort(<) == [user3, user2, user1])
    }
    
    func testNonIDEquality() {
        let user1 = User(id: NSUUID(), name: "Stafford", password: "pass", emailAddress: EmailAddress(string: "stafford@chaosium.com"), image: nil)
        let user2 = User(id: NSUUID(), name: "Stafford", password: "pass", emailAddress: EmailAddress(string: "stafford@chaosium.com"), image: nil)
        let user3 = User(id: user1.id, name: "Gygax", password: "pass", emailAddress: EmailAddress(string: "gygax@tsr.com"), image: nil)
        
        XCTAssertTrue(user1 ==% user2)
        XCTAssertTrue(user1 == user3)
        XCTAssertFalse(user1 ==% user3)
    }
    
    func testReadAuthorization() {
        let admin = User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(string: "admin@desai.com"), image: nil)
        let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(string: "ravi@desai.com"), image: nil)
        let other = User(id: NSUUID(), name: "Other", password: "pass", emailAddress: EmailAddress(string: "other@desai.com"), image: nil)
        
        XCTAssertTrue(ravi.isAuthorizedForReading(admin))
        XCTAssertTrue(ravi.isAuthorizedForReading(ravi))
        XCTAssertTrue(ravi.isAuthorizedForReading(other))
    }

    func testWriteAuthorization() {
        let admin = User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(string: "admin@desai.com"), image: nil)
        let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(string: "ravi@desai.com"), image: nil)
        let other = User(id: NSUUID(), name: "Other", password: "pass", emailAddress: EmailAddress(string: "other@desai.com"), image: nil)
        
        XCTAssertTrue(ravi.isAuthorizedForUpdating(admin))
        XCTAssertTrue(ravi.isAuthorizedForUpdating(ravi))
        XCTAssertFalse(ravi.isAuthorizedForUpdating(other))
    }
}
