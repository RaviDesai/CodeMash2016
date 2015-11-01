//
//  URLBodyEncoder.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation
import RSDSerialization

public class APIURLBodyEncoder : APIBodyEncoderProtocol {
    private var model: SerializableToJSON
    public init(model: SerializableToJSON) {
        self.model = model
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

    public func contentType() -> String {
        return "application/x-www-form-urlencoded"
    }
    
    public func body() -> NSData? {
        return convertToFormUrl(model.convertToJSON())
    }
}