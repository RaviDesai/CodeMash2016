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
    var loginSite = APISite(name: "Sample", uri: "http://com.desai.sample/")
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
    
    func testLogin() {
        mockedRest?.hijackAll()
        
        var returnedError: NSError?
        
        Client.sharedClient.authenticate(self.loginSite, username: "Admin", password: "Admin", completion: { (nsuuid, error) -> () in
            self.called = true
            returnedError = error
        })
        
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(returnedError == nil)
    }
}