//
//  TestModelEmailAddress.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/19/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDSerialization
@testable import CodeMash2016

class TestEmailAddress: XCTestCase {    
    func testSerializeAndDeserialize() {
        let addr = EmailAddress(user: "ravi", host: "desai.com")
        let json = addr.convertToJSON()
        XCTAssert(json.count == 2)
        
        let newAddr = EmailAddress.createFromJSON(json)
        XCTAssertTrue(newAddr != nil)
        XCTAssertTrue(addr == newAddr!)
    }
    
    func testConvertToEmailAddressSuccess() {
        let string = "ravi@desai.com"
        let addr = EmailAddress(string: string)
        XCTAssertTrue(addr != nil)
        XCTAssertTrue(addr! == EmailAddress(user: "ravi", host: "desai.com"))
    }

    func testConvertToEmailAddressFailure() {
        let string = "@desai.com"
        let addr = EmailAddress(string: string)
        XCTAssertTrue(addr == nil)
    }

    func testCollapsedEmailAddressString() {
        let result1 = EmailAddress.getCollapsedDisplayText([EmailAddress(user: "ravi", host: "desai.com")])
        XCTAssertTrue(result1 == "ravi@desai.com")
        
        let result2 = EmailAddress.getCollapsedDisplayText([EmailAddress(user: "ravi", host: "desai.com"), EmailAddress(user: "bonnie", host: "desai.com")])
        XCTAssertTrue(result2 == "ravi@desai.com and one other")
        
        let result3 = EmailAddress.getCollapsedDisplayText([EmailAddress(user: "ravi", host: "desai.com"), EmailAddress(user: "bonnie", host: "desai.com"), EmailAddress(user: "children", host: "desai.com")])
        XCTAssertTrue(result3 == "ravi@desai.com and 2 others")
    }
    
    func testSortingByHostThenUser() {
        let addresses = [
            EmailAddress(user: "martin", host: "clunes.com"),
            EmailAddress(user: "walker", host: "desai.com"),
            EmailAddress(user: "eric", host: "idle.com"),
            EmailAddress(user: "alexander", host: "desai.com"),
            EmailAddress(user: "emerson", host: "desai.com"),
            EmailAddress(user: "john", host: "cleese.com")
        ]
        
        let sortedAddresses = [
            EmailAddress(user: "john", host: "cleese.com"),
            EmailAddress(user: "martin", host: "clunes.com"),
            EmailAddress(user: "alexander", host: "desai.com"),
            EmailAddress(user: "emerson", host: "desai.com"),
            EmailAddress(user: "walker", host: "desai.com"),
            EmailAddress(user: "eric", host: "idle.com")
        ]
        
        XCTAssertTrue(addresses.sort(<) == sortedAddresses)
    }
    
    func testDescription() {
        let address = EmailAddress(user: "my.name", host: "my.cool.host.com")
        XCTAssertTrue(address.description == "my.name@my.cool.host.com")
        XCTAssertTrue("\(address)" == "my.name@my.cool.host.com")
    }
}