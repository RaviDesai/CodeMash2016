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

private var user1 = User(id: NSUUID(), name: "One", password: "pass", emailAddress: EmailAddress(user: "one", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberOne"))
private var user2 = User(id: NSUUID(), name: "Two", password: "pass", emailAddress: EmailAddress(user: "two", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberTwo"))
private var user3 = User(id: NSUUID(), name: "Three", password: "pass", emailAddress: EmailAddress(user: "three", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberThree"))
private var user4 = User(id: NSUUID(), name: "Four", password: "pass", emailAddress: EmailAddress(user: "four", host: "desai.com"), image: MockedRESTCalls.getImageWithName("NumberFour"))

private var game1 = Game(id: NSUUID(), title: "RuneQuest", owner: user1.id!, users: [user2.id!, user3.id!])
private var game2 = Game(id: NSUUID(), title: "ElfQuest", owner: user4.id!, users: [user1.id!, user3.id!])

class TestApiUsers: AsynchronousTestCase {
    var loginSite = APISite(name: "Sample", uri: "http://com.desai.sample/")
    var called = false
    var mockedRest: MockedRESTCalls?
    
    func getFakeUsers() -> [User] {
        return [user1, user2, user3, user4]
    }

    func getFakeGames() -> [Game] {
        return [ game1, game2 ]
    }
    
    override func setUp() {
        super.setUp()
        mockedRest = MockedRESTCalls(site: self.loginSite, initialUsers: getFakeUsers(), initialGames: getFakeGames(), initialMessages: [])
        mockedRest?.hijackAll()
        
        self.called = false
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
        let userToDelete = User(id: NSUUID(), name: "Not There", password: "pass", emailAddress: EmailAddress(user: "not", host: "there.com"), image: nil)
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