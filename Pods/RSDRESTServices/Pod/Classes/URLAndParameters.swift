//
//  URLAndParameters.swift
//
//  Created by Ravi Desai on 4/23/15.
//  Copyright (c) 2015 RSD. All rights reserved.
//

import Foundation
private func buildURLQueryValueAllowedCharacterSet() -> NSCharacterSet {
    let urlQueryValueAllowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet;
    urlQueryValueAllowedCharacterSet.removeCharactersInString("&=?")
    return urlQueryValueAllowedCharacterSet
}

internal var URLQueryValueAllowedCharacterSet: NSCharacterSet = buildURLQueryValueAllowedCharacterSet()

public struct URLAndParameters : CustomStringConvertible {
    let URLString: String
    let Parameters: Array<(name: String, value:String)>;
    
    public init (url: String, parameters: (name: String, value:String)...) {
        self.URLString = url
        self.Parameters = parameters.map {
            ( name: $0.name,
              value: $0.value.stringByAddingPercentEncodingWithAllowedCharacters(URLQueryValueAllowedCharacterSet)!)
        };
    }
    
    public var description: String {
        get {
            return self.Parameters
                .map { "\($0.0)=\($0.1)" }
                .reduce (self.URLString, combine: {
                    $0 == self.URLString ? "\($0)?\($1)" : "\($0)&\($1)"
                })
        }
    }
    
    public func URL(baseURL: NSURL?) -> NSURL? {
        let beginning = baseURL?.absoluteString ?? ""
        return NSURL(string: "\(beginning)\(self.description)")
    }
    
}
