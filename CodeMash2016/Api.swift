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
    func getUser(id: NSUUID, completionHandler: (User?, NSError?) -> ())
    func getAllUsers(completionHandler: ([User]?, NSError?) -> ())
    func saveUser(user: User, completionHandler: (User?, NSError?) -> ())
    func createUser(user: User, completionHandler: (User?, NSError?) -> ())
    func deleteUser(user: User, completionHandler: (User?, NSError?) -> ())
    func createGame(game: Game, completionHandler: (Game?, NSError?) -> ())
    func getAllGames(user: User?, completionHandler: ([Game]?, NSError?) -> ())
    func getMessagesForGame(game: Game, completionHandler: ([Message]?, NSError?)->())
    func logout(completionHandler: ()->())
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
    
    func getUser(id: NSUUID, completionHandler: (User?, NSError?) -> ()) {
        let parser = APIJSONSerializableResponseParser<User>()
        let endpoint = APIEndpoint.GET(URLAndParameters(url: "api/users/\(id.UUIDString)"))
        let call = Client.sharedClient.call(endpoint, encoder: nil, parser: parser)
        call.executeRespondWithObject(completionHandler)
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
    
    func createUser(user: User, completionHandler: (User?, NSError?) -> ()) {
        if (user.id == nil) {
            let parser = APIJSONSerializableResponseParser<User>()
            let encoder = APIJSONBodyEncoder(model: user)
            let endpoint = APIEndpoint.POST(URLAndParameters(url: "api/users"))
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

    func createGame(game: Game, completionHandler: (Game?, NSError?) -> ()) {
        if (game.id == nil) {
            let parser = APIJSONSerializableResponseParser<Game>()
            let encoder = APIJSONBodyEncoder(model: game)
            let endpoint = APIEndpoint.POST(URLAndParameters(url: "api/games"))
            let call = Client.sharedClient.call(endpoint, encoder: encoder, parser: parser)
            call.executeRespondWithObject(completionHandler)
        } else {
            completionHandler(nil, nil)
        }
    }

    func getAllGames(user: User?, completionHandler: ([Game]?, NSError?)->()) {
        let parser = APIJSONSerializableResponseParser<Game>()
        let endpoint = APIEndpoint.GET(URLAndParameters(url: "api/games"))
        let call = Client.sharedClient.call(endpoint, encoder: nil, parser: parser)
        call.executeRespondWithArray(completionHandler)
    }
    
    func getMessagesForGame(game: Game, completionHandler: ([Message]?, NSError?)->()) {
        if let gameId = game.id?.UUIDString {
            let parser = APIJSONSerializableResponseParser<Message>()
            let endpoint = APIEndpoint.GET(URLAndParameters(url: "api/messages", parameters: ("game", gameId)))
            let call = Client.sharedClient.call(endpoint, encoder: nil, parser: parser)
            call.executeRespondWithArray(completionHandler)
        } else {
            completionHandler(nil, nil)
        }

    }
    
    func logout(completionHandler: ()->()) {
        Client.sharedClient.logout(completionHandler)
    }
}