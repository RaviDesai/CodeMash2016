//
//  APIPostData.swift
//
//  Created by Ravi Desai on 6/11/15.
//  Copyright (c) 2015 RSD. All rights reserved.
//

import Foundation

public struct APIPostData {
    public var filename: String
    public var mediaType: String
    public var body: NSData
    public var parameters: [String: String]?
    
    public init(filename: String, mediaType: String, body: NSData, parameters: [String: String]?) {
        self.filename = filename
        self.mediaType = mediaType
        self.body = body
        self.parameters = parameters
    }
}