//
//  LoginResponse.swift
//
//  Created by Ravi Desai on 4/23/15.
//  Copyright (c) 2015 RSD. All rights reserved.
//

import Foundation
import RSDSerialization

public struct LoginToken: JSONSerializable, Equatable {
    public var id: String
    public var token: String
    
    public init(id: String, token: String) {
        self.id = id
        self.token = token
    }
    
    public static func create(id: String)(token: String) -> LoginToken {
        return LoginToken(id: id, token: token)
    }
    
    public static func createFromJSON(json: JSON) -> LoginToken? {
        if let record = json as? JSONDictionary {
            return LoginToken.create
                <*> record["wa"] >>- asString
                <*> record["wresult"] >>- asString
        }
        return nil;
    }
    
    public func convertToJSON() -> JSONDictionary {
        return JSONDictionary(tuples:
            ("wa", self.id),
            ("wresult", self.token))
    }
}

public func==(lhs: LoginToken, rhs: LoginToken) -> Bool {
    return lhs.id == rhs.id && lhs.token == rhs.token
}

public struct LoginResponse : JSONSerializable, Equatable {
    public var success: Bool
    public var message: String?
    public var token: LoginToken
    
    public init(success: Bool, message: String?, token: LoginToken) {
        self.success = success
        self.message = message
        self.token = token
    }
    
    public static func create(success: Bool)(message:String?)(token: LoginToken) -> LoginResponse {
        return LoginResponse(success: success, message: message, token: token);
    }
    
    public static func createFromJSON(json: JSON) -> LoginResponse? {
        if let record = json as? JSONDictionary {
            return LoginResponse.create
                <*> record["Success"] >>- asBool
                <**> record["Message"] >>- asString
                <*> record["Parameters"] >>- LoginToken.createFromJSON
        }
        return nil;
    }
    
    public func convertToJSON() -> JSONDictionary {
        return JSONDictionary(tuples:
            ("Success", self.success),
            ("Message", self.message),
            ("Parameters", self.token.convertToJSON()))
    }
}

public func==(lhs: LoginResponse, rhs: LoginResponse) -> Bool {
    return lhs.success == rhs.success && lhs.message == rhs.message && lhs.token == rhs.token
}