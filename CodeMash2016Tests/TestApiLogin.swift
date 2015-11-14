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
    var mockedRest = MockedRESTLogin(site: APISite(name: "Sample", uri: "http://com.desai.sample/"), validLogin: LoginParameters(username: "Admin", password: "Admin"))
    
    override func setUp() {
        super.setUp()
        self.called = false
    }
    
    override func tearDown() {
        self.called = false
        OHHTTPStubs.removeAllStubs();
        
        super.tearDown()
    }
    
    func testLogin() {
        mockedRest.hijackAll()
        
        var returnedError: NSError?
        
        Client.sharedClient.authenticate(self.loginSite, username: "Admin", password: "Admin", completion: { (error) -> () in
            self.called = true
            returnedError = error
        })
        
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(returnedError == nil)
    }
}