//
//  Api.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation
import RSDSerialization
import RSDRESTServices

protocol ApiProtocol {
    func getAllUsers(completionHandler: ([User]?, NSError?) -> ())
    func saveUser(user: User, completionHandler: (User?, NSError?) -> ())
    func deleteUser(user: User, completionHandler: (User?, NSError?) -> ())
}

class Api: ApiProtocol {
    static var sharedInstance: ApiProtocol = Api()
    static func injectApiHandler(handler: ApiProtocol) {
        Api.sharedInstance = handler
    }
    static func resetApiHandler() {
        Api.sharedInstance = Api()
    }
    
    func getAllUsers(completionHandler: (([User]?, NSError?) -> ())) {
        let parser = APIJSONSerializableResponseParser<User>()
        let endpoint = APIEndpoint.GET(URLAndParameters(url: "api/users"))
        let call = Client.sharedClient.call(endpoint, encoder: nil, parser: parser)
        call.executeRespondWithArray(completionHandler)
    }
    
    func saveUser(user: User, completionHandler: (User?, NSError?)->()) {
        if let id = user.id {
            let parser = APIJSONSerializableResponseParser<User>()
            let encoder = APIJSONBodyEncoder(model: user)
            let endpoint = APIEndpoint.PUT(URLAndParameters(url: "api/users/\(id.UUIDString)"))
            let call = Client.sharedClient.call(endpoint, encoder: encoder, parser: parser)
            call.executeRespondWithObject(completionHandler)
        } else {
            completionHandler(nil, nil)
        }
    }
    
    func deleteUser(user: User, completionHandler: (User?, NSError?)->()) {
        if let id = user.id {
            let parser = APIJSONSerializableResponseParser<User>()
            let endpoint = APIEndpoint.DELETE(URLAndParameters(url: "api/users/\(id.UUIDString)"))
            let call = Client.sharedClient.call(endpoint, encoder: nil, parser: parser)
            call.executeRespondWithObject(completionHandler)
        } else {
            completionHandler(nil, nil)
        }
    }
}