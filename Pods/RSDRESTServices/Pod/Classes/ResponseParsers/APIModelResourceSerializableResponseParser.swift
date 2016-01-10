//
//  APIModelResourceSerializableResponseParser.swift
//  Pods
//
//  Created by Ravi Desai on 1/9/16.
//
//

import Foundation
import RSDSerialization

public class APIModelResourceResponseParser<T: ModelResource> : APIJSONSerializableResponseParser<T> {
    public override init() {
        super.init(versionRepresentation: T.resourceVersionRepresentedBy, vendor: T.resourceVendor, version: T.resourceVersion)
    }
}

