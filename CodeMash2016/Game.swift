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
    var owner: User
    var users: [User]?
    
    init(id: NSUUID?, title: String, owner: User, users: [User]?) {
        self.id = id
        self.title = title
        self.owner = owner
        self.users = users
    }
    
    static func create(id: NSUUID?)(title: String)(owner: User)(users: [User]?) -> Game {
        return Game(id: id, title: title, owner: owner, users: users)
    }
    
    func convertToJSON() -> JSONDictionary {
        return JSONDictionary(tuples:
            ("ID", self.id?.UUIDString),
            ("Title", self.title),
            ("Owner", self.owner.convertToJSON()),
            ("Users", self.users?.convertToJSONArray())
        )
    }
    
    static func createFromJSON(json: JSON) -> Game? {
        if let record = json as? JSONDictionary {
            return Game.create
                <**> record["ID"] >>- asUUID
                <*> record["Title"] >>- asString
                <*> record["Owner"] >>- User.createFromJSON
                <**> record["Users"] >>- ModelFactory<User>.createFromJSONArray
        }
        return nil;
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
    if (lhs.title == rhs.title) {
        return lhs.owner < rhs.owner
    }
    return lhs.title < rhs.title
}