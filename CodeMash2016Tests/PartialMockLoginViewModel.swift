//
//  PartialMockLoginViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/14/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation
import RSDRESTServices
@testable import CodeMash2016

class PartialMockLoginViewModel: NSObject, LoginViewModelProtocol {
    var vm: LoginViewModel
    var fakedUsers: [User]?
    var fakedGames: [Game]?
    var loginSucceeds: Bool
    
    init(vm: LoginViewModel, fakedUsers: [User]?, fakedGames: [Game]?, loginSucceeds: Bool) {
        self.vm = vm
        self.fakedUsers = fakedUsers
        self.loginSucceeds = loginSucceeds
    }
    
    var isLoggingIn: Bool {
        get { return self.vm.isLoggingIn }
    }
    
    var username: String {
        get { return self.vm.username }
        set { self.vm.username = newValue }
    }
    var password: String {
        get { return self.vm.password }
        set { self.vm.password = newValue }
    }
    var loginButtonLabel: String {
        get { return self.vm.loginButtonLabel }
        set { self.vm.loginButtonLabel = newValue }
    }
    
    var loggedInUser: User? { get { return self.vm.loggedInUser } }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.vm.numberOfSectionsInTableView(tableView)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.vm.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }

    
    func generateError(statusCode: Int, message: String) -> NSError? {
        let response = NetworkResponse.HTTPStatusCodeFailure(statusCode, message)
        return response.getError()
    }
    
    func instantiateCell(cellIdentifier: LoginTableCellIdentifier, value: String, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        return self.vm.instantiateCell(cellIdentifier, value: value, tableView: tableView, indexPath: indexPath)
    }
    
    func executeLogin(completionHandler: (User?, NSError?)->()) {
        if self.loginSucceeds {
            let user = self.fakedUsers?[0];
            completionHandler(user, nil)
        } else {
            completionHandler(nil, self.generateError(401, message: "unauthorized"))
        }
    }
    
    func getAllUsers(completionHandler: ([User]?, NSError?)->()) {
        let userError = fakedUsers == nil ? generateError(500, message: "internal error") : nil
        completionHandler(fakedUsers, userError)
    }
    
    func getAllGames(completionHandler: ([Game]?, NSError?)->()) {
        let gamesError = fakedGames == nil ? generateError(500, message: "internal error") : nil
        completionHandler(fakedGames, gamesError)
    }


}