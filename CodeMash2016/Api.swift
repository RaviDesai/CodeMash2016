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
    func deleteGame(game: Game, completionHandler: (NSError?) -> ())
    func getAllGames(user: User?, completionHandler: ([Game]?, NSError?) -> ())
    func getMessagesForGame(game: Game, completionHandler: ([Message]?, NSError?)->())
    
    func login(site: APISite, username: String, password: String, completionHandler: (NSUUID?, NSError?)->())
    func logout(completionHandler: ()->())
}

private let invalidId = NSError(domain: "com.github.RaviDesai", code: 48118002, userInfo: [NSLocalizedDescriptionKey: "Invalid ID", NSLocalizedFailureReasonErrorKey: "Invalid ID"])

class Api: ApiProtocol {
    static var sharedInstance: ApiProtocol = Api()
    static func injectApiHandler(handler: ApiProtocol) {
        Api.sharedInstance = handler
    }
    static func resetApiHandler() {
        Api.sharedInstance = Api()
    }
    
    func getAllUsers(completionHandler: (([User]?, NSError?) -> ())) {
        let parser = APIModelResourceResponseParser<User>()
        let endpoint = APIEndpoint.GET(URLAndParameters(url: User.versionedResourceEndpoint))
        let call = Client.sharedClient.call(endpoint, encoder: nil, parser: parser, additionalHeaders: User.additionalHeadersForRequest)
        call.executeRespondWithArray(completionHandler)
    }
    
    func getUser(id: NSUUID, completionHandler: (User?, NSError?) -> ()) {
        let parser = APIModelResourceResponseParser<User>()
        let endpoint = APIEndpoint.GET(URLAndParameters(url: "\(User.versionedResourceEndpoint)/\(id.UUIDString)"))
        let call = Client.sharedClient.call(endpoint, encoder: nil, parser: parser, additionalHeaders: User.additionalHeadersForRequest)
        call.executeRespondWithObject(completionHandler)
    }
    
    func saveUser(user: User, completionHandler: (User?, NSError?)->()) {
        if let id = user.id {
            let parser = APIModelResourceResponseParser<User>()
            let encoder = APIJSONBodyEncoder(model: user)
            let endpoint = APIEndpoint.PUT(URLAndParameters(url: "\(User.versionedResourceEndpoint)/\(id.UUIDString)"))
            let call = Client.sharedClient.call(endpoint, encoder: encoder, parser: parser, additionalHeaders: User.additionalHeadersForRequest)
            call.executeRespondWithObject(completionHandler)
        } else {
            completionHandler(nil, invalidId)
        }
    }
    
    func createUser(user: User, completionHandler: (User?, NSError?) -> ()) {
        if (user.id == nil) {
            let parser = APIModelResourceResponseParser<User>()
            let encoder = APIJSONBodyEncoder(model: user)
            let endpoint = APIEndpoint.POST(URLAndParameters(url: "\(User.versionedResourceEndpoint)"))
            let call = Client.sharedClient.call(endpoint, encoder: encoder, parser: parser, additionalHeaders: User.additionalHeadersForRequest)
            call.executeRespondWithObject(completionHandler)
        } else {
            completionHandler(nil, invalidId)
        }
    }
    
    func deleteUser(user: User, completionHandler: (User?, NSError?)->()) {
        if let id = user.id {
            let parser = APIModelResourceResponseParser<User>()
            let endpoint = APIEndpoint.DELETE(URLAndParameters(url: "\(User.versionedResourceEndpoint)/\(id.UUIDString)"))
            let call = Client.sharedClient.call(endpoint, encoder: nil, parser: parser, additionalHeaders: User.additionalHeadersForRequest)
            call.executeRespondWithObject(completionHandler)
        } else {
            completionHandler(nil, invalidId)
        }
    }

    func createGame(game: Game, completionHandler: (Game?, NSError?) -> ()) {
        if game.id == nil {
            let parser = APIModelResourceResponseParser<Game>()
            let encoder = APIJSONBodyEncoder(model: game)
            let endpoint = APIEndpoint.POST(URLAndParameters(url: "\(Game.versionedResourceEndpoint)"))
            let call = Client.sharedClient.call(endpoint, encoder: encoder, parser: parser, additionalHeaders: Game.additionalHeadersForRequest)
            call.executeRespondWithObject(completionHandler)
        } else {
            completionHandler(nil, invalidId)
        }
    }
    
    func deleteGame(game: Game, completionHandler: (NSError?)->()) {
        if let gameId = game.id?.UUIDString {
            let parser = APIDataResponseParser()
            let encoder = APIJSONBodyEncoder(model: game)
            let endpoint = APIEndpoint.DELETE(URLAndParameters(url: "\(Game.versionedResourceEndpoint)/\(gameId)"))
            let call = Client.sharedClient.call(endpoint, encoder: encoder, parser: parser, additionalHeaders: Game.additionalHeadersForRequest)
            call.execute(completionHandler)
        } else {
            completionHandler(invalidId)
        }
    }

    func getAllGames(user: User?, completionHandler: ([Game]?, NSError?)->()) {
        let parser = APIModelResourceResponseParser<Game>()
        let endpoint = APIEndpoint.GET(URLAndParameters(url: "\(Game.versionedResourceEndpoint)"))
        let call = Client.sharedClient.call(endpoint, encoder: nil, parser: parser, additionalHeaders: Game.additionalHeadersForRequest)
        call.executeRespondWithArray(completionHandler)
    }
    
    func getMessagesForGame(game: Game, completionHandler: ([Message]?, NSError?)->()) {
        if let gameId = game.id?.UUIDString {
            let parser = APIModelResourceResponseParser<Message>()
            let endpoint = APIEndpoint.GET(URLAndParameters(url: "\(Message.versionedResourceEndpoint)", parameters: ("game", gameId)))
            let call = Client.sharedClient.call(endpoint, encoder: nil, parser: parser, additionalHeaders: Message.additionalHeadersForRequest)
            call.executeRespondWithArray(completionHandler)
        } else {
            completionHandler(nil, invalidId)
        }

    }
    
    func login(site: APISite, username: String, password: String, completionHandler: (NSUUID?, NSError?)->()) {
        Client.sharedClient.authenticate(site, username: username, password: password, completion: {(userId, error) -> () in
            if let myerror = error {
                completionHandler(nil, myerror)
                return
            }
            guard let myUserId = userId else {
                completionHandler(nil, invalidId)
                return
            }
            completionHandler(myUserId, nil)
        })
    }
    
    func logout(completionHandler: ()->()) {
        Client.sharedClient.logout(completionHandler)
    }
}