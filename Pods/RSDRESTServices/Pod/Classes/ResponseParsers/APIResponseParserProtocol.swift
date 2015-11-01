//
//  ResponseParser.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation

public protocol APIResponseParserProtocol {
    typealias T
    func Parse(networkResponse: NetworkResponse) -> (T?, NSError?)
    func ParseToArray(networkResponse: NetworkResponse) -> ([T]?, NSError?)
    
    var acceptTypes: [String]? { get }
}
