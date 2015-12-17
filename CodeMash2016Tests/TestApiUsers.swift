//
//  TestApiUsers.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/14/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDTesting
import RSDRESTServices
import RSDSerialization
import OHHTTPStubs
@testable import CodeMash2016


class TestApiUsers: AsynchronousTestCase {
    var loginSite = APISite(name: "Sample", uri: "http://com.desai.sample/")
    var called = false
    var mockedRest: MockedRESTCalls?
    
    func getFakeUsers() -> [User] {
        return [
            User(id: NSUUID(), name: "One", password: "pass", emailAddress: EmailAddress(user: "one", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberOne")),
            User(id: NSUUID(), name: "Two", password: "pass", emailAddress: EmailAddress(user: "two", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberTwo")),
            User(id: NSUUID(), name: "Three", password: "pass", emailAddress: EmailAddress(user: "three", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberThree")),
            User(id: NSUUID(), name: "Four", password: "pass", emailAddress: EmailAddress(user: "four", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberFour"))]
    }

    func getFakeGames() -> [Game] {
        var users = getFakeUsers()
        return [
            Game(id: NSUUID(), title: "RuneQuest", owner: users[0], users: [users[1], users[2]]),
            Game(id: NSUUID(), title: "ElfQuest", owner: users[3], users: [users[0], users[2]])
        ]
    }
    
    override func setUp() {
        super.setUp()
        mockedRest = MockedRESTCalls(site: self.loginSite, initialUsers: getFakeUsers(), initialGames: getFakeGames(), initialMessages: [])
        self.called = false
        mockedRest?.hijackAll()
        
        Client.sharedClient.authenticate(self.loginSite, username: "One", password: "pass", completion: { (nsuuid, error) -> () in
            if (error == nil) {
                self.called = true
            }
        })
        
        XCTAssertTrue(self.waitForResponse { self.called })
        self.called = false
    }
    
    override func tearDown() {
        self.called = false
        mockedRest?.unhijackAll()
        mockedRest = nil
        super.tearDown()
    }
    
    private func usersFromStore() -> [User]? {
        return self.mockedRest?.userStore.store.sort()
    }
    
    func testGetAllUsers() {
        var resultUsers: [User]?
        var resultError: NSError?
        
        Api.sharedInstance.getAllUsers { (users, error) -> () in
            resultUsers = users
            resultError = error;
            self.called = true
        }

        XCTAssertTrue(self.waitForResponse { self.called });
        
        XCTAssertTrue(resultUsers != nil);
        XCTAssertTrue(resultError == nil);
        XCTAssertTrue(resultUsers! == self.usersFromStore()!)
    }
    
    func testDeleteUserSuccess() {
        let initialCount = self.usersFromStore()!.count
        XCTAssertTrue(initialCount >= 4)
        let userToDelete = self.usersFromStore()![1]
        var resultUser: User?
        var resultError: NSError?
        
        Api.sharedInstance.deleteUser(userToDelete) { (user, error) -> () in
            resultUser = user
            resultError = error;
            self.called = true
        }
        
        XCTAssertTrue(self.waitForResponse { self.called });
        
        XCTAssertTrue(resultUser != nil);
        XCTAssertTrue(resultError == nil);
        XCTAssertTrue(resultUser! == userToDelete)
        
        let afterCount = self.usersFromStore()!.count
        XCTAssertTrue(afterCount == initialCount - 1)
    }
    
    func testDeleteUserFail() {
        let initialCount = self.usersFromStore()!.count
        XCTAssertTrue(initialCount >= 4)
        let userToDelete = User(id: NSUUID(), name: "Not There", password: "pass", emailAddress: EmailAddress(user: "not", host: "there.com", displayValue: "not there, dude"), image: nil)
        var resultUser: User?
        var resultError: NSError?
        
        Api.sharedInstance.deleteUser(userToDelete) { (user, error) -> () in
            resultUser = user
            resultError = error;
            self.called = true
        }
        
        XCTAssertTrue(self.waitForResponse { self.called });
        
        XCTAssertTrue(resultUser == nil);
        XCTAssertTrue(resultError != nil);
        
        let afterCount = self.usersFromStore()!.count
        XCTAssertTrue(afterCount == initialCount)
        
    }
    
    func testSaveUserSuccess() {
        let initialCount = self.usersFromStore()!.count
        XCTAssertTrue(initialCount >= 4)
        var userToUpdate = self.usersFromStore()![1]
        userToUpdate.name = "Jordy"
        var resultUser: User?
        var resultError: NSError?
        
        Api.sharedInstance.saveUser(userToUpdate) { (user, error) -> () in
            resultUser = user
            resultError = error;
            self.called = true
        }
        
        XCTAssertTrue(self.waitForResponse { self.called });
        
        XCTAssertTrue(resultUser != nil);
        XCTAssertTrue(resultError == nil);
        XCTAssertTrue(resultUser! == userToUpdate)
        XCTAssertTrue(self.usersFromStore()!.filter { $0.name == "Jordy" }.first != nil)
        
        let afterCount = self.usersFromStore()!.count
        XCTAssertTrue(afterCount == initialCount)
    }
}