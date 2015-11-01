//
//  EmailAddress.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation
import RSDSerialization

struct EmailAddress: JSONSerializable, Comparable, CustomStringConvertible {
    var user: String
    var host: String
    var displayValue: String?
    
    init(user: String, host: String, displayValue: String?) {
        self.user = user
        self.host = host
        self.displayValue = displayValue
    }
        
    static func create(user: String)(host: String)(displayValue: String?) -> EmailAddress {
        return EmailAddress(user: user, host: host, displayValue: displayValue)
    }
    
    func convertToJSON() -> JSONDictionary {
        var dict = JSONDictionary()
        addTuplesIf(&dict, tuples:
            ("User", self.user),
            ("Host", self.host),
            ("DisplayValue", self.displayValue))
        
        return dict
    }
    
    static func createFromJSON(json: JSON) -> EmailAddress? {
        if let record = json as? JSONDictionary {
            return EmailAddress.create
                <*> record["User"] >>- asString
                <*> record["Host"] >>- asString
                <**> record["DisplayValue"] >>- asString
        }
        return nil;
    }
    
    var description: String {
        get {
            let display = self.displayValue?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if (display == nil || display! == "") {
                return "\(self.addressString)"
            }
            return "\"\(display)\" \(self.addressString)"
        }
    }
    
    var addressString: String {
        return "\(user)@\(host)"
    }
    
    static func convertToEmailAddress(possibleValue: String?) -> EmailAddress? {
        guard let value = possibleValue else {
            return nil
        }
        var result: EmailAddress? = nil;
        let queryPattern1 = "^\\s*\"(.*)\"\\s*<(\\S*)@(\\S*)>\\s*$";
        let queryPattern3 = "^\\s*([^<>\\s]+)@([^<>\\s]+)\\s*$";
        let queryPattern4 = "^\\s*(.*?)\\s*\\((\\S*)@(\\S*)\\)\\s*$";
        let queryPattern5 = "^\\s*(.*?)\\s*<(\\S*)@(\\S*)>\\s*$";
        let queryPattern6 = "^\\s*(.*?)\\s*(\\S+)@(\\S*)\\s*$";
        
        let regex1 = try? NSRegularExpression(pattern: queryPattern1, options: NSRegularExpressionOptions.CaseInsensitive)
        let regex3 = try? NSRegularExpression(pattern: queryPattern3, options: NSRegularExpressionOptions.CaseInsensitive)
        let regex4 = try? NSRegularExpression(pattern: queryPattern4, options: NSRegularExpressionOptions.CaseInsensitive)
        let regex5 = try? NSRegularExpression(pattern: queryPattern5, options: NSRegularExpressionOptions.CaseInsensitive)
        let regex6 = try? NSRegularExpression(pattern: queryPattern6, options: NSRegularExpressionOptions.CaseInsensitive)
        
        let nsValue = value as NSString
        if let matches = regex1?.matchesInString(value, options: NSMatchingOptions(), range: NSMakeRange(0, value.characters.count)) {
            if (matches.count > 0) {
                let user = nsValue.substringWithRange(matches[0].rangeAtIndex(2))
                let host = nsValue.substringWithRange(matches[0].rangeAtIndex(3))
                let displayName = nsValue.substringWithRange(matches[0].rangeAtIndex(1))
                result = EmailAddress(user: user, host: host, displayValue: displayName)
                return result
            }
        }
        
        if let matches = regex3?.matchesInString(value, options: NSMatchingOptions(), range: NSMakeRange(0, value.characters.count)) {
            if (matches.count > 0) {
                let user = nsValue.substringWithRange(matches[0].rangeAtIndex(1))
                let host = nsValue.substringWithRange(matches[0].rangeAtIndex(2))
                let displayName = ""
                result = EmailAddress(user: user, host: host, displayValue: displayName)
                return result
            }
        }
        
        if let matches = regex4?.matchesInString(value, options: NSMatchingOptions(), range: NSMakeRange(0, value.characters.count)) {
            if (matches.count > 0) {
                let user = nsValue.substringWithRange(matches[0].rangeAtIndex(2))
                let host = nsValue.substringWithRange(matches[0].rangeAtIndex(3))
                let displayName = nsValue.substringWithRange(matches[0].rangeAtIndex(1))
                result = EmailAddress(user: user, host: host, displayValue: displayName)
                return result
            }
        }
        
        if let matches = regex5?.matchesInString(value, options: NSMatchingOptions(), range: NSMakeRange(0, value.characters.count)) {
            if (matches.count > 0) {
                let user = nsValue.substringWithRange(matches[0].rangeAtIndex(2))
                let host = nsValue.substringWithRange(matches[0].rangeAtIndex(3))
                let displayName = nsValue.substringWithRange(matches[0].rangeAtIndex(1))
                result = EmailAddress(user: user, host: host, displayValue: displayName)
                return result
            }
        }
        
        if let matches = regex6?.matchesInString(value, options: NSMatchingOptions(), range: NSMakeRange(0, value.characters.count)) {
            if (matches.count > 0) {
                let user = nsValue.substringWithRange(matches[0].rangeAtIndex(2))
                let host = nsValue.substringWithRange(matches[0].rangeAtIndex(3))
                let displayName = nsValue.substringWithRange(matches[0].rangeAtIndex(1))
                result = EmailAddress(user: user, host: host, displayValue: displayName)
                return result
            }
        }
        
        return result
    }

}

func==(lhs: EmailAddress, rhs: EmailAddress) -> Bool {
    return lhs.user == rhs.user && lhs.host == rhs.host
}

func<(lhs: EmailAddress, rhs: EmailAddress) -> Bool {
    if (lhs.host == rhs.host) {
        if (lhs.user == rhs.user) {
            return lhs.displayValue < rhs.displayValue
        }
        return lhs.user < rhs.user
    }
    return lhs.host < rhs.host
}
