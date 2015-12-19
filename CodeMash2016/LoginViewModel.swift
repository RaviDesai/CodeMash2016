//
//  LoginViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/23/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import RSDRESTServices

enum LoginTableCellIdentifier : String {
    case UsernameCell = "usernameCell"
    case PasswordCell = "passwordCell"
    case LoginCell = "loginCell"
    case CreateNewUserCell = "createNewUserCell"
}

protocol LoginViewModelProtocol: UITableViewDataSource {
    var isLoggingIn: Bool { get }
    var username: String { get set }
    var password: String { get set }
    var loginButtonLabel: String { get set }
    var loggedInUser: User? { get }
    
    func instantiateCell(cellIdentifier: LoginTableCellIdentifier, value: String, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell
    func executeLogin(completionHandler: (User?, NSError?)->())
    func getAllUsers(completionHandler: ([User]?, NSError?)->())
    func getAllGames(completionHandler: ([Game]?, NSError?) -> ())
}

class LoginViewModel : ViewModelBase, LoginViewModelProtocol {
    private var cellInstantiator: ((LoginTableCellIdentifier, String, UITableView, NSIndexPath) -> UITableViewCell)
    static var site = APISite(name: "api", uri: "https://desai.com/")

    private(set) var isLoggingIn: Bool
    
    var username: String = ""
    var password: String = ""
    var loginButtonLabel: String = "Login"
    var createNewUserLabel: String = "Create New User"
    private(set) var loggedInUser: User?
    
    func getCellIdentifier(indexPath: NSIndexPath) -> LoginTableCellIdentifier {
        switch(indexPath.row) {
        case 0: return LoginTableCellIdentifier.UsernameCell
        case 1: return LoginTableCellIdentifier.PasswordCell
        case 2: return LoginTableCellIdentifier.LoginCell
        default: return LoginTableCellIdentifier.CreateNewUserCell
        }
    }
    
    func getCellValue(indexPath: NSIndexPath) -> String {
        switch(indexPath.row) {
        case 0: return self.username
        case 1: return self.password
        case 2: return self.loginButtonLabel
        default: return self.createNewUserLabel
        }
    }
    
    init(cellInstantiator: (LoginTableCellIdentifier, String, UITableView, NSIndexPath) -> UITableViewCell) {
        self.cellInstantiator = cellInstantiator
        self.isLoggingIn = false
        
        if let mockLogin = UIApplication.sharedApplication().delegate as? ApplicationMockLoginProtocol {
            if let validLogin = mockLogin.validLogin {
                self.username = validLogin.username
                self.password = validLogin.password
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.instantiateCell(self.getCellIdentifier(indexPath), value: self.getCellValue(indexPath), tableView: tableView, indexPath: indexPath)
    }
    
    func instantiateCell(cellIdentifier: LoginTableCellIdentifier, value: String, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        return self.cellInstantiator(cellIdentifier, value, tableView, indexPath)
    }
    
    func executeLogin(completionHandler: (User?, NSError?)->()) {
        let handler = self.fireOnMainThread(completionHandler)
        Client.sharedClient.authenticate(LoginViewModel.site, username: self.username, password: self.password, completion: {(userId, error) -> () in
            if let myerror = error {
                handler(nil, myerror)
                return
            }
            guard let myUserId = userId else {
                handler(nil, nil)
                return
            }
            Api.sharedInstance.getUser(myUserId, completionHandler: {(user, error) -> () in
                self.loggedInUser = user
                handler(user, error)
            })
        })
    }
    
    func getAllUsers(completionHandler: ([User]?, NSError?)->()) {
        let handler = self.fireOnMainThread(completionHandler)
        Api.sharedInstance.getAllUsers(handler)
    }
    
    func getAllGames(completionHandler: ([Game]?, NSError?) -> ()) {
        let handler = self.fireOnMainThread(completionHandler)
        Api.sharedInstance.getAllGames(self.loggedInUser, completionHandler: handler)
    }
}