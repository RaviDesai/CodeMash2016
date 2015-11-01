//
//  NSDataResponseParser.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation

public class APIDataResponseParser : APIResponseParserProtocol {
    public typealias T = NSData
    
    public init() {
        self.acceptTypes = nil
    }
    
    public init(acceptTypes: [String]) {
        self.acceptTypes = acceptTypes
    }
    public private(set) var acceptTypes: [String]?
    
    public class func convertToSerializable(response: NetworkResponse) -> (NSData?, NSError?) {
        let data: NSData? = response.getData()
        let error: NSError? = response.getError()
        return (data, error)
    }
    
    public class func convertToSerializableArray(response: NetworkResponse) -> ([NSData]?, NSError?) {
        let data: NSData? = response.getData()
        let error: NSError? = response.getError()
        return (data != nil ? [data!] : nil, error)
    }
    
    public func Parse(response: NetworkResponse) -> (NSData?, NSError?) {
        return APIDataResponseParser.convertToSerializable(response)
    }
    
    public func ParseToArray(response: NetworkResponse) -> ([NSData]?, NSError?) {
        return APIDataResponseParser.convertToSerializableArray(response)
    }
}