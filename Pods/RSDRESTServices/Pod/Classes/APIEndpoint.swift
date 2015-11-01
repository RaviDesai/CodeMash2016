//
//  APIEndpoint.swift
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 RSD. All rights reserved.
//

import Foundation

public class APIEndpoint {
    private var _URLAndParams: URLAndParameters
    private var _method: String
    
    public init(method: String, url: URLAndParameters) {
        self._URLAndParams = url;
        self._method = method;
    }
    
    public func URL(baseURL: NSURL?) -> NSURL? {
        return self._URLAndParams.URL(baseURL)
    }
    
    public func method() -> String {
        return self._method
    }
    
    public class func GET(url: URLAndParameters) -> APIEndpoint {
        return APIEndpoint(method: "GET", url: url)
    }
    
    public class func POST(url: URLAndParameters) -> APIEndpoint {
        return APIEndpoint(method: "POST", url: url)
    }
    
    public class func PUT(url: URLAndParameters) -> APIEndpoint {
        return APIEndpoint(method: "PUT", url: url)
    }
    
    public class func DELETE(url: URLAndParameters) -> APIEndpoint {
        return APIEndpoint(method: "DELETE", url: url)
    }
}