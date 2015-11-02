//
//  Box.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/1/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation

class Box : NSObject {
    let unbox: EmailAddress
    init(_ value: EmailAddress) {
        self.unbox = value
    }
    override var description: String { get { return unbox.description } }
}

func ==(lhs: Box, rhs: Box) -> Bool {
    return lhs.unbox == rhs.unbox
}