//
//  MockRESTStore.swift
//  RSDRESTServices
//
//  Created by Ravi Desai on 11/05/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//
import Foundation
import RSDSerialization
import OHHTTPStubs

public class MockedRESTStore<T: ModelItem> {
    private var host: String?
    private var endpoint: String?
    private var endpointRegEx: NSRegularExpression?
    
    public var store: [T]
    
    private var createStub: OHHTTPStubsDescriptor?
    private var deleteStub: OHHTTPStubsDescriptor?
    private var updateStub: OHHTTPStubsDescriptor?
    private var getAllStub: OHHTTPStubsDescriptor?
    private var getOneStub: OHHTTPStubsDescriptor?
    
    public init(host: String?, endpoint: String, initialValues: [T]?) {
        self.host = host
        self.endpoint = endpoint
        let queryPattern = "\(endpoint)/(.+)$"
        self.endpointRegEx = try? NSRegularExpression(pattern: queryPattern, options: NSRegularExpressionOptions.CaseInsensitive)
        
        if let initial = initialValues {
            self.store = initial
        } else {
            self.store = []
        }
    }
    
    public func findIndex(object: T) -> Int? {
        var index: Int = 0
        for (index = 0; index < store.count; index++) {
            if (store[index] == object) {
                return index
            }
        }
        return index
    }
    
    public func findIndexOfUUID(id: NSUUID) -> Int? {
        var index: Int = 0
        for (index = 0; index < store.count; index++) {
            if (store[index].id == id) {
                return index
            }
        }
        return index
    }
    
    public func create(object: T) -> T? {
        if (object.id != nil) { return nil }
        
        var item = object
        item.id = NSUUID()
        store.append(item)
        return item
    }
    
    public func update(object: T) -> T? {
        if let index = self.findIndex(object) {
            self.store[index] = object
            return object
        }
        return nil
    }
    
    public func delete(uuid: NSUUID) -> T? {
        if let index = findIndexOfUUID(uuid) {
            return self.store.removeAtIndex(index)
        }
        return nil
    }
    
    private func hijackGetAll() {
        if (self.getAllStub != nil) { return }
        
        self.getAllStub =
            OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
                if (request.URL?.host != self.host) {
                    return false
                }
                if (request.URL?.path != self.endpoint) {
                    return false
                }
                if (request.HTTPMethod != "GET") {
                    return false
                }
                
                return true
            }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                return MockHTTPResponder<T>.produceArrayResponse(self.store.sort(<))
            })
    }
    
    private func hijackGetOne() {
        if (self.getOneStub != nil) { return }
        
        self.getOneStub =
            OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
                if (request.URL?.host != self.host) {
                    return false
                }
                
                if pullIdFromPath(request.URL?.path, regEx: self.endpointRegEx) == nil {
                    return false
                }
                
                if (request.HTTPMethod != "GET") {
                    return false
                }
                
                return true
            }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                    var item: T? = nil
                    if let id = pullIdFromPath(request.URL?.path, regEx: self.endpointRegEx) {
                        if let index = self.findIndexOfUUID(id) {
                            item = self.store[index]
                        }
                    }
                    return MockHTTPResponder<T>.produceObjectResponse(item)
            })
    }
    
    private func hijackCreate() {
        if self.createStub != nil { return }
        
        self.createStub =
            OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
                if (request.URL?.host != self.host) {
                    return false
                }
                
                if request.URL?.path == self.endpoint {
                    return false
                }
                
                if (request.HTTPMethod != "POST") {
                    return false
                }
                
                if (MockHTTPResponder<T>.getPostedObject(request) == nil) {
                    return false
                }
                
                return true
            }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                    return MockHTTPResponder<T>.withPostedObject(request, logic: { (item) -> OHHTTPStubsResponse in
                        return MockHTTPResponder<T>.produceObjectResponse(self.create(item as! T))
                    })
            })
    }
    
    private func hijackUpdate() {
        if (self.updateStub != nil) { return }
        
        self.updateStub =
            OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
                if (request.URL?.host != self.host) {
                    return false
                }
                
                if pullIdFromPath(request.URL?.path, regEx: self.endpointRegEx) == nil {
                    return false
                }
                
                if (request.HTTPMethod != "PUT") {
                    return false
                }
                
                if (MockHTTPResponder<T>.getPostedObject(request) == nil) {
                    return false
                }
                
                return true
            }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                    return MockHTTPResponder<T>.withPostedObject(request, logic: { (item) -> OHHTTPStubsResponse in
                        return MockHTTPResponder<T>.produceObjectResponse(self.update(item as! T))
                    })
            })
    }
    
    private func hijackDelete() {
        if (self.deleteStub != nil) { return }
        
        self.deleteStub =
            OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
                if (request.URL?.host != self.host) {
                    return false
                }
                
                if pullIdFromPath(request.URL?.path, regEx: self.endpointRegEx) == nil {
                    return false
                }
                
                if (request.HTTPMethod != "DELETE") {
                    return false
                }
                
                return true
            }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                    return MockHTTPResponder<T>.withIdInPath(request, regEx: self.endpointRegEx, logic: { (requestId) -> OHHTTPStubsResponse in
                        MockHTTPResponder<T>.produceObjectResponse(self.delete(requestId))
                    })
            })
    }
    
    public func hijackAll() {
        self.hijackCreate()
        self.hijackDelete()
        self.hijackUpdate()
        self.hijackGetAll()
        self.hijackGetOne()
    }
    
    public func unhijackAll() {
        if let createStub = self.createStub {
            OHHTTPStubs.removeStub(createStub)
            self.createStub = nil
        }
        if let deleteStub = self.deleteStub {
            OHHTTPStubs.removeStub(deleteStub)
            self.deleteStub = nil
        }
        if let updateStub = self.updateStub {
            OHHTTPStubs.removeStub(updateStub)
            self.updateStub = nil
        }
        if let getAllStub = self.getAllStub {
            OHHTTPStubs.removeStub(getAllStub)
            self.getAllStub = nil
        }
        if let getOneStub = self.getOneStub {
            OHHTTPStubs.removeStub(getOneStub)
            self.getOneStub = nil
        }
    }
    
    deinit {
        self.unhijackAll()
    }
}

