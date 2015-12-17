//
//  JSONHelpers.swift
//  Chat
//
//  Created by Ravi Desai on 4/23/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation

public typealias JSON = AnyObject
public typealias JSONArray = [JSON]
public typealias JSONDictionary = [String: JSON]

public extension String {
    public func toDate(format: String) -> NSDate? {
        return toDateFromString(format, dateString: self)
    }
}

public extension NSDate {
    public func toUTCString(format: String) -> String? {
        return toStringFromDate(format, dateOptional: self)
    }
}

private func toStringFromDate(format: String, dateOptional: NSDate?) -> String? {
    if let date = dateOptional {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.dateFormat = format
        return formatter.stringFromDate(date);
    }
    return nil
}

private func toDateFromString(format: String, dateString: String) -> NSDate? {
    let formatter = NSDateFormatter()
    formatter.dateFormat = format
    return formatter.dateFromString(dateString)
}

public func asBool(object: JSON) -> Bool? {
    return object as? Bool
}

public func asString(object: JSON) -> String? {
    return object as? String
}

public func asDouble(object: JSON) -> Double? {
    return object as? Double
}

public func asInt(object: JSON) -> Int? {
    return object as? Int
}

public func asDictionary(object: JSON) -> JSONDictionary? {
    return object as? JSONDictionary
}

public func asArray(object: JSON) -> JSONArray? {
    return object as? JSONArray
}

public func asUrl(object: JSON) -> NSURL? {
    if let urlString = object as? String {
        return NSURL(string: urlString)
    }
    return nil
}

public func asUUID(object: JSON) -> NSUUID? {
    if let uuidString = object as? String {
        return NSUUID(UUIDString: uuidString)
    }
    return nil
}

public func asDate(format: String)(object: JSON) -> NSDate? {
    if let dateString = object as? String {
        return toDateFromString(format, dateString: dateString)
    }
    return nil
}

// null bind operator
infix operator >>- { associativity left precedence 150 }
public func >>-<T>(optional: JSON?, asFunction: JSON -> T?) -> T? {
    if let value: JSON = optional {
        return asFunction(value)
    }
    return nil
}

// applicative apply operators
infix operator <*> { associativity left }
infix operator<**> { associativity left }

// Applicative apply operator.  Second parameter cannot be nil,
// will only apply function if both function and parameter are not nil
public func <*><A, B>(curryFunc: (A -> B)?, curryParam: A?) -> B? {
    if let curryFunction = curryFunc {
        if let curryParameter = curryParam {
            return curryFunction(curryParameter)
        }
    }
    return nil
}

// Applicative apply operator.  Second parameter can be nil (function
// takes a null parameter as input).
public func <**><A,B>(curryFunc: (A?->B)?, curryParam: A?) -> B? {
    if let curryFunction = curryFunc {
        return curryFunction(curryParam)
    }
    return nil
}