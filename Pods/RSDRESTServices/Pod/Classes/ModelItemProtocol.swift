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

public protocol ModelItem: JSONSerializable, ItemWithID, Comparable {}

