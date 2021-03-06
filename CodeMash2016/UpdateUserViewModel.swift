//
//  UpdateUserViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/29/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

protocol UpdateUserViewModelProtocol {
    var user: User? { get }
    var isLoaded: Bool { get }
    var loggedInUser: User? { get }
    var canBeUpdated: Bool { get }
    var canBeDeleted: Bool { get }
    var contactName: String? { get set }
    var contactAddress: String? { get set }
    var contactImage: UIImage? { get set }

    var uuidString: String? { get }
    var hasValidEmailAddress: Bool { get }
    var hasInformationChanged: Bool { get }

    func loadData(user: User?, loggedInUser: User?)
    func getColorForEmailString(currentValue: String?) -> UIColor
    func saveUser(completionHandler: (User?, NSError?)->())
    func createUser(completionHandler: (User?, NSError?) -> ())
    func deleteUser(completionHandler: (User?, NSError?)->())
}

class UpdateUserViewModel: ViewModelBase, UpdateUserViewModelProtocol {
    var originalUser: User?
    var user: User?
    var loggedInUser: User?
    
    func loadData(user: User?, loggedInUser: User?) {
        self.user = user
        self.loggedInUser = loggedInUser
        self.originalUser = user
        // make sure comparisons are using ID field.
        self.originalUser?.id = nil
    }
    
    var isLoaded: Bool { get { return self.user != nil } }
    
    var canBeUpdated: Bool {
        get {
            if let loggedInUser = self.loggedInUser, thisuser = self.user {
                if (loggedInUser.isAdmin) { return true }
                if (thisuser.isAuthorizedForUpdating(loggedInUser)) { return true }
                if (thisuser.id == nil) { return true }
            }
            return self.user != nil && self.user?.id == nil
        }
    }
    
    var canBeDeleted: Bool {
        get {
            return canBeUpdated && self.user != self.loggedInUser && self.user?.id != nil
        }
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
        get { return self.user?.emailAddress?.description }
        set {
            self.user?.emailAddress = EmailAddress(string: newValue)
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
    
    func createUser(completionHandler: (User?, NSError?) -> ()) {
        if let user = self.user {
            let handler = self.fireOnMainThread(completionHandler)
            Api.sharedInstance.createUser(user, completionHandler: handler)
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
    
    func getColorForEmailString(currentValue: String?) -> UIColor {
        if EmailAddress(string: currentValue) == nil {
            return UIColor.redColor()
        }
        return UIColor.blackColor()
    }
}