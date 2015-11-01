//
//  ShowUsersController.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

class ShowUsersController: UITableViewController {
    var viewModel: ShowUsersViewModel?
    
    func ensureViewModelIsCreated() {
        if (self.viewModel != nil) { return }
     
        self.viewModel = ShowUsersViewModel(cellInstantiator: { (user, tableView, indexPath) -> UITableViewCell in
            
            let resultCell = self.tableView.dequeueReusableCellWithIdentifier(self.viewModel!.cellIdentifier, forIndexPath: indexPath) as! UserTableViewCell
            
            resultCell.setUser(user)
            return resultCell

        })
    }
    
    func instantiateFromViewModel() {
        if (self.viewModel == nil) { return }
        if (!self.isViewLoaded()) { return }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self.viewModel!
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        ensureViewModelIsCreated()
        instantiateFromViewModel()
    }
    
    func setUsers(users: [User]?, error: NSError?) {
        if let retrieveError = error {
            self.notifyUserOfError(retrieveError, withCallbackOnDismissal: { () -> () in })
            self.popBackToCallerWithMissingDataMessage()
            return
        }
        ensureViewModelIsCreated()
        self.viewModel?.setUsers(users!, completionHandler: { (err) -> () in
            self.instantiateFromViewModel()
        })
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ModifyUser") {
            if let updateUserController = segue.destinationViewController as? UpdateUserController {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    updateUserController.setUser(self.viewModel?.getUserAtIndexPath(indexPath), userWasModified: {(deletedOrSaved, user)->() in
                        if deletedOrSaved == .Saved {
                            if let updatedUser = user {
                                self.viewModel?.updateUser(updatedUser, atIndexPath: indexPath)
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                            }
                        } else {
                            self.viewModel?.deleteUserAtIndexPath(indexPath)
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                        }
                    })
                }
            }
        }

    }
}
