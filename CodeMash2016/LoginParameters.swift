//
//  LoginParameters.swift
//
//  Created by Ravi Desai on 4/23/15.
//  Copyright (c) 2015 RSD. All rights reserved.
//

import Foundation
import RSDSerialization

public struct LoginParameters : JSONSerializable, Equatable {
    public var username: String
    public var password: String
    
    public init(username: String, password: String) {
        self.username = username;
        self.password = password;
    }
    
    public static func create(username: String)(password: String) -> LoginParameters {
        return LoginParameters(username: username, password: password);
    }
    
    public static func createFromJSON(json: JSON) -> LoginParameters? {
        if let record = json as? JSONDictionary {
            return LoginParameters.create
                <*> record["UserName"] >>- asString
                <*> record["Password"] >>- asString
        }
        return nil;
    }
    
    public func convertToJSON() -> JSONDictionary {
        return JSONDictionary(tuples:
            ("UserName", self.username),
            ("Password", self.password))
    }
}

public func==(lhs: LoginParameters, rhs: LoginParameters) -> Bool {
    return lhs.username.lowercaseString == rhs.username.lowercaseString && lhs.password == rhs.password
}