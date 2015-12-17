//
//  LoginController.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/23/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

class LoginController: UITableViewController {
    var viewModel: LoginViewModelProtocol?
    var loginButton: UIButton?
    var createNewButton: UIButton?
    
    func ensureViewModelIsCreated() {
        if (self.viewModel != nil) { return }

        self.viewModel = LoginViewModel(cellInstantiator: { (cellIdentifier, value, tableView, indexPath) -> UITableViewCell in
            
            let resultcell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier.rawValue, forIndexPath: indexPath)
            
            var t: UITextField?
            var b: UIButton?
            
            switch(indexPath.row) {
            case 0:
                resultcell.selectionStyle = UITableViewCellSelectionStyle.None
                t = resultcell.viewWithTag(100) as? UITextField
                t?.addTarget(self, action: "usernameEditingChanged:", forControlEvents: UIControlEvents.EditingChanged)
                t?.text = value
                break;
            case 1:
                resultcell.selectionStyle = UITableViewCellSelectionStyle.None
                t = resultcell.viewWithTag(100) as? UITextField
                t?.addTarget(self, action: "passwordEditingChanged:", forControlEvents: UIControlEvents.EditingChanged)
                t?.text = value
                break;
            case 2:
                resultcell.selectionStyle = UITableViewCellSelectionStyle.None
                b = resultcell.viewWithTag(100) as? UIButton
                self.loginButton = b
                b?.addTarget(self, action: Selector("loginPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
                b?.setTitle(value, forState: UIControlState.Normal)
                b?.enabled = (!self.viewModel!.isLoggingIn)
                break;
            case 3:
                resultcell.selectionStyle = UITableViewCellSelectionStyle.None
                b = resultcell.viewWithTag(100) as? UIButton
                self.createNewButton = b
                //b?.addTarget(self, action: Selector("createNewUserPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
                b?.setTitle(value, forState: UIControlState.Normal)
                b?.enabled = (!self.viewModel!.isLoggingIn)
                break;
            default:
                resultcell.selectionStyle = UITableViewCellSelectionStyle.None
                break;
                
            }
            return resultcell
        })
    }
    
    func instantiateFromViewModel() {
        if (self.viewModel == nil) { return }
        if (!self.isViewLoaded()) { return }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self.viewModel!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ensureViewModelIsCreated()
        instantiateFromViewModel()
    }
    
    func usernameEditingChanged(sender: UITextField) {
        self.viewModel?.username = sender.text ?? ""
    }
    
    func passwordEditingChanged(sender: UITextField) {
        self.viewModel?.password = sender.text ?? ""
    }
    
    func loginPressed(sender: UIButton) {
        self.loginButton?.enabled = false
        self.createNewButton?.enabled = false
        self.viewModel?.executeLogin({ (userId, error) -> () in
            self.loginButton?.enabled = true
            self.createNewButton?.enabled = true
            guard let errorOccurred = error else {
                self.performSegueWithIdentifier("TabController", sender: self)
                return
            }
            self.notifyUserOfError(errorOccurred, withCallbackOnDismissal: { () -> () in })
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateUser" {
            if let createUserController = segue.destinationViewController as? UpdateUserController {
                createUserController.setUser(User(id: nil, name: "", password: "pass", emailAddress: nil, image: nil), userWasModified: { (deletedOrSaved, user) -> () in
                    if (deletedOrSaved == DeletedOrSaved.Saved) {
                        if let newUser = user {
                            self.viewModel?.username = newUser.name
                            self.viewModel?.password = newUser.password
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        } else if segue.identifier == "TabController" {
            if let tabController = segue.destinationViewController as? TabController {
                tabController.setLoggedInUser(self.viewModel?.loggedInUser)
            }
        }
    }

}