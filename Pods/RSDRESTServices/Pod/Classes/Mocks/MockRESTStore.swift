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

public enum StoreError: ErrorType {
    case InvalidId
    case NotUnique
    case NotFound
    case UndefinedError
}

public class MockedRESTStore<T: ModelItem> {
    public var host: String?
    public var endpoint: String?
    private var endpointRegEx: NSRegularExpression?
    
    public var store: [T]
    
    public var createStub: OHHTTPStubsDescriptor?
    public var deleteStub: OHHTTPStubsDescriptor?
    public var updateStub: OHHTTPStubsDescriptor?
    public var getAllStub: OHHTTPStubsDescriptor?
    public var getOneStub: OHHTTPStubsDescriptor?
    
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
        for (var index = 0; index < store.count; index++) {
            if (store[index] == object) {
                return index
            }
        }
        return nil
    }
    
    public func verifyUnique(object: T, atIndex: Int?) -> Bool {
        for (var index = 0; index < store.count; index++) {
            if (index != atIndex) {
                if (store[index] ==% object) {
                    return false
                }
            }
        }
        return true
    }
    
    public func findIndexOfUUID(id: NSUUID) -> Int? {
        for (var index = 0; index < store.count; index++) {
            if (store[index].id == id) {
                return index
            }
        }
        return nil
    }
    
    public func create(object: T) throws -> T? {
        if (object.id != nil) {
            throw StoreError.InvalidId
        }
        
        guard verifyUnique(object, atIndex: nil) else {
            throw StoreError.NotUnique
        }
        
        var item = object
        item.id = NSUUID()
        store.append(item)
        return item
    }
    
    public func update(object: T) throws -> T {
        guard let index = self.findIndex(object) else {
            throw StoreError.NotFound
        }
        
        guard verifyUnique(object, atIndex: index) else {
            throw StoreError.NotUnique
        }
        
        self.store[index] = object
        return object
    }
    
    public func delete(uuid: NSUUID) throws -> T? {
        guard let index = findIndexOfUUID(uuid) else {
            throw StoreError.NotFound
        }
        return self.store.removeAtIndex(index)
    }
    
    public func hijackGetAll() {
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
                if let queryString = request.URL?.query where queryString != "" {
                    return false
                }
                
                return true
            }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                return MockHTTPResponder<T>.produceArrayResponse(self.store.sort(<), error: nil)
            })
    }
    
    public func hijackGetOne() {
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
                
                if let queryString = request.URL?.query where queryString != "" {
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
                return MockHTTPResponder<T>.produceObjectResponse(item, error: nil)
            })
    }
    
    public func hijackCreate() {
        if self.createStub != nil { return }
        
        self.createStub =
            OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
                if (request.URL?.host != self.host) {
                    return false
                }
                
                if request.URL?.path != self.endpoint {
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
                    var response: T?
                    var responseError: StoreError?
                    do {
                        response = try self.create(item)
                    } catch let err as StoreError {
                        responseError = err
                    } catch {
                        responseError = StoreError.UndefinedError
                    }
                    
                    return MockHTTPResponder<T>.produceObjectResponse(response, error: responseError)
                })
            })
    }
    
    public func hijackUpdate() {
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
                    var response: T?
                    var responseError: StoreError?
                    do {
                        response = try self.update(item)
                    } catch let err as StoreError {
                        responseError = err
                    } catch {
                        responseError = StoreError.UndefinedError
                    }
                    

                    return MockHTTPResponder<T>.produceObjectResponse(response, error: responseError)
                })
            })
    }
    
    public func hijackDelete() {
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
                        
                        var response: T?
                        var responseError: StoreError?
                        do {
                            response = try self.delete(requestId)
                        } catch let err as StoreError {
                            responseError = err
                        } catch {
                            responseError = StoreError.UndefinedError
                        }
                        
                        
                        return MockHTTPResponder<T>.produceObjectResponse(response, error: responseError)
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

