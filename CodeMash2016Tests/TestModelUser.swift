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
}
