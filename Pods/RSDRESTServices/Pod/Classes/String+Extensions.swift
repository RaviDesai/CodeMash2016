//
//  String+Extensions.swift
//  Pods
//
//  Created by Ravi Desai on 11/7/15.
//
//

import Foundation

extension String {
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
        let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
                return from ..< to
        }
        return nil
    }
    
    func NSRangeFromRange(range : Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = String.UTF16View.Index(range.startIndex, within: utf16view)
        let to = String.UTF16View.Index(range.endIndex, within: utf16view)
        return NSMakeRange(utf16view.startIndex.distanceTo(from), from.distanceTo(to))
    }
    
    func stringByReplacingCharactersInRange(nsRange: NSRange, withString string: String) -> String {
        if let range = self.rangeFromNSRange(nsRange) {
            return self.stringByReplacingCharactersInRange(range, withString: string)
        }
        return self
    }
    
    func substringWithRange(nsRange: NSRange) -> String {
        if let range = self.rangeFromNSRange(nsRange) {
            return self.substringWithRange(range)
        }
        return self
    }
}
