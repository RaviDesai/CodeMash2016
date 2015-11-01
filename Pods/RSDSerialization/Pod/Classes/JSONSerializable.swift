//
//  JSONSerializable.swift
//  Chat
//
//  Created by Ravi Desai on 4/23/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation
public protocol SerializableToJSON {
    func convertToJSON() -> JSONDictionary
}

public protocol SerializableFromJSON {
    typealias ConcreteType
    static func createFromJSON(json: JSON) -> ConcreteType?
}

public protocol JSONSerializable : SerializableToJSON, SerializableFromJSON { }
