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
    static func createFromJSON(json: JSON) -> Self?
}

public protocol JSONSerializable : SerializableToJSON, SerializableFromJSON { }

public extension SequenceType where Generator.Element: SerializableToJSON {
    public func convertToJSONArray() -> [JSONDictionary] {
        return self.map { $0.convertToJSON() }
    }
}

public extension SequenceType where Generator.Element: JSON {
    public func createFromJSONArray<T where T: SerializableFromJSON>() -> [T]? {
        return self
            .map { T.createFromJSON($0) }
            .filter { $0 != nil }
            .map { $0! }

    }
}
