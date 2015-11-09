//
//  NSError+Extensions.swift
//  Pods
//
//  Created by Ravi Desai on 11/8/15.
//
//

import Foundation

public let RSDRESTServicesNetworkResponseKey = "RSDRESTServices.NetworkResponse"

public class BoxedNetworkResponse: NSObject {
    public private(set) var value: NetworkResponse
    init(_ value: NetworkResponse) {
        self.value = value
    }
}

public extension NSError {
    public var networkResponse: NetworkResponse? {
        get {
            let boxed = self.userInfo[RSDRESTServicesNetworkResponseKey] as? BoxedNetworkResponse
            return boxed?.value
        }
    }
    
    public var isNetworkResponseUnauthorized: Bool {
        get {
            let networkResponse = self.networkResponse
            return networkResponse?.isUnauthorized() ?? false
        }
    }
}