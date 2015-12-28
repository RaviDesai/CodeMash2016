//
//  PartialMockShowUsersViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation
import RSDRESTServices
@testable import CodeMash2016

class PartialMockGamesViewModel: PartialMockViewModelBase, GamesViewModelProtocol {
    var vm: GamesViewModel
    var currentUser: User? { get { return self.vm.currentUser } }
    var games: [Game]? { get { return self.vm.games } }
    var users: [User]? { get { return self.vm.users } }
    var totalGames: Int { get { return self.vm.totalGames } }
    var createGameCallback: ((Game) -> (Game?, NSError?))?
    var getMessagesForGameCallback: (() -> ([Message]?, NSError?))?
    var deleteGameAtIndexPathCallback: ((NSIndexPath)-> NSError?)?
    
    init(vm: GamesViewModel) {
        self.vm = vm
    }
    
    func instantiateCell(title: String?, name: String?, tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        return self.vm.instantiateCell(title, name: name, tableView: tableView, indexPath: indexPath)
    }
    
    func setCurrentUserAndGames(user: User?, games: [Game]?, users: [User]?) {
        self.vm.setCurrentUserAndGames(user, games: games, users: users)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.vm.numberOfSectionsInTableView(tableView)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.vm.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }

    func canDeleteGameAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return vm.canDeleteGameAtIndexPath(indexPath)
    }

    func createGame(game: Game, completionHandler: (Game?, NSError?)->()) {
        if let createGameCallback = self.createGameCallback {
            let (createdGame, createError) = createGameCallback(game)
            self.vm.appendGameToList(createdGame, error: createError)
            completionHandler(createdGame, createError)
        } else {
            completionHandler(nil, self.generateError(405, message: "unimplemented"))
        }
    }
    
    func getMessagesForGame(indexPath: NSIndexPath, completionHandler: ([Message]?, NSError?)->()) {
        if let getMessagesForGameCallback = self.getMessagesForGameCallback {
            completionHandler(getMessagesForGameCallback())
        } else {
            completionHandler(nil, self.generateError(405, message: "unimplemented"))
        }
    }
    
    
    func deleteGameAtIndexPath(indexPath: NSIndexPath, completionHandler: (NSError?) -> ()) {
        if let deleteGameCallback = self.deleteGameAtIndexPathCallback, let game = self.vm.getGameAtIndexPath(indexPath) {
            let error = deleteGameCallback(indexPath)
            self.vm.removeGameFromList(game, error: error)
            completionHandler(error)
        } else {
            completionHandler(self.generateError(405, message: "unimplemented"))
        }
    }
}