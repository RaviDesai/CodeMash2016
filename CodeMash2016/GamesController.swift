//
//  GamesController.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/16/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

class GamesController: UITableViewController {
    var viewModel: GamesViewModel?
    func ensureViewModelIsCreated() {
        if (self.viewModel != nil) { return }
        self.viewModel = GamesViewModel(cellInstantiator: { (title, owner, tableView, indexPath) -> UITableViewCell in
            
            let resultCell = self.tableView.dequeueReusableCellWithIdentifier(GamesViewModel.cellIdentifier, forIndexPath: indexPath)
            let titleField = resultCell.viewWithTag(100) as? UILabel
            titleField?.text = title
            let ownerField = resultCell.viewWithTag(101) as? UILabel
            ownerField?.text = owner
            
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
        super.viewDidLoad()
        ensureViewModelIsCreated()
        instantiateFromViewModel()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.title = "Games"
    }

    func setCurrentUserAndGames(owner: User?, games: [Game]?, error: NSError?) {
        guard let mygames = games, myowner = owner else {
            self.popBackToCallerWithMissingDataMessage()
            return
        }
        ensureViewModelIsCreated()
        self.viewModel?.setCurrentUserAndGames(myowner, games: mygames)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowMessages") {
            if let controller = segue.destinationViewController as? MessageListController,
                let indexPath = self.tableView.indexPathForSelectedRow {
                self.viewModel?.getMessagesForGame(indexPath, completionHandler: { (messages, error) -> () in
                    controller.setMessages(self.viewModel?.currentUser, game: self.viewModel?.games?[indexPath.row], messages: messages, error: error)
                })
            }
        }
    }

}
