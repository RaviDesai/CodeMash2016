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
    var loginCallback: (()-> (User?, NSError?))?
    var getAllUsersCallback: (() -> ([User]?, NSError?))?
    var getAllGamesCallback: (() -> ([Game]?, NSError?))?
    
    init(vm: LoginViewModel) {
        self.vm = vm
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
        if let callback = self.loginCallback {
            completionHandler(callback())
        } else {
            completionHandler(nil, self.generateError(405, message: "unimplemented"))
        }
    }
    
    func getAllUsers(completionHandler: ([User]?, NSError?)->()) {
        if let callback = self.getAllUsersCallback {
            completionHandler(callback())
        } else {
            completionHandler(nil, self.generateError(405, message: "unimplemented"))
        }
    }
    
    func getAllGames(completionHandler: ([Game]?, NSError?)->()) {
        if let callback = self.getAllGamesCallback {
            completionHandler(callback())
        } else {
            completionHandler(nil, self.generateError(405, message: "unimplemented"))
        }
    }


}