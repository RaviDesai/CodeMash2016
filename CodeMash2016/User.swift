//
//  User.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation
import RSDSerialization
import RSDRESTServices

extension NSUUID {
    var compressedUUIDString: String {
        let base64TailBuffer = "="
        var tempUuidBytes = [UInt8](count: 16, repeatedValue: 0)
        self.getUUIDBytes(&tempUuidBytes)
        let data = NSData(bytes: &tempUuidBytes, length: 16)
        let base64 = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        return base64.stringByReplacingOccurrencesOfString(base64TailBuffer, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
    }

}

private func== (lhs: UIImage?, rhs: UIImage?) -> Bool {
    if let mylhs = lhs {
        return mylhs.isEqual(rhs)
    }
    
    switch(rhs) {
        case .None: return true
        default: return false
    }
}


struct User : ModelItem, CustomStringConvertible {
    var id: NSUUID?
    var name: String
    var password: String
    var emailAddress: EmailAddress?
    var image: UIImage?

    init(id: NSUUID?, name: String, password: String, emailAddress: EmailAddress?, image: UIImage?) {
        self.id = id
        self.name = name
        self.password = password
        self.emailAddress = emailAddress
        self.image = image
    }
    
    static func create(id: NSUUID?)(name: String)(password: String)(emailAddress: EmailAddress?)(image: UIImage?) -> User {
        return User(id: id, name: name, password: password, emailAddress: emailAddress, image: image)
    }
    
    func convertToJSON() -> JSONDictionary {
        return JSONDictionary(tuples:
            ("ID", self.id?.UUIDString),
            ("Name", self.name),
            ("Password", self.password),
            ("EmailAddress", self.emailAddress?.convertToJSON()),
            ("Image", toBase64FromImage(self.image))
        )
    }
    
    static func createFromJSON(json: JSON) -> User? {
        if let record = json as? JSONDictionary {
            return User.create
                <**> record["ID"] >>- asUUID
                <*> record["Name"] >>- asString
                <*> record["Password"] >>- asString
                <**> record["EmailAddress"] >>- EmailAddress.createFromJSON
                <**> record["Image"] >>- asImage
        }
        return nil;
    }
    
    var isAdmin: Bool { get { return self.name.lowercaseString == "admin" } }
    
    var description: String { get { return self.name } }
}

extension User {
    func isAuthorizedForReading(user: User) -> Bool {
        return true
    }
    
    func isAuthorizedForUpdating(user: User) -> Bool {
        return user.isAdmin || self == user
    }
}

func==(lhs: User, rhs: User) -> Bool {
    if (lhs.id == nil || rhs.id == nil) {
        return lhs ==% rhs
    }
    
    return lhs.id == rhs.id
}

func==%(lhs: User, rhs: User) -> Bool {
    return lhs.name == rhs.name && lhs.password == rhs.password && lhs.emailAddress == rhs.emailAddress && lhs.image == rhs.image
}

func<(lhs: User, rhs: User) -> Bool {
    if (lhs.name == rhs.name) {
        return lhs.emailAddress < rhs.emailAddress
    }
    return lhs.name < rhs.name
}

extension User: PrintableAndEquatable { }
