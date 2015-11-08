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

public protocol ModelItemWithID {
    var id: NSUUID? { get set }
}


struct User : ModelItem {
    var id: NSUUID?
    var name: String
    var emailAddress: EmailAddress?
    var image: UIImage?

    init(id: NSUUID?, name: String, emailAddress: EmailAddress?, image: UIImage?) {
        self.id = id
        self.name = name
        self.emailAddress = emailAddress
        self.image = image
    }
    
    static func create(id: NSUUID?)(name: String)(emailAddress: EmailAddress?)(image: UIImage?) -> User {
        return User(id: id, name: name, emailAddress: emailAddress, image: image)
    }
    
    func convertToJSON() -> JSONDictionary {
        var dict = JSONDictionary()
        addTuplesIf(&dict, tuples:
            ("ID", self.id?.UUIDString),
            ("Name", self.name),
            ("EmailAddress", self.emailAddress?.convertToJSON()),
            ("Image", toBase64FromImage(self.image))
        )
        
        return dict
    }
    
    static func createFromJSON(json: JSON) -> User? {
        if let record = json as? JSONDictionary {
            return User.create
                <**> record["ID"] >>- asUUID
                <*> record["Name"] >>- asString
                <**> record["EmailAddress"] >>- EmailAddress.createFromJSON
                <**> record["Image"] >>- asImage
        }
        return nil;
    }
}

func==(lhs: User, rhs: User) -> Bool {
    if (lhs.id == nil || rhs.id == nil) {
        return lhs.name == rhs.name && lhs.emailAddress == rhs.emailAddress && lhs.image == rhs.image
    }
    
    return lhs.id == rhs.id
}

func<(lhs: User, rhs: User) -> Bool {
    if (lhs.name == rhs.name) {
        return lhs.emailAddress < rhs.emailAddress
    }
    return lhs.name < rhs.name
}