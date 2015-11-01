//
//  APIRequest.swift
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 RSD. All rights reserved.
//

import Foundation

public class APIRequest<U: APIResponseParserProtocol> {
    private var baseURL: NSURL?
    private var endpoint: APIEndpoint
    private var bodyEncoder: APIBodyEncoderProtocol?
    private var additionalHeaders: [String: String]?
    public private(set) var responseParser: U
    public init(baseURL: NSURL?, endpoint: APIEndpoint, bodyEncoder: APIBodyEncoderProtocol?, responseParser: U, additionalHeaders: [String: String]?) {
        self.baseURL = baseURL
        self.endpoint = endpoint
        self.bodyEncoder = bodyEncoder
        self.additionalHeaders = additionalHeaders
        self.responseParser = responseParser
    }
    
    public func URL() -> NSURL? {
        return self.endpoint.URL(self.baseURL)
    }
    
    public func acceptTypes() -> String? {
        return self.responseParser.acceptTypes?.joinWithSeparator(", ")
    }

    public func method() -> String {
        return self.endpoint.method()
    }
    
    public func contentType() -> String? {
        return self.bodyEncoder?.contentType()
    }
    
    public func body() -> NSData? {
        return self.bodyEncoder?.body()
    }
    
    public func makeRequest() -> NSMutableURLRequest? {
        var result: NSMutableURLRequest?
        if let url = self.URL() {
            let mutableRequest = NSMutableURLRequest(URL: url)
            mutableRequest.HTTPMethod = self.method()
            if let data = body() {
                mutableRequest.HTTPBody = data;
                NSURLProtocol.setProperty(data.copy(), forKey: "PostedData", inRequest: mutableRequest)
            }
            
            if let headers = self.additionalHeaders {
                for header in headers {
                    mutableRequest.setValue(header.1, forHTTPHeaderField: header.0);
                }
            }

            if let acceptTypes = self.acceptTypes() {
                mutableRequest.setValue(acceptTypes, forHTTPHeaderField: "Accept")
            }
            
            if let contentType = self.contentType() {
                mutableRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            }
            
            result = mutableRequest
        }
        return result
    }
}