//
//  TabBarViewModelProtocol.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/10/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

protocol TabBarViewModelProtocol {
    var loggedInUser: User? { get }
    
    func getAllUsers(completionHandler: ([User]?, NSError?)->())
    func getAllGames(completionHandler: ([Game]?, NSError?) -> ())
    func setUser(loggedInUser: User?)
    func logout(completionHandler: ()->())
}

class TabBarViewModel: ViewModelBase, TabBarViewModelProtocol {
    var loggedInUser: User?
    
    func setUser(loggedInUser: User?) {
        self.loggedInUser = loggedInUser
    }
    func getAllUsers(completionHandler: ([User]?, NSError?)->()) {
        let handler = self.fireOnMainThread(completionHandler)
        Api.sharedInstance.getAllUsers(handler)
    }
    
    func getAllGames(completionHandler: ([Game]?, NSError?) -> ()) {
        let handler = self.fireOnMainThread(completionHandler)
        Api.sharedInstance.getAllGames(self.loggedInUser, completionHandler: handler)
    }
    
    func logout(completionHandler: ()->()) {
        let handler = self.fireNoResultOnMainThread(completionHandler)
        Api.sharedInstance.logout(handler)
    }
}
