//
//  RESTResponse.swift
//
//  Created by Ravi Desai on 4/23/15.
//  Copyright (c) 2015 RSD. All rights reserved.
//

import Foundation
import RSDSerialization

public protocol NetworkResponseCheckProtocol {
    func isNetworkFailure() -> Bool
    func isBadRequest() -> Bool
    func isUnauthorized() -> Bool
    func isUndetermined() -> Bool
    func getData() -> NSData?
    func getJSON() -> (JSON?, NSError?)
}

public enum NetworkResponse : CustomStringConvertible, NetworkResponseCheckProtocol {
    case Success(Int, String, NSData?)
    case HTTPStatusCodeFailure(Int, String)
    case CouldNotConnectToURL(String)
    case SystemFailure(NSError)
    case NetworkFailure
    case Undetermined
    
    public static func create(data: NSData?, response: NSURLResponse?, error: NSError?) -> NetworkResponse {
        var netResponse: NetworkResponse = NetworkResponse.Undetermined
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                let localizedString = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode)
                netResponse = NetworkResponse.Success(httpResponse.statusCode, localizedString, data)
            } else {
                let localizedString = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode)
                netResponse = NetworkResponse.HTTPStatusCodeFailure(httpResponse.statusCode, localizedString)
            }
        } else {
            netResponse = NetworkResponse.NetworkFailure
        }
        
        return netResponse
    }
    
    public var description: String {
        get {
            switch(self) {
            case let .Success(statusCode, localizedMessage, _):
                return "Success(\(statusCode)): \(localizedMessage)"
            case let .HTTPStatusCodeFailure(statusCode, localizedMessage):
                return "HTTP status code \(statusCode) indicated failure: \(localizedMessage)"
            case let .CouldNotConnectToURL(urlString):
                return "Could not connect to URL: \(urlString)"
            case let .SystemFailure(error):
                return "General system failure: \(error.localizedDescription)"
            case .NetworkFailure:
                return "Network failure"
            case .Undetermined:
                return "Undetermined response"
            }
        }
    }
    
    public func didSucceed() -> Bool {
        switch(self) {
        case .Success(_, _, _):
            return true
        default:
            return false
        }
    }
    
    public func didFail() -> Bool {
        return !didSucceed()
    }
    
    public func isNetworkFailure() -> Bool {
        switch(self) {
        case .NetworkFailure:
            return true
        default:
            return false
        }
    }
    
    public func isBadRequest() -> Bool {
        switch(self) {
        case let .HTTPStatusCodeFailure(statusCode, _):
            if (statusCode == 400) {
                return true
            }
            return false
        default:
            return false
        }
    }
    
    public func isUnauthorized() -> Bool {
        switch(self) {
        case let .HTTPStatusCodeFailure(statusCode, _):
            if (statusCode == 401) {
                return true
            }
            return false
        default:
            return false
        }
    }
    
    public func isUndetermined() -> Bool {
        switch(self) {
        case .Undetermined:
            return true
        default:
            return false
        }
    }
    
    public func getData() -> NSData? {
        switch(self) {
        case let .Success(_, _, data):
            return data
        default:
            return nil
        }
    }

    public func getJSON() -> (JSON?, NSError?) {
        let data = self.getData();
        var result:JSON?
        var error: NSError?
        if (data != nil && data!.length > 0) {
            result = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
        } else {
            error = self.getError()
        }
        return (result, error);
    }
    
    public func getError() -> NSError? {
        switch(self) {
        case let .HTTPStatusCodeFailure(_, localizedMessage):
            let userInfo = [NSLocalizedDescriptionKey:localizedMessage, NSLocalizedFailureReasonErrorKey: localizedMessage, RSDRESTServicesNetworkResponseKey: BoxedNetworkResponse(self)];
            return NSError(domain: "com.github.RaviDesai", code: 48118003, userInfo: userInfo)
        case let .CouldNotConnectToURL(urlString):
            let message = "Could not connect to url: \(urlString)"
            let userInfo = [NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey: message, RSDRESTServicesNetworkResponseKey: BoxedNetworkResponse(self)];
            return NSError(domain: "com.github.RaviDesai", code: 48118004, userInfo: userInfo)
        case let .SystemFailure(error):
            var userInfo = error.userInfo
            userInfo[RSDRESTServicesNetworkResponseKey] = BoxedNetworkResponse(self)
            return NSError(domain: error.domain, code: error.code, userInfo: userInfo)
        case .NetworkFailure:
            let message = "General Network Failure"
            let userInfo = [NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey: message, RSDRESTServicesNetworkResponseKey: BoxedNetworkResponse(self)]
            return NSError(domain: "com.github.RaviDesai", code: 48118005, userInfo: userInfo)
        case .Undetermined:
            let message = "Task never completed"
            let userInfo = [NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey: message, RSDRESTServicesNetworkResponseKey: BoxedNetworkResponse(self)]
            return NSError(domain: "com.github.RaviDesai", code: 48118006, userInfo: userInfo)
        default:
            return nil
        }

    }
}

