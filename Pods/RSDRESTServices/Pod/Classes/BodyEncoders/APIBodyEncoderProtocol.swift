//
//  BodyEncoder.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation

public protocol APIBodyEncoderProtocol {
    func contentType() -> String
    func body() -> NSData?
}