//
//  ShowUsersViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import RSDRESTServices

protocol ShowUsersViewModelProtocol: UITableViewDataSource {
    var users: [User]? { get }
    var loggedInUser: User? { get }
    var isLoaded: Bool { get }
    var totalUsers: Int { get }
    
    func getUserAtIndexPath(indexPath: NSIndexPath) -> User?
    func userWasUpdated(user: User, atIndexPath indexPath: NSIndexPath)
    func userWasDeleted(indexPath: NSIndexPath)
    func loadData(users: [User], loggedInUser: User?)
    func instantiateCell(user: User?, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell
}

class ShowUsersViewModel: ViewModelBase, ShowUsersViewModelProtocol {
    static var cellIdentifier = "userCellIdentifier"
    var users: [User]?
    var loggedInUser: User?
    var isLoaded: Bool { get { return users != nil } }
    
    private var cellInstantiator: ((User?, UITableView, NSIndexPath) -> UITableViewCell)
    
    init(cellInstantiator: ((User?, UITableView, NSIndexPath) -> UITableViewCell)) {
        self.cellInstantiator = cellInstantiator
    }

    func loadData(users: [User], loggedInUser: User?) {
        self.users = users
        self.loggedInUser = loggedInUser
    }
 
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalUsers
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    var totalUsers: Int {
        return self.users?.count ?? 0
    }
    
    func getUserAtIndexPath(indexPath: NSIndexPath) -> User? {
        if (indexPath.row >= 0 && indexPath.row < self.totalUsers) {
            return self.users?[indexPath.row]
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.instantiateCell(self.getUserAtIndexPath(indexPath), tableView: tableView, indexPath: indexPath)
    }
    
    func instantiateCell(user: User?, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        return self.cellInstantiator(user, tableView, indexPath)
    }
    
    func userWasUpdated(user: User, atIndexPath indexPath: NSIndexPath) {
        if (self.users == nil || indexPath.row >= self.users!.count || indexPath.row < 0) {
            return
        }
        
        self.users?[indexPath.row] = user;
    }
    
    func userWasDeleted(indexPath: NSIndexPath) {
        if (self.users == nil || indexPath.row >= self.users!.count || indexPath.row < 0) {
            return
        }
        
        self.users?.removeAtIndex(indexPath.row)
    }

}
