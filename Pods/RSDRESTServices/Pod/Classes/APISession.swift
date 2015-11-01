//
//  AOISession.swift
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 RSD. All rights reserved.
//

import Foundation

public class APISession {
    public private(set) var baseURL : NSURL?
    public private(set) var session: NSURLSession
    public private(set) var selectedSite: APISite?
    private var sessionConfig: NSURLSessionConfiguration
    
    static let DefaultTimeoutIntervalForRequest = NSTimeInterval(30)
    
    public convenience init(site: APISite?, configurationBlock: ((inout NSURLSessionConfiguration) -> ())?) {
        self.init(configurationBlock: configurationBlock)
        self.selectSite(site)
    }
    
    public init(configurationBlock: ((inout NSURLSessionConfiguration) -> ())?) {
        self.sessionConfig = APISession.defaultSessionConfiguration()
        configurationBlock?(&self.sessionConfig)
        session = NSURLSession(configuration: self.sessionConfig)
    }
    
    private class func defaultSessionConfiguration() -> NSURLSessionConfiguration {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration();
        configuration.URLCache = nil;
        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Always
        configuration.timeoutIntervalForRequest = APISession.DefaultTimeoutIntervalForRequest
        return configuration
    }
    
    
    public func selectSite(site: APISite?) {
        self.selectedSite = site;
        self.baseURL = site?.uri
    }
    
    public func setSessionCookieValue(name: String, value: String?) {
        var cookieProperties = [
            NSHTTPCookieDomain: self.baseURL?.host ?? "",
            NSHTTPCookiePath: self.baseURL?.path ?? "",
            NSHTTPCookieName: name
        ]
        if let port = self.baseURL?.port {
            cookieProperties[NSHTTPCookiePort] = port.stringValue
        }
        if (self.baseURL?.scheme == .Some("https")) {
            cookieProperties[NSHTTPCookieSecure] = NSNumber(bool: true).stringValue
        }
        
        if (value != nil) {
            cookieProperties[NSHTTPCookieValue] = value!
            if let cookie = NSHTTPCookie(properties: cookieProperties) {
                self.session.configuration.HTTPCookieStorage?.setCookie(cookie)
            }
        } else {
            cookieProperties[NSHTTPCookieValue] = ""
            if let cookie = NSHTTPCookie(properties: cookieProperties) {
                self.session.configuration.HTTPCookieStorage?.deleteCookie(cookie)
            }
        }
    }
    
    public func reset(completionHandler: (()->())) {
        self.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
            for task in dataTasks {
                task.cancel()
            }
            for task in uploadTasks {
                task.cancel()
            }
            for task in downloadTasks {
                task.cancel()
            }
        }
        self.selectSite(nil)
        self.session.resetWithCompletionHandler(completionHandler)
    }
    
}