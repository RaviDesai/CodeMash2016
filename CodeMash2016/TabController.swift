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
    
    func setLoggedInUser(loggedInUser: User?, users: [User]?, games: [Game]?, error: NSError?) {
        if (loggedInUser == nil || users == nil || games == nil || error != nil) {
            self.popBackToCallerWithMissingDataMessage()
            return
        }
        ensureViewModelIsCreated()
        viewModel?.setUser(loggedInUser, users: users, games: games)
        instantiateFromViewModel()
    }
    
    func ensureViewModelIsCreated() {
        if (self.viewModel != nil) { return }
        viewModel = TabBarViewModel()
    }
    
    func instantiateFromViewModel() {
        guard let vm = self.viewModel where vm.isLoaded else { return }
        if (!self.isViewLoaded()) { return }
        
        let composeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: Selector("compose:"))
        
        self.navigationItem.rightBarButtonItem = composeButton
        
        if let gamesController = self.viewControllers?[1] as? GamesController {
            gamesController.setCurrentUserAndGames(self.viewModel?.loggedInUser, games: self.viewModel?.games, users: self.viewModel?.users)
            self.title = gamesController.title
        }

        if let usersController = self.viewControllers?[0] as? ShowUsersController {
            usersController.setUsers(self.viewModel?.users, loggedInUser: self.viewModel?.loggedInUser)
            self.title = usersController.title
        }
    }

    override func navigationShouldPopOnBackButton() -> Bool {
        let title = "Logout"
        let message: String? = "Are you sure you wish to log out?"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let exitAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.viewModel?.logout {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        ensureViewModelIsCreated()
        instantiateFromViewModel()
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
    }
}