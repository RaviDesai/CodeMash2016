//
//  Game.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/16/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation
import RSDRESTServices
import RSDSerialization

struct Game: ModelItem {
    var id: NSUUID?
    var title: String
    var owner: NSUUID
    var users: [NSUUID]?
    
    init(id: NSUUID?, title: String, owner: NSUUID, users: [NSUUID]?) {
        self.id = id
        self.title = title
        self.owner = owner
        self.users = users
    }
    
    static func create(id: NSUUID?)(title: String)(owner: NSUUID)(users: [NSUUID]?) -> Game {
        return Game(id: id, title: title, owner: owner, users: users)
    }
    
    func convertToJSON() -> JSONDictionary {
        return JSONDictionary(tuples:
            ("ID", self.id?.UUIDString),
            ("Title", self.title),
            ("Owner", self.owner.UUIDString),
            ("Users", self.users?.map { $0.UUIDString })
        )
    }
    
    static func createFromJSON(json: JSON) -> Game? {
        if let record = json as? JSONDictionary {
            return Game.create
                <**> record["ID"] >>- asUUID
                <*> record["Title"] >>- asString
                <*> record["Owner"] >>- asUUID
                <**> record["Users"] >>- NSUUID.createFromJSONArray
        }
        return nil;
    }
}

extension Game {
    func isAuthorizedForReading(user: User) -> Bool {
        if (user.isAdmin) { return true }
        return self.isAuthorizedForReading(user.id?.UUIDString)
    }
    
    func isAuthorizedForReading(userIdString: String?) -> Bool {
        if self.owner.UUIDString == userIdString {
            return true
        }
        if let matchingUsersCount = self.users?.filter({ $0.UUIDString == userIdString }).count where matchingUsersCount > 0 {
            return true
        }
        return false
    }
    
    func isAuthorizedForUpdating(user: User) -> Bool {
        if (user.isAdmin) { return true }
        return self.isAuthorizedForUpdating(user.id?.UUIDString)
    }
    
    func isAuthorizedForUpdating(userIdString: String?) -> Bool {
        if self.owner.UUIDString == userIdString {
            return true
        }
        return false
    }
}

func==(lhs: Game, rhs: Game) -> Bool {
    if (lhs.id == nil || rhs.id == nil) {
        return lhs.title == rhs.title && lhs.owner == rhs.owner
    }
    
    return lhs.id == rhs.id
}

func==%(lhs: Game, rhs: Game) -> Bool {
    return lhs.title == rhs.title
}

func<(lhs: Game, rhs: Game) -> Bool {
    return lhs.title < rhs.title
}