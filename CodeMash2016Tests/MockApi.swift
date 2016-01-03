//
//  MockApi.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/16/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation
import RSDRESTServices
@testable import CodeMash2016

private let userInfoNotImplemented = [NSLocalizedDescriptionKey: "API is not implemented", NSLocalizedFailureReasonErrorKey: "API is not implemented"]

private let errorNotImplemented = NSError(domain: "com.careevolution.direct", code: 48103001, userInfo: userInfoNotImplemented)

class MockApi: ApiProtocol {

    func getUser(id: NSUUID, completionHandler: (User?, NSError?) -> ()) {
        completionHandler(nil, errorNotImplemented)
    }
    func getAllUsers(completionHandler: ([User]?, NSError?) -> ()) {
        completionHandler(nil, errorNotImplemented)
    }
    func saveUser(user: User, completionHandler: (User?, NSError?) -> ()) {
        completionHandler(nil, errorNotImplemented)
    }
    func createUser(user: User, completionHandler: (User?, NSError?) -> ()) {
        completionHandler(nil, errorNotImplemented)
    }
    func deleteUser(user: User, completionHandler: (User?, NSError?) -> ()) {
        completionHandler(nil, errorNotImplemented)
    }
    func createGame(game: Game, completionHandler: (Game?, NSError?) -> ()) {
        completionHandler(nil, errorNotImplemented)
    }
    func deleteGame(game: Game, completionHandler: (NSError?) -> ()) {
        completionHandler(errorNotImplemented)
    }
    func getAllGames(user: User?, completionHandler: ([Game]?, NSError?) -> ()) {
        completionHandler(nil, errorNotImplemented)
    }
    func getMessagesForGame(game: Game, completionHandler: ([Message]?, NSError?)->()) {
        completionHandler(nil, errorNotImplemented)
    }
    func login(site: APISite, username: String, password: String, completionHandler: (NSUUID?, NSError?) -> ()) {
        completionHandler(nil, errorNotImplemented)
    }
    func logout(completionHandler: ()->()) {
        completionHandler()
    }
}
