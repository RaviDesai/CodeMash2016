//
//  MessageListController.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/16/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

class MessageListController: UITableViewController {
    var viewModel: MessageListViewModel?
    
    func ensureViewModelIsCreated() {
        if (self.viewModel != nil) { return }
        
        self.viewModel = MessageListViewModel(cellInstantiator: { (message, tableView, indexPath) -> UITableViewCell in
            let resultCell = self.tableView.dequeueReusableCellWithIdentifier(MessageListViewModel.cellIdentifier, forIndexPath: indexPath) as! MessageCell
            
            resultCell.setMessage(message)
            return resultCell
        })
    }
    
    func initializeComponentsFromViewModel() {
        guard let isLoaded = self.viewModel?.isLoaded where isLoaded else { return }
        if (!self.isViewLoaded()) { return }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self.viewModel
        self.tableView.reloadData()
    }
    
    func setMessages(currentUser: User?, game: Game?, messages: [Message]?, error: NSError?) {
        guard let myMessages = messages where error == nil else {
            self.popBackToCallerWithMissingDataMessage()
            return
        }
        self.viewModel?.setMessages(currentUser, game: game, messages: myMessages)
    }
}