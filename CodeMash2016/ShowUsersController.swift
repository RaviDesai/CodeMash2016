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
    
    func loadData(users: [User]?, loggedInUser: User?) {
        guard let myUsers = users, myLoggedInUser = loggedInUser else {
            self.notifyUserOfError(self.generateMissingDataMessage(), withCallbackOnDismissal: { () -> () in })
            return
        }
        ensureViewModelIsCreated()
        self.viewModel?.loadData(myUsers, loggedInUser: myLoggedInUser)
        self.initializeComponentsFromViewModel()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ModifyUser") {
            if let updateUserController = segue.destinationViewController as? UpdateUserController {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    updateUserController.loadData(self.viewModel?.getUserAtIndexPath(indexPath), loggedInUser: self.viewModel?.loggedInUser, userWasModified: {(deletedOrSaved, user)->() in
                        if deletedOrSaved == .Saved {
                            if let updatedUser = user {
                                self.viewModel?.userWasUpdated(updatedUser, atIndexPath: indexPath)
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                            }
                        } else {
                            self.viewModel?.userWasDeleted(indexPath)
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                        }
                    })
                }
            }
        }
    }
    
}
