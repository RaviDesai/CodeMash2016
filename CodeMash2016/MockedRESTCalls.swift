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


public class MockedRESTLogin {
    public var host: String?
    public var site: APISite
    public var loginParameters: LoginParameters
    
    private var authStub: OHHTTPStubsDescriptor?
    private var tokenStub: OHHTTPStubsDescriptor?
    private var postStub: OHHTTPStubsDescriptor?

    
    public init(site: APISite, validLogin: LoginParameters) {
        self.site = site
        self.loginParameters = validLogin
    }
    
    private static func sampleAuthenticateData() -> NSData {
        return "{\"Success\":true,\"Message\":null,\"Parameters\":{\"wa\":\"wsignin1.0\",\"wresult\":\"<crazyweirdxml></crazyweirdxml>\"}}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
    
    private static func sampleAuthenticationTokenData() -> NSData {
        return "\"success\"".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }

    private func hijackLoginSequence(loginSite: APISite, validLoginParameters: LoginParameters) {
        self.host = loginSite.uri?.host
        
        self.authStub =
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
                                let response = MockedRESTLogin.sampleAuthenticateData()
                                return OHHTTPStubsResponse(data: response, statusCode: 200, headers: ["Content-Type": "application/json"])
                            }
                        }
                    }
                }
                return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 401, headers: nil)
        })
        
        self.tokenStub =
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
                let response = MockedRESTLogin.sampleAuthenticationTokenData()
                return OHHTTPStubsResponse(data: response, statusCode: 200, headers: ["Content-Type": "text/plain"])
        })
        
        self.postStub =
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

    public func hijackAll() {
        self.hijackLoginSequence(self.site, validLoginParameters: self.loginParameters)
    }
    
    public func unhijackAll() {
        if let authStub = self.authStub {
            OHHTTPStubs.removeStub(authStub)
            self.authStub = nil
        }
        if let tokenStub = self.authStub {
            OHHTTPStubs.removeStub(tokenStub)
            self.tokenStub = nil
        }
        if let postStub = self.authStub {
            OHHTTPStubs.removeStub(postStub)
            self.postStub = nil
        }
    }
    
    deinit {
        unhijackAll()
    }
}

class MockedRESTCalls {
    var userStore: MockedRESTStore<User>?
    var loginStore: MockedRESTLogin?
    
    init(site: APISite, validLogin: LoginParameters) {
        self.loginStore = MockedRESTLogin(site: site, validLogin: validLogin)

        self.userStore = MockedRESTStore(host: site.uri?.host, endpoint: "/api/users", initialValues: [
            User(id: NSUUID(), name: "One", emailAddress: EmailAddress(user: "one", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberOne")),
            User(id: NSUUID(), name: "Two", emailAddress: EmailAddress(user: "two", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberTwo")),
            User(id: NSUUID(), name: "Three", emailAddress: EmailAddress(user: "three", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberThree")),
            User(id: NSUUID(), name: "Four", emailAddress: EmailAddress(user: "four", host: "desai.com", displayValue: nil), image: MockedRESTCalls.getImageWithName("NumberFourxr"))])
        
    }
    
    static func getImageWithName(name: String) -> UIImage? {
        let myBundle = NSBundle(forClass: self)
        if let jsonFilePath = myBundle.pathForResource(name, ofType: "jpeg") {
            if let data = NSData(contentsOfFile: jsonFilePath) {
                return UIImage(data: data)
            }
        }
        return nil
    }

    func hijackAll() {
        self.loginStore?.hijackAll()
        self.userStore?.hijackAll()
    }
    
    func unhijackAll() {
        self.loginStore?.unhijackAll()
        self.userStore?.unhijackAll()
    }
    
    deinit {
        self.loginStore = nil
        self.userStore = nil
    }
}