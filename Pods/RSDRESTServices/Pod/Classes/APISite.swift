//
//  Site.swift
//
//  Created by Ravi Desai on 4/23/15.
//  Copyright (c) 2015 RSD. All rights reserved.
//

import Foundation
import RSDSerialization


public struct APISite : JSONSerializable, Comparable {
    public var name: String
    public var uri: NSURL?
    
    public init(name: String, uri: String?) {
        self.name = name
        if let myUri = uri {
            self.uri = NSURL(string: myUri)
        }
    }

    public static func create(name: String)(uri: String?) -> APISite {
        return APISite(name: name, uri: uri);
    }

    public func convertToJSON() -> JSONDictionary {
        var dict = JSONDictionary()
        addTuplesIf( &dict, tuples:
            ("Name", self.name),
            ("Uri", self.uri?.absoluteString))
        
        return dict

    }
    
    public static func createFromJSON(json: JSON) -> APISite? {
        if let record = json as? JSONDictionary {
            return APISite.create
                <*> record["Name"] >>- asString
                <**> record["Uri"] >>- asString
        }
        return nil;
    }
}

public func==(lhs: APISite, rhs: APISite) -> Bool {
    return lhs.name == rhs.name && lhs.uri == rhs.uri
}

public func<(lhs: APISite, rhs: APISite) -> Bool {
    return lhs.name < rhs.name
}