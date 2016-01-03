//
//  TestBox.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/31/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDSerialization
import RSDRESTServices
import ObjectiveC
@testable import CodeMash2016

private var testBoxingHandle: UInt8 = 0

class TestBoxing: XCTestCase {
    func testBoxUser() {
        let user = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(string: "ravi@desai.com"), image: MockedRESTCalls.getImageWithName("NumberOne"))
        let box = Box(user)
        
        let o = NSObject()
        objc_setAssociatedObject(o, &testBoxingHandle, box, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        
        let p = objc_getAssociatedObject(o, &testBoxingHandle) as! Box<User>
        
        XCTAssertTrue(p.description == "Ravi")
        let unboxedUser = p.unbox
        XCTAssertTrue(user == unboxedUser)
 
        let box2 = Box(unboxedUser)
        XCTAssertFalse(box === box2)
        XCTAssertTrue(box == box2)
    }
}