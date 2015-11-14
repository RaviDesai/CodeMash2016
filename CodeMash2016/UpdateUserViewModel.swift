//
//  UpdateUserViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/29/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

class UpdateUserViewModel: ViewModelBase {
    var originalUser: User?
    var user: User?
    
    func setUser(user: User?) {
        self.user = user
        self.originalUser = user
        // make sure comparisons are using ID field.
        self.originalUser?.id = nil
    }
    
    var contactName: String? {
        get { return self.user?.name }
        set {
            if let name = newValue {
                self.user?.name = name
            }
        }
    }
    
    var contactAddress: String? {
        get { return self.user?.emailAddress?.addressString }
        set {
            self.user?.emailAddress = EmailAddress.convertToEmailAddress(newValue)
        }
    }
    
    var uuidString: String? {
        return self.user?.id?.compressedUUIDString
    }
    
    var contactImage: UIImage? {
        get { return self.user?.image }
        set { self.user?.image = newValue }
    }
    
    var hasValidEmailAddress: Bool {
        return self.user?.emailAddress != nil
    }
    
    var hasInformationChanged: Bool {
        return self.user != self.originalUser
    }
    
    func saveUser(completionHandler: (User?, NSError?)->()) {
        if let user = self.user {
            let handler = self.fireOnMainThread(completionHandler)
            Api.sharedInstance.saveUser(user, completionHandler: handler)
        } else {
            completionHandler(nil, nil)
        }
    }
    
    func deleteUser(completionHandler: (User?, NSError?)->()) {
        if let user = self.user {
            let handler = self.fireOnMainThread(completionHandler)
            Api.sharedInstance.deleteUser(user, completionHandler: handler)
        } else {
            completionHandler(nil, nil)
        }
    }
}