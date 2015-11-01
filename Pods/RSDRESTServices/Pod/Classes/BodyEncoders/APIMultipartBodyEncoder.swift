//
//  APIMultipartBodyEncoder.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 6/11/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation

public class APIMultipartBodyEncoder : APIBodyEncoderProtocol {
    private let boundary = "----------V2ymHFg03ehbqgZCaKO6jy"
    private var postData: [APIPostData]
    public init(postData: [APIPostData]) {
        self.postData = postData
    }
    
    public func contentType() -> String {
        return "multipart/form-data boundary=\(self.boundary)"
    }
    
    public func body() -> NSData? {
        let body = NSMutableData()
        for data in self.postData {
            if let parameters = data.parameters {
                for parameter in parameters {
                    body.appendData("--\(self.boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                    body.appendData("Content-Disposition: form-data; name=\"\(parameter.0)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                    body.appendData("\(parameter.1)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                }
            }
            
            body.appendData("--\(self.boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("Content-Disposition: form-data; name=\"\(data.filename)\"; filename=\"\(data.filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("Content-Type: \(data.mediaType)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(data.body)
            body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("--\(self.boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        return body;
    }
}