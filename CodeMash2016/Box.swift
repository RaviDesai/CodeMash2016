//
//  Box.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/1/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation

class Box<T: PrintableAndEquatable> : NSObject {
    let unbox: T
    init(_ value: T) {
        self.unbox = value
    }
    
    override var description: String { get { return unbox.description } }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let otherBox = object as? Box<T> {
            return unbox == otherBox.unbox
        }
        return false
    }
}

