//
//  TabController.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/10/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

class TabController: UITabBarController {
    var viewModel: TabBarViewModelProtocol?
    
    func setLoggedInUser(loggedInUser: User?) {
        ensureViewModelIsCreated()
        viewModel?.setUser(loggedInUser)
    }
    
    func ensureViewModelIsCreated() {
        if (self.viewModel != nil) { return }
        viewModel = TabBarViewModel()
    }
    
    func instantiateFromViewModel() {
        if (self.viewModel == nil) { return }
        if (!self.isViewLoaded()) { return }
        
        if let usersController = self.viewControllers?[0] as? ShowUsersController {
            self.viewModel?.getAllUsers({ (users, error) -> () in
                usersController.setUsers(users, loggedInUser: self.viewModel?.loggedInUser, error: error)
                if let gamesController = self.viewControllers?[1] as? GamesController {
                    self.viewModel?.getAllGames({ (games, error) -> () in
                        gamesController.setCurrentUserAndGames(self.viewModel?.loggedInUser, games: games, error: error)
                    })
                }
            })
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
        ensureViewModelIsCreated()
        instantiateFromViewModel()
    }

}