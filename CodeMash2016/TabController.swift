//
//  TabController.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/10/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

protocol NamedTabProtocol {
    var tabName: String { get }
}

class TabController: UITabBarController, UITabBarControllerDelegate {
    var viewModel: TabBarViewModelProtocol?
    var composeButton: UIBarButtonItem?
    
    func ensureViewModelIsCreated() {
        if (self.viewModel != nil) { return }
        viewModel = TabBarViewModel()
    }
    
    func initializeComponentsFromViewModel() {
        guard let vm = self.viewModel where vm.isLoaded else { return }
        if (!self.isViewLoaded()) { return }
        
        self.composeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: Selector("compose:"))
        
        if let gamesController = self.viewControllers?[1] as? GamesController {
            gamesController.loadData(self.viewModel?.loggedInUser, games: self.viewModel?.games, users: self.viewModel?.users)
        }

        if let usersController = self.viewControllers?[0] as? ShowUsersController {
            usersController.loadData(self.viewModel?.users, loggedInUser: self.viewModel?.loggedInUser)
            self.title = usersController.title
        }
    }

    func loadData(loggedInUser: User?, users: [User]?, games: [Game]?, error: NSError?) {
        if (loggedInUser == nil || users == nil || games == nil || error != nil) {
            self.popBackToCallerWithMissingDataMessage()
            return
        }
        ensureViewModelIsCreated()
        viewModel?.loadData(loggedInUser, users: users, games: games)
        initializeComponentsFromViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        ensureViewModelIsCreated()
        initializeComponentsFromViewModel()
    }
    
    override func navigationShouldPopOnBackButton() -> Bool {
        let title = "Logout"
        let message: String? = "Are you sure you wish to log out?"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let exitAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.viewModel?.logout {
                if let mockLogin = UIApplication.sharedApplication().delegate as? ApplicationMockLoginProtocol {
                    mockLogin.logoff()
                }
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
        }
        
        alert.addAction(exitAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        return false
    }
    
    func compose(sender: UIButton) {
        if let composable = self.selectedViewController as? ComposableControllerProtocol {
            composable.compose()
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let namedTab = viewController as? NamedTabProtocol {
            self.title = namedTab.tabName
        }
        if viewController is ComposableControllerProtocol {
            if let composeButton = self.composeButton {
                self.navigationItem.rightBarButtonItem = composeButton
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
}