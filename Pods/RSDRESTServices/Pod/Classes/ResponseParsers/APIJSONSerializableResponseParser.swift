//
//  JSONResponseParser.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation
import RSDSerialization

public class APIJSONSerializableResponseParser<T: SerializableFromJSON> : APIResponseParserProtocol {
    public init() {
        self.acceptTypes = ["application/json"]
    }
    
    public init(versionRepresentation: ModelResourceVersionRepresentation, vendor: String, version: String) {
        if (versionRepresentation == ModelResourceVersionRepresentation.CustomContentType) {
            self.acceptTypes = ["application/\(vendor).v\(version)+json"]
        } else {
            self.acceptTypes = ["application/json"]
        }
    }
    
    public init(acceptTypes: [String]) {
        self.acceptTypes = acceptTypes
    }
    
    public private(set) var acceptTypes: [String]?
    
    public class func convertToSerializable(response: NetworkResponse) -> (T?, NSError?) {
        let (jsonOptional, error) = response.getJSON()
        if let json:JSON = jsonOptional {
            if let obj = T.createFromJSON(json) {
                return (obj, nil)
            } else {
                let userInfo = [NSLocalizedDescriptionKey: "JSON deserialization error", NSLocalizedFailureReasonErrorKey: "JSON deserialization error"]
                
                let jsonError = NSError(domain: "com.careevolution.direct", code: 48103001, userInfo: userInfo)
                return (nil, jsonError)
            }
        } else {
            return (nil, error)
        }
    }
    
    public class func convertToSerializableArray(response: NetworkResponse) -> ([T]?, NSError?) {
        let (jsonOptional, error) = response.getJSON()
        if let json:JSON = jsonOptional {
            if let objArray = ModelFactory<T>.createFromJSONArray(json) {
                return (objArray.map { $0 }, nil)
            } else {
                let userInfo = [NSLocalizedDescriptionKey: "JSON deserialization error", NSLocalizedFailureReasonErrorKey: "JSON deserialization error"]
                
                let jsonError = NSError(domain: "com.careevolution.direct", code: 48103001, userInfo: userInfo)
                return (nil, jsonError)
            }
        } else {
            return (nil, error)
        }
    }

    public func Parse(response: NetworkResponse) -> (T?, NSError?) {
        let (jsonOptional, jsonError) = response.getJSON()
        if (jsonOptional != nil) {
            return APIJSONSerializableResponseParser.convertToSerializable(response)
        }
        let responseError = response.getError() ?? jsonError;
        return (nil, responseError)
    }

    public func ParseToArray(response: NetworkResponse) -> ([T]?, NSError?) {
        let (jsonOptional, jsonError) = response.getJSON()
        if (jsonOptional != nil) {
            return APIJSONSerializableResponseParser.convertToSerializableArray(response)
        }
        let responseError = response.getError() ?? jsonError;
        return (nil, responseError)
    }
}