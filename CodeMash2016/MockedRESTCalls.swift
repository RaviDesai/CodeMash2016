//
//  File.swift
//  RSDTesting
//
//  Created by Ravi Desai on 10/25/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import RSDRESTServices
import RSDSerialization
import OHHTTPStubs

public class MockedRESTCalls {
    var users: [User]?
    var host: String?
    
    public init() {
        self.users = [
            User(id: NSUUID(), name: "One", emailAddress: EmailAddress(user: "one", host: "desai.com", displayValue: nil)/*, image: nil*/),
            User(id: NSUUID(), name: "Two", emailAddress: EmailAddress(user: "two", host: "desai.com", displayValue: nil)/*, image: nil*/),
            User(id: NSUUID(), name: "Three", emailAddress: EmailAddress(user: "three", host: "desai.com", displayValue: nil)/*, image: nil*/),
            User(id: NSUUID(), name: "Four", emailAddress: EmailAddress(user: "four", host: "desai.com", displayValue: nil)/*, image: nil*/)]
    }
    
    static func sampleAuthenticateData() -> NSData {
        return "{\"Success\":true,\"Message\":null,\"Parameters\":{\"wa\":\"wsignin1.0\",\"wresult\":\"<crazyweirdxml></crazyweirdxml>\"}}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
    
    static func sampleAuthenticationTokenData() -> NSData {
        return "\"success\"".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
    
    func findUserIndex(user: User) -> Int? {
        if let users = self.users {
            var index: Int = 0
            for (index = 0; index < users.count; index++) {
                if (users[index] == user) {
                    return index
                }
            }
        }
        return nil
    }

    func findUserIdIndex(id: NSUUID) -> Int? {
        if let users = self.users {
            var index: Int = 0
            for (index = 0; index < users.count; index++) {
                if (users[index].id == id) {
                    return index
                }
            }
        }
        return nil
    }

    func updateUser(user: User) -> Bool {
        if let index = self.findUserIndex(user) {
            self.users![index] = user
            return true
        }
        return false
    }
    
    func deleteUser(requestId: String) -> User? {
        if let uuid = NSUUID(UUIDString: requestId) {
            if let index = findUserIdIndex(uuid) {
                return self.users!.removeAtIndex(index)
            }
        }
        return nil
    }
    
    public func hijackLoginSequence(loginSite: APISite, validLoginParameters: LoginParameters) {
        self.host = loginSite.uri?.host
        
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != self.host) {
                return false
            }
            if (request.URL?.path != .Some("/api/authentication/authenticate")) {
                return false
            }
            if (request.HTTPMethod != "POST") {
                return false
            }
            let requestData = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData
            if (requestData == nil) {
                return false
            }
            
            return true
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
            if let requestData = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData {
                if let json = try? NSJSONSerialization.JSONObjectWithData(requestData, options: NSJSONReadingOptions.AllowFragments) {
                    if let login = LoginParameters.createFromJSON(json) {
                        if login == validLoginParameters {
                            let response = MockedRESTCalls.sampleAuthenticateData()
                            return OHHTTPStubsResponse(data: response, statusCode: 200, headers: ["Content-Type": "application/json"])
                        }
                    }
                }
            }
            return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 401, headers: nil)
        })
        
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != self.host) {
                return false
            }
            if (request.URL?.path != .Some("/api/authentication/authenticationtoken")) {
                return false
            }
            if (request.HTTPMethod != "POST") {
                return false
            }
            let contentType = request.allHTTPHeaderFields?["Content-Type"]
            if (contentType != .Some("application/x-www-form-urlencoded")) {
                return false
            }
            let requestData = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData
            if (requestData == nil) {
                return false
            }
            return true
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
            let response = MockedRESTCalls.sampleAuthenticationTokenData()
            return OHHTTPStubsResponse(data: response, statusCode: 200, headers: ["Content-Type": "text/plain"])
        })
        
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != self.host) {
                return false
            }
            if (request.URL?.path != .Some("/api/PostLogin/PostLoginChecks")) {
                return false
            }
            if (request.HTTPMethod != "GET") {
                return false
            }
            
            return true
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                let expiryDate = NSDate(timeIntervalSinceNow: 2629743)
                let myhost: String = self.host ?? ""
                let cookieProperties: [String: AnyObject] = [NSHTTPCookieValue: "true", NSHTTPCookieName: "PassedPostLoginChecks", NSHTTPCookiePath: "/", NSHTTPCookieDomain: myhost, NSHTTPCookieOriginURL: myhost, NSHTTPCookieExpires: expiryDate]
                let cookie = NSHTTPCookie(properties: cookieProperties)
                let mockedCookies = [cookie!]
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(mockedCookies, forURL: loginSite.uri, mainDocumentURL: nil)
                
                let postedCheckData = "<!DOCTYPE html><html><body><p>weird html page</p></body></html>".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                return OHHTTPStubsResponse(data: postedCheckData, statusCode: 200, headers: ["Content-Type": "text/html"])
        })
        
    }
    
    public func hijackGetUsers() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != self.host) {
                return false
            }
            if (request.URL?.path != .Some("/api/users")) {
                return false
            }
            if (request.HTTPMethod != "GET") {
                return false
            }
            
            return true
            
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
            if let users = self.users,
                let json = convertToJSONArray(users) {
                    do {
                        let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted)
                        return OHHTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json"])
                    } catch let error as NSError {
                        return OHHTTPStubsResponse(error: error)
                    }
            }
            return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 500, headers: nil)
        })
    }

    public func hijackUpdateUser() {
        let queryPattern = "/api/users/(.+)$"
        let regEx = try? NSRegularExpression(pattern: queryPattern, options: NSRegularExpressionOptions.CaseInsensitive)

        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != self.host) {
                return false
            }
            
            var userId: String?
            if let path = request.URL?.path {
                if let matches = regEx?.matchesInString(path, options: NSMatchingOptions(), range: NSMakeRange(0, path.characters.count)) {
                    if (matches.count > 0) {
                        userId = path.substringWithRange(matches[0].rangeAtIndex(1))
                    }
                }
            }
            
            if (userId == nil || userId!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "") {
                return false
            }
            
            if (request.URL?.path != .Some("/api/users")) {
                return false
            }
            if (request.HTTPMethod != "PUT") {
                return false
            }
            
            let requestData = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData
            if (requestData == nil) {
                return false
            }

            return true
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
            if let requestData = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData {
                if let json = try? NSJSONSerialization.JSONObjectWithData(requestData, options: NSJSONReadingOptions.AllowFragments) {
                    if let user = User.createFromJSON(json) {
                        if (self.updateUser(user)) {
                            return OHHTTPStubsResponse(data: requestData, statusCode: 200, headers: ["Content-Type": "application/json"])
                        } else {
                            return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 404, headers: nil)
                        }
                    }
                }
                return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 500, headers: nil)
            }
            return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 400, headers: nil)
        })
    }

    public func hijackDeleteUser() {
        let queryPattern = "/api/users/(.+)$"
        let regEx = try? NSRegularExpression(pattern: queryPattern, options: NSRegularExpressionOptions.CaseInsensitive)
        
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != self.host) {
                return false
            }
            
            var userId: String?
            if let path = request.URL?.path {
                if let matches = regEx?.matchesInString(path, options: NSMatchingOptions(), range: NSMakeRange(0, path.characters.count)) {
                    if (matches.count > 0) {
                        userId = path.substringWithRange(matches[0].rangeAtIndex(1))
                    }
                }
            }
            
            if (userId == nil || userId!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "") {
                return false
            }
            
            if (request.HTTPMethod != "DELETE") {
                return false
            }
                        
            return true
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
            var userId: String?
            if let path = request.URL?.path {
                if let matches = regEx?.matchesInString(path, options: NSMatchingOptions(), range: NSMakeRange(0, path.characters.count)) {
                    if (matches.count > 0) {
                        userId = path.substringWithRange(matches[0].rangeAtIndex(1))
                    }
                }
            }

            if let requestId = userId {
                if let deletedUser = self.deleteUser(requestId) {
                    let json = deletedUser.convertToJSON()
                    if let data = try? NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted) {
                        return OHHTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json"])
                    }
                } else {
                    return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 404, headers: nil)
                }
                
                return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 500, headers: nil)
            }
            return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 400, headers: nil)
        })
    }

    public func hijackAll(site: APISite, validLogin: LoginParameters) {
        self.hijackLoginSequence(site, validLoginParameters: validLogin)
        self.hijackGetUsers()
        self.hijackUpdateUser()
        self.hijackDeleteUser()
    }
    
    deinit {
        OHHTTPStubs.removeAllStubs()
    }
}