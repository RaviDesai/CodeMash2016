//
//  GamesViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/16/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

protocol GamesViewModelProtocol: UITableViewDataSource {
    var loggedInUser: User? { get }
    var games: [Game]? { get }
    var users: [User]? { get }
    var totalGames: Int { get }
    
    func loadData(user: User?, games: [Game]?, users: [User]?)
    func instantiateCell(title: String?, name: String?, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell
    func createGame(game: Game, completionHandler: (Game?, NSError?)->())
    func getMessagesForGame(indexPath: NSIndexPath, completionHandler: ([Message]?, NSError?)->())
    func canDeleteGameAtIndexPath(indexPath: NSIndexPath) -> Bool
    func deleteGameAtIndexPath(indexPath: NSIndexPath, completionHandler: (NSError?)->())
}

class GamesViewModel: ViewModelBase, GamesViewModelProtocol {
    var loggedInUser: User?
    var cellInstantiator: (String?, String?, UITableView, NSIndexPath) -> UITableViewCell
    var games: [Game]?
    var users: [User]?
    static let cellIdentifier = "gamesIRunCell"
    var totalGames: Int { get { return games?.count ?? 0 } }

    
    init(cellInstantiator: (String?, String?, UITableView, NSIndexPath) -> UITableViewCell) {
        self.cellInstantiator = cellInstantiator
    }
    
    func loadData(user: User?, games: [Game]?, users: [User]?) {
        self.loggedInUser = user
        self.users = users
        self.games = games
    }
    
    func getGameAtIndexPath(indexPath: NSIndexPath) -> Game? {
        if let games = self.games where indexPath.row < games.count {
            return games[indexPath.row]
        }
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalGames
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var title: String?
        var userName: String?
        if let game = self.getGameAtIndexPath(indexPath) {
            title = game.title
            if let owner = self.users?.filter({ $0.id == game.owner }).first {
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
        
        if let game = self.getGameAtIndexPath(indexPath) {
            Api.sharedInstance.getMessagesForGame(game, completionHandler: handler)
        } else {
            handler(nil, nil)
        }
    }
    
    func createGame(game: Game, completionHandler: (Game?, NSError?) -> ()) {
        let handler = self.fireOnMainThread(completionHandler)
        Api.sharedInstance.createGame(game, completionHandler: {(game, error)->() in
            self.appendGameToList(game, error: error)
            handler(game, error)
        })
    }
    
    func appendGameToList(game: Game?, error: NSError?) {
        if let mygame = game where error == nil {
            self.games?.append(mygame)
            self.games?.sortInPlace(<)
        }
    }
    
    func removeGameFromList(game: Game?, error: NSError?) {
        if let mygame = game where error == nil {
            self.games = self.games?.filter { $0 != mygame }
        }
    }
    
    func canDeleteGameAtIndexPath(indexPath: NSIndexPath) -> Bool {
        if let game = self.getGameAtIndexPath(indexPath), loggedInUser = self.loggedInUser {
            return loggedInUser.isAdmin || game.owner == loggedInUser.id
        }
        return false
    }
    
    func deleteGameAtIndexPath(indexPath: NSIndexPath, completionHandler: (NSError?)->()) {
        let handler = self.fireOnMainThread(completionHandler)
        if let game = self.getGameAtIndexPath(indexPath) {
            Api.sharedInstance.deleteGame(game, completionHandler: {(error)->() in
                self.removeGameFromList(game, error: error)
                handler(error)
            })
        }
    }
    
}
