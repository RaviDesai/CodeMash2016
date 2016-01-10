//
//  Client.swift
//
//  Created by Ravi Desai on 10/25/15.
//  Copyright (c) 2015 RSD. All rights reserved.
//

import Foundation
import RSDRESTServices

public class Client {
    public static var sharedClient = Client()
    
    public private(set) var session: APISession = APISession(configurationBlock: nil)
    public private(set) var authenticated = false
    public private(set) var site: APISite?
    
    private init() {}
    
    public func resetSession(site: APISite, configurationBlock: ((inout NSURLSessionConfiguration) -> ())?) {
        self.session.reset { () -> () in
            self.session = APISession(site: site, configurationBlock: configurationBlock)
            self.authenticated = false
        }
    }
    
    public func authenticate(site: APISite, username: String, password: String, completion: ((NSUUID?, NSError?) -> ())) {
        self.session = APISession(configurationBlock: nil)
        self.session.selectSite(site)
        self.authenticateUsingFedAuth(username, password: password, callback: completion)
    }
    
    public func setSite(site: APISite, authenticated: Bool) {
        self.site = site
        self.session.selectSite(site)
        self.authenticated = authenticated
    }
    
    private func authenticateUsingFedAuth(userName: String, password: String, callback: ((NSUUID?, NSError?) ->())) {
        let message = "Invalid username or password"
        let userInfo = [NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey: message];
        let authError = NSError(domain: "com.github.RaviDesai", code: 48118002, userInfo: userInfo)
        
        let parser = APIJSONSerializableResponseParser<LoginResponse>()
        let encoder = APIJSONBodyEncoder(model: LoginParameters(username: userName, password: password))
        let endpointUrl = URLAndParameters(url: "/api/authentication/authenticate")
        let endpoint = APIEndpoint.POST(endpointUrl)
        let request = APIRequest(baseURL: self.session.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: self.session, request: request)
        call.executeRespondWithObject { (loginResponse, error) -> () in
            if let params = loginResponse?.token, let message = loginResponse?.message, let userId = NSUUID(UUIDString: message) {
                let parser = APIObjectResponseParser<String>()
                let encoder = APIURLBodyEncoder(model: params)
                let endpointUrl = URLAndParameters(url:"/api/authentication/authenticationtoken")
                let endpoint = APIEndpoint.POST(endpointUrl)
                let request = APIRequest(baseURL: self.session.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: nil)
                let call = APICall(session: self.session, request: request)
                call.executeRespondWithObject({ (stringResult, error) -> () in
                    if (stringResult == .Some("success")) {
                        let endpointUrl = URLAndParameters(url:"/api/PostLogin/PostLoginChecks")
                        let endpoint = APIEndpoint.GET(endpointUrl)
                        let request = APIRequest(baseURL: self.session.baseURL, endpoint: endpoint, bodyEncoder: nil, responseParser: APIDataResponseParser(), additionalHeaders: nil)
                        let call = APICall(session: self.session, request: request)
                        call.execute({ (error) -> () in
                            if (error == nil) {
                                if let urlString = self.session.baseURL?.absoluteString {
                                    if let url = NSURL(string: urlString) {
                                        let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(url)
                                        let foundCheck: AnyObject? = cookies?.filter { $0.name == "PassedPostLoginChecks" && $0.value == "true" }.first
                                        if (foundCheck != nil) {
                                            self.authenticated = true
                                            callback(userId, nil)
                                            return
                                        }
                                    }
                                }
                                let message = "Please log into the webclient to finish security questions."
                                let userInfo = [NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey: message];
                                let cookieError = NSError(domain: "com.github.RaviDesai", code: 48118006, userInfo: userInfo)
                                callback(userId, cookieError)
                            } else {
                                callback(userId, error)
                            }
                        })
                    } else {
                        callback(userId, error ?? authError)
                    }
                })
            } else {
                callback(nil, error ?? authError)
            }
        }
    }
    
    
    public func call<U: APIResponseParserProtocol>(endpoint: APIEndpoint, encoder: APIBodyEncoderProtocol?, parser: U, additionalHeaders: [String: String]?) -> APICall<U> {
        let request = APIRequest(baseURL: self.session.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: additionalHeaders)
        return APICall(session: self.session, request: request)
    }
    
    
    public func logout(completion: (()->())) {
        self.authenticated = false
        self.session.reset(completion)
    }
    
}