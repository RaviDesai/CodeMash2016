//
//  APICall.swift
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 RSD. All rights reserved.
//

import Foundation

public class APICall<U: APIResponseParserProtocol> {
    public private(set) var session: APISession
    private var request: APIRequest<U>
    
    public init(session: APISession, request: APIRequest<U>) {
        self.session = session
        self.request = request
    }
    
    private func performTask(callback: (NetworkResponse) -> ()) {
        let message = "Could not construct a valid HTTP request."
        let userInfo = [NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey: message];
        let error = NSError(domain: "com.github.RaviDesai", code: 48118001, userInfo: userInfo)
        
        if let request = self.request.makeRequest() {
            let task = self.session.session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                let result = NetworkResponse.create(data, response: response, error: error)
                callback(result);
            })
            task.resume()
        } else {
            callback(NetworkResponse.SystemFailure(error))
        }
    }
    
    public func execute(callback: (NSError?) -> ()) {
        self.performTask { (networkResponse) -> () in
            callback(networkResponse.getError())
        }
    }
    
    public func executeRespondWithObject(callback: (U.T?, NSError?) ->()) {
        self.performTask { (response) -> () in
            let (result, error) = self.request.responseParser.Parse(response)
            callback(result, error)
        }
    }
    
    public func executeRespondWithArray(callback: ([U.T]?, NSError?) ->()) {
        self.performTask { (response) -> () in
            let (result, error) = self.request.responseParser.ParseToArray(response)
            callback(result, error)
        }
    }
    
}