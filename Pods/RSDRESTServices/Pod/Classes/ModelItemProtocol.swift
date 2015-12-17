//
//  ModelItemProtocol.swift
//  Pods
//
//  Created by Ravi Desai on 11/7/15.
//
//

import Foundation
import RSDSerialization

public protocol ItemWithID {
    var id: NSUUID? { get set }
}

infix operator ==% {
    associativity none
    precedence 130
}


public protocol UniqueFieldComparable {
    func==%(lhs: Self, rhs: Self) -> Bool
}

public func==%<T: UniqueFieldComparable>(lhs: T, rhs: T) -> Bool {
    return false
}

public protocol ModelItem: JSONSerializable, ItemWithID, Comparable, UniqueFieldComparable {}

