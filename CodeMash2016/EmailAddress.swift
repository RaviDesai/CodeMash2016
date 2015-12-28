//
//  EmailAddress.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation
import RSDSerialization

struct EmailAddress: JSONSerializable, Comparable, PrintableAndEquatable {
    var user: String
    var host: String
    
    init(user: String, host: String) {
        self.user = user
        self.host = host
    }
    
    init?(string: String?) {
        guard let value = string else {
            return nil
        }
        let queryPattern1 = "^([\\w-\\.]+)@(([\\w-]+\\.)+[\\w-]{2,4})$"
        
        let regex1 = try? NSRegularExpression(pattern: queryPattern1, options: NSRegularExpressionOptions.CaseInsensitive)
        
        let nsValue = value as NSString
        if let matches = regex1?.matchesInString(value, options: NSMatchingOptions(), range: NSMakeRange(0, value.characters.count)) {
            if (matches.count > 0) {
                self.user = nsValue.substringWithRange(matches[0].rangeAtIndex(1))
                self.host = nsValue.substringWithRange(matches[0].rangeAtIndex(2))
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    static func create(user: String)(host: String) -> EmailAddress {
        return EmailAddress(user: user, host: host)
    }
    
    func convertToJSON() -> JSONDictionary {
        return JSONDictionary(tuples:
            ("User", self.user),
            ("Host", self.host))
    }
    
    static func createFromJSON(json: JSON) -> EmailAddress? {
        if let record = json as? JSONDictionary {
            return EmailAddress.create
                <*> record["User"] >>- asString
                <*> record["Host"] >>- asString
        }
        return nil;
    }
    
    var description: String {
        get {
            return "\(user)@\(host)"
        }
    }
    
    static func getCollapsedDisplayText(addresses: [EmailAddress]) -> String {
        if (addresses.count == 0) { return "" }
        let firstAddress = addresses[0].description
        if (addresses.count == 1) { return firstAddress }
        let count = addresses.count - 1
        let others = (count == 1) ? " and one other" : " and \(count) others"
        return "\(firstAddress)\(others)"
    }

}

func==(lhs: EmailAddress, rhs: EmailAddress) -> Bool {
    return lhs.user == rhs.user && lhs.host == rhs.host
}

func<(lhs: EmailAddress, rhs: EmailAddress) -> Bool {
    if (lhs.host == rhs.host) {
        return lhs.user < rhs.user
    }
    return lhs.host < rhs.host
}
