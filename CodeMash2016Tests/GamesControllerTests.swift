//
//  GamesControllerTests.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit
import XCTest
import RSDTesting
import RSDRESTServices
import RSDSerialization
import OHHTTPStubs
@testable import CodeMash2016

class GamesControllerTests: ControllerTestsBase {
    var controller: GamesController?
    var mockViewModel: PartialMockGamesViewModel?
    var called = false

    func getStoryboard(name: String) -> UIStoryboard? {
        let storyboardBundle = NSBundle(forClass: GamesController.classForCoder())
        return UIStoryboard(name: name, bundle: storyboardBundle)
    }

    class override func setUp() {
        super.setUp()
        Swizzler<GamesController>.swizzlePresentViewControllerAnimated()
        Swizzler<GamesController>.swizzleDismissViewControllerAnimated()
    }
    
    class override func tearDown() {
        Swizzler<GamesController>.swizzlePresentViewControllerAnimated()
        Swizzler<GamesController>.swizzleDismissViewControllerAnimated()

        super.tearDown()
    }
    
    override func setUp() {
        super.setUp()
        let storyboard = self.getStoryboard("Main")
        self.controller = storyboard?.instantiateViewControllerWithIdentifier("gamesController") as? GamesController
        
        self.controller?.view.hidden = false
        
        mockViewModel = PartialMockGamesViewModel(vm: self.controller!.viewModel! as! GamesViewModel)
        
        self.controller?.viewModel = mockViewModel
        self.called = false
    }
    
    override func tearDown() {
        self.controller = nil
        self.called = false
        super.tearDown()
    }
    

    func testGameScreenDisplaysInitialized() {
        self.controller!.setCurrentUserAndGames(self.getLoginUser(), games: self.getFakeGames(), users: self.getFakeUsers())
        
        XCTAssertTrue(self.controller != nil)
        XCTAssertTrue(self.controller!.numberOfSectionsInTableView(
            self.controller!.tableView) == 1)
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 1)
        
        let cell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))

        let titleText = cell?.viewWithTag(100) as? UILabel
        XCTAssertTrue(titleText?.text == .Some("D&D"))
        
        let ownerText = cell?.viewWithTag(101) as? UILabel
        XCTAssertTrue(ownerText?.text == .Some("One"))
    }

    func testComposeNewGameWouldDisplayAlert() {
        var alertView: UIViewController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated) -> Bool in
            alertView = viewController
            self.called = true
            return false
        })

        self.controller!.compose()
        
        XCTAssertTrue(alertView != nil)
        let gameTextField: UITextField? = alertView?.view?.embeddedView()
        XCTAssertTrue(gameTextField != nil)
    }

    func testComposeNewGameClickCreateSuccess() {
        self.controller!.setCurrentUserAndGames(self.getLoginUser(), games: self.getFakeGames(), users: self.getFakeUsers())
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 1)

        var alertView: UIAlertController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated) -> Bool in
            alertView = viewController as? UIAlertController
            self.called = true
            return false
        })
        
        self.controller!.compose()
        
        XCTAssertTrue(alertView != nil)
        let gameTextField: UITextField? = alertView?.view?.embeddedView()
        XCTAssertTrue(gameTextField != nil)
        gameTextField!.text = "Runequest"
        
        let createButton: UIButton? = alertView?.view?.embeddedView {(button: UIButton)-> Bool in
            return button.titleLabel?.text == .Some("OK")
        }
        XCTAssertTrue(createButton != nil)
        
        self.mockViewModel!.createGameCallback = {(game: Game) -> (Game?, NSError?) in
            return (Game(id: NSUUID(), title: game.title, owner: game.owner, users: game.users), nil)
        }
        
        createButton?.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 2)
    }

    func testComposeNewGameClickCreateFailure() {
        self.controller!.setCurrentUserAndGames(self.getLoginUser(), games: self.getFakeGames(), users: self.getFakeUsers())
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 1)
        
        var alertView: UIAlertController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated) -> Bool in
            alertView = viewController as? UIAlertController
            self.called = true
            return false
        })
        
        self.controller!.compose()
        
        XCTAssertTrue(alertView != nil)
        let gameTextField: UITextField? = alertView?.view?.embeddedView()
        XCTAssertTrue(gameTextField != nil)
        gameTextField!.text = "D&D"
        
        let createButton: UIButton? = alertView?.view?.embeddedView {(button: UIButton)-> Bool in
            return button.titleLabel?.text == .Some("OK")
        }
        XCTAssertTrue(createButton != nil)
        
        self.mockViewModel!.createGameCallback = {(game: Game) -> (Game?, NSError?) in
            return (nil, self.mockViewModel!.generateError(422, message: "Entity already exists"))
        }
        
        alertView = nil
        createButton?.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 1)
        XCTAssertTrue(alertView?.title == .Some("Entity already exists"))
    }

    
    func testComposeNewGameClickCancel() {
        self.controller!.setCurrentUserAndGames(self.getLoginUser(), games: self.getFakeGames(), users: self.getFakeUsers())
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 1)
        
        var alertView: UIAlertController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated) -> Bool in
            alertView = viewController as? UIAlertController
            self.called = true
            return false
        })
        
        self.controller!.compose()
        
        XCTAssertTrue(alertView != nil)
        let gameTextField: UITextField? = alertView?.view?.embeddedView()
        XCTAssertTrue(gameTextField != nil)
        gameTextField!.text = "Runequest"
        
        let cancelButton: UIButton? = alertView?.view?.embeddedView {(button: UIButton)-> Bool in
            return button.titleLabel?.text == .Some("Cancel")
        }
        XCTAssertTrue(cancelButton != nil)
        
        self.mockViewModel!.createGameCallback = {(game: Game) -> (Game?, NSError?) in
            return (Game(id: NSUUID(), title: game.title, owner: game.owner, users: game.users), nil)
        }
        
        cancelButton?.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 1)
    }
    
    func testDeleteGame() {
        self.controller!.setCurrentUserAndGames(self.getLoginUser(), games: self.getFakeGames(), users: self.getFakeUsers())

        var vmcount = self.controller!.viewModel!.tableView(self.controller!.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(vmcount, 1)
        
        var count = self.controller!.tableView.numberOfRowsInSection(0)
        XCTAssertEqual(count, 1)
        
        let gameCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(gameCell != nil)
        
        self.mockViewModel!.deleteGameAtIndexPathCallback = {(indexPath) -> NSError? in
            if let game = self.mockViewModel!.vm.getGameAtIndexPath(indexPath) {
                self.mockViewModel!.vm.removeGameFromList(game, error: nil)
                return nil
            }
            return self.mockViewModel!.generateError(403, message: "not found")
        }
        
        var actions = self.controller!.tableView(self.controller!.tableView, editActionsForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))!
        let deleteAction = actions[0]
        deleteAction.trigger(NSIndexPath(forRow: 0, inSection: 0))
        
        vmcount = self.controller!.viewModel!.tableView(self.controller!.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(vmcount, 0)
        
        count = self.controller!.tableView.numberOfRowsInSection(0)
        XCTAssertEqual(count, 0)
    }

}