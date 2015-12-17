//
//  MockHTTPResponder.swift
//  RSDRESTServices
//
//  Created by Ravi Desai on 11/05/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//
import Foundation
import RSDSerialization
import OHHTTPStubs

func pullIdFromPath(path: String?, regEx: NSRegularExpression?) -> NSUUID? {
    var myId: NSUUID?
    if let path = path {
        if let matches = regEx?.matchesInString(path, options: NSMatchingOptions(), range: NSMakeRange(0, path.characters.count)) {
            if (matches.count > 0) {
                var idString = path.substringWithRange(matches[0].rangeAtIndex(1))
                idString = idString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                myId = NSUUID(UUIDString: idString)
            }
        }
    }
    return myId
}

public class MockHTTPResponder<T: JSONSerializable> {
    public class func getPostedObject(request: NSURLRequest) -> T? {
        var result: T?
        if let requestData = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData {
            if let json = try? NSJSONSerialization.JSONObjectWithData(requestData, options: NSJSONReadingOptions.AllowFragments) {
                result = T.createFromJSON(json)
            }
        }
        return result
    }
    
    public class func withIdInPath(request: NSURLRequest, regEx: NSRegularExpression?, logic: ((NSUUID)->OHHTTPStubsResponse)) -> OHHTTPStubsResponse {
        if let requestId = pullIdFromPath(request.URL?.path, regEx: regEx) {
            return logic(requestId)
        }
        return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 400, headers: nil)
    }
    
    public class func withPostedObject(request: NSURLRequest, logic: ((T)->OHHTTPStubsResponse)) -> OHHTTPStubsResponse {
        
        if let deserialized = MockHTTPResponder<T>.getPostedObject(request) {
            return logic(deserialized)
        }
        
        return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 400, headers: nil)
    }
    
    public class func withPostedArray(request: NSURLRequest, logic: (([T])->OHHTTPStubsResponse)) -> OHHTTPStubsResponse {
        if let requestData = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData {
            if let json = try? NSJSONSerialization.JSONObjectWithData(requestData, options: NSJSONReadingOptions.AllowFragments) {
                if let deserialized = ModelFactory<T>.createFromJSONArray(json) {
                    return logic(deserialized)
                }
            }
            return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 500, headers: nil)
        }
        return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 400, headers: nil)
        
    }
    
    private class func stubsResponseForError(error: StoreError?) -> OHHTTPStubsResponse {
        if let myerror = error {
            switch(myerror) {
            case StoreError.NotFound:
                return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 404, headers: nil)
            case StoreError.NotUnique:
                return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 409, headers: nil)
            default:
                return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 400, headers: nil)
            }
        }
        // should never hit here.  return I'm a teapot error
        return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 418, headers: nil)
    }
    
    public class func produceObjectResponse(object: T?, error: StoreError?) -> OHHTTPStubsResponse {
        if let json = object?.convertToJSON() {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted)
                return OHHTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "appliction/json"])
            } catch let error as NSError {
                return OHHTTPStubsResponse(error: error)
            }
        } else {
            return stubsResponseForError(error)
        }
    }
    
    public class func produceArrayResponse(array: [T]?, error: StoreError?) -> OHHTTPStubsResponse {
        if let json = array?.convertToJSONArray() {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted)
                return OHHTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json"])
            } catch let error as NSError {
                return OHHTTPStubsResponse(error: error)
            }
        } else {
            return stubsResponseForError(error)
        }
    }
    
}
