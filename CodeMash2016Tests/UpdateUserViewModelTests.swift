//
//  UpdateUserViewModelTests.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/29/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDTesting
import RSDRESTServices
import RSDSerialization
import OHHTTPStubs
@testable import CodeMash2016

class MockUpdateUserApi: MockApi {
    var mockUser: User?
    var mockError: NSError?
    
    override func createUser(user: User, completionHandler: (User?, NSError?) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            completionHandler(self.mockUser, self.mockError)
        })
    }
    
    override func saveUser(user: User, completionHandler: (User?, NSError?) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            completionHandler(self.mockUser, self.mockError)
        })
    }
    
    override func deleteUser(user: User, completionHandler: (User?, NSError?) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            completionHandler(self.mockUser, self.mockError)
        })
    }
}

private let admin = User(id: NSUUID(), name: "Admin", password: "pass", emailAddress: EmailAddress(user: "admin", host: "desai.com"), image: nil)
private let ravi = User(id: NSUUID(), name: "Ravi", password: "pass", emailAddress: EmailAddress(user: "ravi", host: "desai.com"), image: nil)
private let newguy = User(id: nil, name: "Newbie", password: "pass", emailAddress: nil, image: nil)
private let fakeUserInfo = [NSLocalizedDescriptionKey: "Faked Error", NSLocalizedFailureReasonErrorKey: "Faked Error"]
private let fakeError = NSError(domain: "com.careevolution.direct", code: 48103001, userInfo: fakeUserInfo)


class UpdateUserViewModelTests: AsynchronousTestCase {
    var vm: UpdateUserViewModel?
    var called = false
    var mockApi = MockUpdateUserApi()
    
    override func setUp() {
        super.setUp()
        
        Api.injectApiHandler(mockApi)
        
        self.vm = UpdateUserViewModel()
        
        self.vm?.setUser(ravi, loggedInUser: admin)
        self.called = false
    }
    
    override func tearDown() {
        self.vm = nil
        Api.resetApiHandler()
        super.tearDown()
    }
    
    func testLoadedRavi() {
        XCTAssertTrue(self.vm!.canBeUpdated)
        XCTAssertTrue(self.vm!.contactName == "Ravi")
        XCTAssertTrue(self.vm!.contactAddress == "ravi@desai.com")
        XCTAssertTrue(self.vm!.contactImage == nil)
        XCTAssertTrue(self.vm!.uuidString == ravi.id?.compressedUUIDString)
        XCTAssertFalse(self.vm!.hasInformationChanged)
        XCTAssertTrue(self.vm!.hasValidEmailAddress)
    }

    func testLoadedNewbie() {
        self.vm!.setUser(newguy, loggedInUser: admin)
        XCTAssertTrue(self.vm!.canBeUpdated)
        XCTAssertTrue(self.vm!.contactName == "Newbie")
        XCTAssertTrue(self.vm!.contactAddress == nil)
        XCTAssertTrue(self.vm!.contactImage == nil)
        XCTAssertTrue(self.vm!.uuidString == nil)
        XCTAssertFalse(self.vm!.hasInformationChanged)
        XCTAssertFalse(self.vm!.hasValidEmailAddress)
    }
    
    func testUpdateAndSaveSuccess() {
        self.vm!.contactAddress = "rsd@gmail.com"
        XCTAssertTrue(self.vm!.hasInformationChanged)
        let updatedUser = self.vm!.user
        self.mockApi.mockUser = updatedUser
        self.mockApi.mockError = nil
        
        var returnedUser: User?
        var returnedError: NSError?
        var wasOnMainThread = false
        self.vm!.saveUser { (user, error) -> () in
            returnedUser = user
            returnedError = error
            wasOnMainThread = NSThread.isMainThread()
            self.called = true
        }
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(wasOnMainThread)
        XCTAssertTrue(returnedUser != nil)
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedUser == updatedUser)
    }

    func testUpdateAndSaveFailure() {
        self.vm!.contactAddress = "rsd@gmail.com"
        XCTAssertTrue(self.vm!.hasInformationChanged)
        self.mockApi.mockUser = nil
        self.mockApi.mockError = fakeError
        
        var returnedUser: User?
        var returnedError: NSError?
        var wasOnMainThread = false
        self.vm!.saveUser { (user, error) -> () in
            returnedUser = user
            returnedError = error
            wasOnMainThread = NSThread.isMainThread()
            self.called = true
        }
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(wasOnMainThread)
        XCTAssertTrue(returnedUser == nil)
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(self.vm!.hasInformationChanged)
    }

    
    func testDeleteSuccess() {
        var returnedUser: User?
        var returnedError: NSError?
        var wasOnMainThread = false
        self.mockApi.mockUser = ravi
        self.mockApi.mockError = nil
        
        self.vm!.deleteUser { (user, error) -> () in
            returnedUser = user
            returnedError = error
            wasOnMainThread = NSThread.isMainThread()
            self.called = true
        }
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(wasOnMainThread)
        XCTAssertTrue(returnedUser == ravi)
        XCTAssertTrue(returnedError == nil)
    }

    func testDeleteFailure() {
        var returnedUser: User?
        var returnedError: NSError?
        var wasOnMainThread = false
        self.mockApi.mockUser = nil
        self.mockApi.mockError = fakeError
        
        self.vm!.deleteUser { (user, error) -> () in
            returnedUser = user
            returnedError = error
            wasOnMainThread = NSThread.isMainThread()
            self.called = true
        }
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(wasOnMainThread)
        XCTAssertTrue(returnedUser == nil)
        XCTAssertTrue(returnedError != nil)
    }
    
    func testCreateSuccess() {
        self.vm!.setUser(newguy, loggedInUser: admin)
        self.vm!.contactAddress = "newbie@desai.com"
        
        var createdUser = self.vm!.user
        createdUser!.id = NSUUID()
        self.mockApi.mockUser = createdUser
        self.mockApi.mockError = nil
        
        var returnedUser: User?
        var returnedError: NSError?
        var wasOnMainThread = false
        self.vm!.createUser { (user, error) -> () in
            returnedUser = user
            returnedError = error
            wasOnMainThread = NSThread.isMainThread()
            self.called = true
        }
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(wasOnMainThread)
        XCTAssertTrue(returnedUser == createdUser)
        XCTAssertTrue(returnedError == nil)
    }
    
    func testCreateFailure() {
        self.vm!.setUser(newguy, loggedInUser: admin)
        self.vm!.contactAddress = "newbie@desai.com"
        
        self.mockApi.mockUser =  nil
        self.mockApi.mockError = fakeError
        
        var returnedUser: User?
        var returnedError: NSError?
        var wasOnMainThread = false
        self.vm!.createUser { (user, error) -> () in
            returnedUser = user
            returnedError = error
            wasOnMainThread = NSThread.isMainThread()
            self.called = true
        }
        
        XCTAssertTrue(self.waitForResponse { self.called })
        XCTAssertTrue(wasOnMainThread)
        XCTAssertTrue(returnedUser == nil)
        XCTAssertTrue(returnedError != nil)
    }

}
