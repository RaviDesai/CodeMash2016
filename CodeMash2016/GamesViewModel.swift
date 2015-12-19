//
//  GamesViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/16/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

protocol GamesViewModelProtocol {
    var currentUser: User? { get set }
    var games: [Game]? { get set }
    func instantiateCell(title: String?, name: String?, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell
    func createGame(game: Game, completionHandler: (Game?, NSError?)->())
}

class GamesViewModel: ViewModelBase, UITableViewDataSource, GamesViewModelProtocol {
    var currentUser: User?
    var cellInstantiator: (String?, String?, UITableView, NSIndexPath) -> UITableViewCell
    var games: [Game]?
    var users: [User]?
    static let cellIdentifier = "gamesIRunCell"
    
    init(cellInstantiator: (String?, String?, UITableView, NSIndexPath) -> UITableViewCell) {
        self.cellInstantiator = cellInstantiator
    }
    
    func setCurrentUserAndGames(user: User?, games: [Game]?, users: [User]?) {
        self.currentUser = user
        self.users = users
        self.games = games
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var title: String?
        var userName: String?
        if let games = self.games where indexPath.row < games.count {
            title = games[indexPath.row].title
            if let owner = self.users?.filter({ $0.id == games[indexPath.row].owner }).first {
                userName = owner.name
            }
            
        }
        return self.instantiateCell(title, name: userName, tableView: tableView, indexPath: indexPath)
    }
    
    func instantiateCell(title: String?, name: String?, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        return self.cellInstantiator(title, name, tableView, indexPath)
    }
    
    func getMessagesForGame(indexPath: NSIndexPath, completionHandler: ([Message]?, NSError?)->()) {
        let handler = self.fireOnMainThread(completionHandler)
        
        if let games = self.games where indexPath.row < games.count {
            let game = games[indexPath.row];
            Api.sharedInstance.getMessagesForGame(game, completionHandler: handler)
        } else {
            handler(nil, nil)
        }
    }
    
    func createGame(game: Game, completionHandler: (Game?, NSError?) -> ()) {
        let handler = self.fireOnMainThread(completionHandler)
        Api.sharedInstance.createGame(game, completionHandler: {(game, error)->() in
            if let mygame = game where error == nil {
                self.games?.append(mygame)
                self.games?.sortInPlace(<)
            }
            handler(game, error)
        })
    }
    
}
