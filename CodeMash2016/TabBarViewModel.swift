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
    var users: [User]? { get }
    var games: [Game]? { get }
    var isLoaded: Bool { get }
    
    func setUser(loggedInUser: User?, users: [User]?, games: [Game]?)
    func logout(completionHandler: ()->())
}

class TabBarViewModel: ViewModelBase, TabBarViewModelProtocol {
    var loggedInUser: User?
    var users: [User]?
    var games: [Game]?
    
    var isLoaded: Bool { get { return loggedInUser != nil && users != nil && games != nil } }
    
    func setUser(loggedInUser: User?, users: [User]?, games: [Game]?) {
        self.loggedInUser = loggedInUser
        self.users = users
        self.games = games
    }
    
    func logout(completionHandler: ()->()) {
        let handler = self.fireNoResultOnMainThread(completionHandler)
        Api.sharedInstance.logout(handler)
    }
}
