//
//  LoginController.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/23/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

class LoginController: UITableViewController {
    var viewModel: LoginViewModel?
    var loginButton: UIButton?
    
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
            default:
                resultcell.selectionStyle = UITableViewCellSelectionStyle.None
                break;
                
            }
            return resultcell
        })
    }
    
    func instantiateFromViewModel() {
        if (self.viewModel == nil) { return }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self.viewModel!
    }
    
    override func viewDidLoad() {
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
        self.viewModel?.executeLogin({ (error) -> () in
            self.loginButton?.enabled = true
            guard let errorOccurred = error else {
                self.performSegueWithIdentifier("ShowUsers", sender: self)
                return
            }
            self.notifyUserOfError(errorOccurred, withCallbackOnDismissal: { () -> () in })
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowUsers" {
            if let usersController = segue.destinationViewController as? ShowUsersController {
                self.viewModel?.getAllUsers({ (users, error) -> () in
                    usersController.setUsers(users, error: error)
                })
            }
        }
    }

}