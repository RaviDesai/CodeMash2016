//
//  MessageListViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/16/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

protocol MessageListViewModelProtocol {
    var currentUser: User? { get set }
    var game: Game? { get set }
    var messages: [Message]? { get set }
    var isLoaded: Bool { get }
    
    func instantiateCell(message: Message?, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell
    func setMessages(currentUser: User?, game: Game?, users: [User]?, messages: [Message])
}

class MessageListViewModel: NSObject, UITableViewDataSource, MessageListViewModelProtocol {
    static var cellIdentifier = "messageCell"
    
    var cellInstantiator: (Message?, UITableView, NSIndexPath) -> UITableViewCell
    var messages: [Message]?
    var game: Game?
    var users: [User]?
    var currentUser: User?
    
    init(cellInstantiator: (Message?, UITableView, NSIndexPath)->UITableViewCell) {
        self.cellInstantiator = cellInstantiator
    }
    
    private var numberOfMessages: Int {
        get { return self.messages?.count ?? 0 }
    }
    
    var isLoaded: Bool { get { return self.messages != nil } }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfMessages
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var message: Message? = nil
        if indexPath.row >= 0 && indexPath.row < numberOfMessages {
            message = self.messages?[indexPath.row]
        }
        return self.instantiateCell(message, tableView: tableView, indexPath: indexPath)
    }
    
    func instantiateCell(message: Message?, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        return self.cellInstantiator(message, tableView, indexPath)
    }
    
    func setMessages(currentUser: User?, game: Game?, users: [User]?, messages: [Message]) {
        self.currentUser = currentUser
        self.game = game
        self.users = users
        self.messages = messages
    }
}