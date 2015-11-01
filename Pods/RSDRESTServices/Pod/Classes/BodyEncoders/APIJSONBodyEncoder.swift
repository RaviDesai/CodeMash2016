//
//  JSONBodyEncoder.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation
import RSDSerialization

public class APIJSONBodyEncoder: APIBodyEncoderProtocol {
    private var model: SerializableToJSON;
    public init(model: SerializableToJSON) {
        self.model = model;
    }
    
    public func contentType() -> String {
        return "application/json"
    }
    
    public func body() -> NSData? {
        let json = model.convertToJSON()
        let result = try? NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted)
        return result;
    }
}