//
//  Message.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/15/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation
import RSDRESTServices
import RSDSerialization

struct Message: ModelItem {
    var id: NSUUID?
    var from: User
    var to: [User]?
    var game: Game?
    var subject: String
    var message: String
    var date: NSDate
    
    init(id: NSUUID?, from: User, to: [User]?, game: Game?, subject: String, message: String, date: NSDate) {
        self.id = id
        self.from = from
        self.to = to
        self.game = game
        self.subject = subject
        self.message = message
        self.date = date
    }
    
    static func create(id: NSUUID?)(from: User)(to: [User]?)(game: Game?)(subject: String)(message: String)(date: NSDate) -> Message {
        return Message(id: id, from: from, to: to, game: game, subject: subject, message: message, date: date)
    }
    
    func convertToJSON() -> JSONDictionary {
        return JSONDictionary(tuples:
            ("ID", self.id?.UUIDString),
            ("From", self.from.convertToJSON()),
            ("To", self.to?.convertToJSONArray()),
            ("Game", self.game?.convertToJSON()),
            ("Subject", self.subject),
            ("Message", self.message),
            ("Date", self.date.toUTCString("yyyy-MM-dd'T'HH:mm:ssX")))
    }
    
    static func createFromJSON(json: JSON) -> Message? {
        if let record = json as? JSONDictionary {
            return Message.create
                <**> record["ID"] >>- asUUID
                <*> record["From"] >>- User.createFromJSON
                <**> record["To"] >>-  ModelFactory<User>.createFromJSONArray
                <**> record["Game"] >>- Game.createFromJSON
                <*> record["Subject"] >>- asString
                <*> record["Message"] >>- asString
                <*> record["Date"] >>- asDate("yyyy-MM-dd'T'HH:mm:ssX")
        }
        return nil;
    }
}

extension Message {
    func isAuthorizedForReading(authuser: User) -> Bool {
        if (authuser.isAdmin) {
            return true
        }
        if let game = self.game where game.isAuthorizedForReading(authuser) {
            return true
        }
        if self.from == authuser {
            return true
        }
        let matchingUsersCount = self.to?.filter { $0 == authuser }.count ?? 0
        if (matchingUsersCount > 0) {
            return true
        }
        return false
    }
    
    func isAuthorizedForUpdate(authuser: User) -> Bool {
        if (authuser.isAdmin) {
            return true
        }
        if self.from == authuser {
            return true
        }
        return false
    }
}

func==(lhs: Message, rhs: Message) -> Bool {
    if (lhs.id == nil || rhs.id == nil) {
        return lhs.from == rhs.from && lhs.to ?? [] == rhs.to ?? [] && lhs.game == rhs.game && lhs.subject == rhs.subject && lhs.message == rhs.message && lhs.date == rhs.date
    }
    
    return lhs.id == rhs.id
}

func==%(lhs: Message, rhs: Message) -> Bool {
    return lhs == rhs
}

func<(lhs: Message, rhs: Message) -> Bool {
    let lhsDate = lhs.date.toUTCString("yyyy-MM-dd'T'HH:mm:ssX") ?? ""
    let rhsDate = rhs.date.toUTCString("yyyy-MM-dd'T'HH:mm:ssX") ?? ""
    return lhsDate < rhsDate
}