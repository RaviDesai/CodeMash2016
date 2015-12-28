//
//  TestApi.swift
//  RSDTesting
//
//  Created by Ravi Desai on 10/25/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDTesting
import RSDRESTServices
import RSDSerialization
import OHHTTPStubs
@testable import CodeMash2016


class TestApiLogin: AsynchronousTestCase {
    var loginSite = APISite(name: "Sample", uri: "http://sample.desai.com/")
    var called = false
    let initialUsers = [User(id: NSUUID(), name: "Admin", password: "Admin", emailAddress: EmailAddress(user: "admin", host: "desai.com"), image: nil)]
    var mockedRest: MockedRESTLogin?
    
    override func setUp() {
        super.setUp()
        self.mockedRest = MockedRESTLogin(site: loginSite, usersStore: MockedUsersStore(host: loginSite.uri?.host, endpoint: "/api/users", initialValues: initialUsers), userLoginChange: {(user)->() in })
        self.called = false
    }
    
    override func tearDown() {
        self.called = false
        self.mockedRest?.unhijackAll()
        self.mockedRest = nil
        
        super.tearDown()
    }
    
    func testLoginSuccess() {
        mockedRest?.hijackAll()
        
        var returnedError: NSError?
        var returnedUserUUID: NSUUID?
        Client.sharedClient.authenticate(self.loginSite, username: "Admin", password: "Admin", completion: { (nsuuid, error) -> () in
            returnedError = error
            returnedUserUUID = nsuuid
            self.called = true
        })
        
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedUserUUID != nil)
    }
    
    func testLoginFailure() {
        mockedRest?.hijackAll()
        
        var returnedError: NSError?
        var returnedUserUUID: NSUUID?
        Client.sharedClient.authenticate(self.loginSite, username: "Bad", password: "wolf", completion: { (nsuuid, error) -> () in
            returnedError = error
            returnedUserUUID = nsuuid
            self.called = true
        })
        
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedUserUUID == nil)
    }
}