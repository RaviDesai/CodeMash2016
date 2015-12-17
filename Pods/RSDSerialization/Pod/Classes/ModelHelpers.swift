//
//  DictionaryExtensions.swift
//  Chat
//
//  Created by Ravi Desai on 4/23/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation

public extension Dictionary {
    public mutating func addIf(key: Key, value: Value?) {
        if let myValue = value {
            self[key] = myValue
        }
    }
    
    public mutating func addTuplesIf(tuples: (Key, Value?)...) {
        for tuple in tuples {
            self.addIf(tuple.0, value: tuple.1)
        }
    }
    
    init (tuples: (Key, Value?)...) {
        self.init()
        for tuple in tuples {
            self.addIf(tuple.0, value: tuple.1)
        }
    }
}

private func convertToFormUrl<Key, Value>(fromDictionary: Dictionary<Key, Value>) -> NSData {
    var urlParams = Array<String>();
    for (key, value) in fromDictionary {
        let set = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy()
        set.removeCharactersInString(":/?#[]@!$'()*+,;")
        
        let encodedKey = "\(key)".stringByAddingPercentEncodingWithAllowedCharacters(set as! NSCharacterSet) ?? ""
        let encodedValue = "\(value)".stringByAddingPercentEncodingWithAllowedCharacters(set as! NSCharacterSet) ?? ""
        
        urlParams.append(("\(encodedKey)=\(encodedValue)"))
    }
    let strData = urlParams.joinWithSeparator("&");
    return strData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) ?? NSData()
}

private func convertToFormUrl(obj: SerializableToJSON) -> NSData {
    return convertToFormUrl(obj.convertToJSON());
}


public extension SerializableToJSON {
    public func convertToFormUrlEncoded() -> NSData {
        return convertToFormUrl(self)
    }
}

public class ModelFactory<T: SerializableFromJSON> {
    public static func createFromJSONArray(json: JSON) -> [T]? {
        let jsonArray = json as? JSONArray
        let result : [T]? = jsonArray?.createFromJSONArray()
        return result
    }
    
    public static func createFromJSON(json: JSON) -> T? {
        return T.createFromJSON(json)
    }
}

