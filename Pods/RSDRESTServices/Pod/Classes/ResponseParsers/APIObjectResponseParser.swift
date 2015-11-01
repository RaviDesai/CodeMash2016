//
//  ObjectResponseParser.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation

public class APIObjectResponseParser<T> : APIResponseParserProtocol {
    public init() {
        self.acceptTypes = nil
    }
    
    public init(acceptTypes: [String]) {
        self.acceptTypes = acceptTypes
    }
    
    public private(set) var acceptTypes: [String]?
    
    public class func convertToSerializable(response: NetworkResponse) -> (T?, NSError?) {
        var error: NSError? = response.getError()
        var result: T?
        if let data: NSData = response.getData() {
            let obj: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            result = obj as? T
            if (result == nil) {
                let message = "Data cannot be cast into type: \(T.self)"
                let userInfo = [NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey: message];
                error = NSError(domain: "com.careevolution.mobile", code: 48103005, userInfo: userInfo)
            }
        }
        return (result, error)
    }
    
    public class func convertToSerializableArray(response: NetworkResponse) -> ([T]?, NSError?) {
        var error: NSError? = response.getError()
        var result: [T]?
        if let data: NSData = response.getData() {
            let obj: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            let ra = obj as? [AnyObject]
            if (ra != nil) {
                result = ra?.map { $0 as? T }.filter { $0 != nil }.map { $0! }
            } else {
                let message = "Data cannot be cast into an array of type: \(T.self)"
                let userInfo = [NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey: message];
                error = NSError(domain: "com.careevolution.mobile", code: 48103005, userInfo: userInfo)

            }
        }
        return (result, error)
    }
    
    public func Parse(response: NetworkResponse) -> (T?, NSError?) {
        return APIObjectResponseParser.convertToSerializable(response)
    }
    
    public func ParseToArray(response: NetworkResponse) -> ([T]?, NSError?) {
        return APIObjectResponseParser.convertToSerializableArray(response)
    }

}