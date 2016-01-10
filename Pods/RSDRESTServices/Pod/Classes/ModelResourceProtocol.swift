//
//  ModelResourceProtocol.swift
//  Pods
//
//  Created by Ravi Desai on 1/8/16.
//
//

import Foundation
import RSDSerialization

public enum ModelResourceVersionRepresentation {
    case URLVersioning
    case CustomRequestHeader
    case CustomContentType
}

public protocol ModelResource : ModelItem {
    typealias T : ModelItem = Self
    static var resourceApiEndpoint: String { get }
    static var resourceName: String { get }
    static var resourceVersion: String { get }
    static var resourceVersionRepresentedBy: ModelResourceVersionRepresentation { get }
    static var resourceVendor: String { get }
    
    static func getAll(session: APISession, completionHandler: ([T]?, NSError?) -> ())
    static func get(session: APISession, resourceId: NSUUID, completionHandler: (T?, NSError?) -> ())
    func save(session: APISession, completionHandler: (T?, NSError?) -> ())
    func create(session: APISession, completionHandler: (T?, NSError?) -> ())
    func delete(session: APISession, completionHandler: (NSError?) -> ())
}

private let invalidId = NSError(domain: "com.github.RaviDesai", code: 48118002, userInfo: [NSLocalizedDescriptionKey: "Invalid ID", NSLocalizedFailureReasonErrorKey: "Invalid ID"])

public extension ModelResource {
    static var customResourceHeaderWithVendorAndVersion: String {
        get {
            return "\(resourceVendor).v\(resourceVersion)"
        }
    }
    
    static var versionedResourceEndpoint: String {
        get {
            if resourceVersionRepresentedBy == ModelResourceVersionRepresentation.URLVersioning {
                return "\(Self.resourceApiEndpoint)/v\(Self.resourceVersion)/\(Self.resourceName)"
            }
            return "\(Self.resourceApiEndpoint)/\(Self.resourceName)"
        }
    }
    
    static var additionalHeadersForRequest: [String: String]? {
        get {
            if resourceVersionRepresentedBy == ModelResourceVersionRepresentation.CustomRequestHeader {
                return ["api-version": resourceVersion]
            }
            return nil
        }
    }
    
    static func getAll(session: APISession, completionHandler: ([T]?, NSError?)->()) {
        let endpoint = APIEndpoint.GET(URLAndParameters(url: Self.versionedResourceEndpoint))
        let parser = APIJSONSerializableResponseParser<T>(versionRepresentation: Self.resourceVersionRepresentedBy, vendor: Self.resourceVendor, version: Self.resourceVersion)
        let request = APIRequest(baseURL: session.baseURL, endpoint: endpoint, bodyEncoder: nil, responseParser: parser, additionalHeaders: Self.additionalHeadersForRequest)
        let call = APICall(session: session, request: request)
        call.executeRespondWithArray(completionHandler)
    }
    
    static func get(session: APISession, resourceId: NSUUID, completionHandler: (T?, NSError?) -> ()) {
        let uuid = resourceId.UUIDString
        let endpoint = APIEndpoint.GET(URLAndParameters(url: "\(Self.versionedResourceEndpoint)/\(uuid)"))
        let parser = APIJSONSerializableResponseParser<T>(versionRepresentation: Self.resourceVersionRepresentedBy, vendor: Self.resourceVendor, version: Self.resourceVersion)
        let request = APIRequest(baseURL: session.baseURL, endpoint: endpoint, bodyEncoder: nil, responseParser: parser, additionalHeaders: Self.additionalHeadersForRequest)
        let call = APICall(session: session, request: request)
        call.executeRespondWithObject(completionHandler)
    }
    
    func save(session: APISession, completionHandler: (T?, NSError?) -> ()) {
        if let uuid = self.id?.UUIDString {
            let endpoint = APIEndpoint.PUT(URLAndParameters(url: "\(Self.versionedResourceEndpoint)/\(uuid)"))
            let parser = APIJSONSerializableResponseParser<T>(versionRepresentation: Self.resourceVersionRepresentedBy, vendor: Self.resourceVendor, version: Self.resourceVersion)
            let encoder = APIJSONBodyEncoder(model: self)
            let request = APIRequest(baseURL: session.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: Self.additionalHeadersForRequest)
            let call = APICall(session: session, request: request)
            call.executeRespondWithObject(completionHandler)
        } else {
            completionHandler(nil, invalidId)
        }
    }
    
    func create(session: APISession, completionHandler: (T?, NSError?) -> ()) {
        if self.id?.UUIDString == nil {
            let endpoint = APIEndpoint.POST(URLAndParameters(url: Self.versionedResourceEndpoint))
            let parser = APIJSONSerializableResponseParser<T>(versionRepresentation: Self.resourceVersionRepresentedBy, vendor: Self.resourceVendor, version: Self.resourceVersion)
            let encoder = APIJSONBodyEncoder(model: self)
            let request = APIRequest(baseURL: session.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: Self.additionalHeadersForRequest)
            let call = APICall(session: session, request: request)
            call.executeRespondWithObject(completionHandler)
        } else {
            completionHandler(nil, invalidId)
        }
    }
    
    func delete(session: APISession, completionHandler: (NSError?) -> ()) {
        if let uuid = self.id?.UUIDString {
            let endpoint = APIEndpoint.DELETE(URLAndParameters(url: "\(Self.versionedResourceEndpoint)/\(uuid)"))
            let parser = APIJSONSerializableResponseParser<T>(versionRepresentation: Self.resourceVersionRepresentedBy, vendor: Self.resourceVendor, version: Self.resourceVersion)
            let encoder = APIJSONBodyEncoder(model: self)
            let request = APIRequest(baseURL: session.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: Self.additionalHeadersForRequest)
            let call = APICall(session: session, request: request)
            call.execute(completionHandler)
        } else {
            completionHandler(invalidId)
        }
    }

}