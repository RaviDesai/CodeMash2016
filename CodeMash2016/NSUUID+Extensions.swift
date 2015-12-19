//
//  NSUUID+Extensions.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/17/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import RSDSerialization

extension NSUUID {
    func convertToJSON() -> JSON {
        return self.UUIDString
    }
    
    static func createFromJSON(json: JSON) -> NSUUID? {
        if let uuidString = json as? String {
            return NSUUID(UUIDString: uuidString)
        }
        return nil
    }

    static func createFromJSONArray(json: JSON) -> [NSUUID]? {
        if let jsonArray = json as? JSONArray {
            return jsonArray.map { NSUUID.createFromJSON($0) }.filter { $0 != nil }.map { $0! }
        }
        return nil
    }
}

extension SequenceType where Generator.Element == NSUUID {
    func convertToJSONArray() -> [JSON] {
        return self.map { $0.convertToJSON() }
    }
}

