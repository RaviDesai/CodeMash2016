//
//  ShowUsersController.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

class ShowUsersController: UITableViewController, NamedTabProtocol {
    var viewModel: ShowUsersViewModelProtocol?
    var tabName: String { return "Users" }
    
    func ensureViewModelIsCreated() {
        if (self.viewModel != nil) { return }
     
        self.viewModel = ShowUsersViewModel(cellInstantiator: { (user, tableView, indexPath) -> UITableViewCell in
            
            let resultCell = self.tableView.dequeueReusableCellWithIdentifier(ShowUsersViewModel.cellIdentifier, forIndexPath: indexPath) as! UserTableViewCell
            
            resultCell.setUser(user)
            return resultCell

        })
    }
    
    func initializeComponentsFromViewModel() {
        guard let isLoaded = self.viewModel?.isLoaded where isLoaded else { return }
        if (!self.isViewLoaded()) { return }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self.viewModel!
        self.tableView.reloadData()
        
        let composeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: Selector("newMessage:"))
        self.navigationItem.rightBarButtonItem = composeButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ensureViewModelIsCreated()
        initializeComponentsFromViewModel()
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        self.tabBarController?.title = "Users"
//    }
    
    func setUsers(users: [User]?, loggedInUser: User?) {
        guard let myUsers = users, myLoggedInUser = loggedInUser else {
            self.notifyUserOfError(self.generateMissingDataMessage(), withCallbackOnDismissal: { () -> () in })
            return
        }
        ensureViewModelIsCreated()
        self.viewModel?.setUsers(myUsers, loggedInUser: myLoggedInUser)
        self.initializeComponentsFromViewModel()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func newMessage(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("NewMessage", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ModifyUser") {
            if let updateUserController = segue.destinationViewController as? UpdateUserController {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    updateUserController.setUser(self.viewModel?.getUserAtIndexPath(indexPath), loggedInUser: self.viewModel?.loggedInUser, userWasModified: {(deletedOrSaved, user)->() in
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
        } else if (segue.identifier == "NewMessage") {
            if let controller =  segue.destinationViewController as? MessageController {
                controller.setContacts(self.viewModel?.users?.map { $0.emailAddress }.filter { $0 != nil }.map { $0! })
            }
        }

    }
    
}
