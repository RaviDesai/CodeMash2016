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
        SwizzlerForNavigationController.swizzlePopToRootViewControllerAnimated()
        Swizzler<GamesController>.swizzleNavigationControllerProperty()
        Swizzler<GamesController>.swizzlePresentViewControllerAnimated()
        Swizzler<GamesController>.swizzleDismissViewControllerAnimated()
        Swizzler<GamesController>.swizzlePrepareForSegue()
    }
    
    class override func tearDown() {
        SwizzlerForNavigationController.swizzlePopToRootViewControllerAnimated()
        Swizzler<GamesController>.swizzleNavigationControllerProperty()
        Swizzler<GamesController>.swizzlePresentViewControllerAnimated()
        Swizzler<GamesController>.swizzleDismissViewControllerAnimated()
        Swizzler<GamesController>.swizzlePrepareForSegue()

        super.tearDown()
    }
    
    override func setUp() {
        super.setUp()
        
        ActionFactory.Action = {(title: String, style: UIAlertActionStyle, handler: ((UIAlertAction)->()))->UIAlertAction in
            return MockAlertAction(title: title, style: style, handler: handler)
        }

        let storyboard = self.getStoryboard("Main")
        self.controller = storyboard?.instantiateViewControllerWithIdentifier("gamesController") as? GamesController
        
        self.controller?.view.hidden = false
        
        mockViewModel = PartialMockGamesViewModel(vm: self.controller!.viewModel! as! GamesViewModel)
        
        self.controller?.viewModel = mockViewModel
        self.called = false
    }
    
    override func tearDown() {
        ActionFactory.restoreDefault()
        self.controller = nil
        self.called = false
        super.tearDown()
    }
    

    func testGameScreenDisplaysInitialized() {
        self.controller!.loadData(self.getLoginUser(), games: self.getFakeGames(), users: self.getFakeUsers())
        
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
        self.controller!.loadData(self.getLoginUser(), games: self.getFakeGames(), users: self.getFakeUsers())
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 1)

        var alertView: UIAlertController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated) -> Bool in
            alertView = viewController as? UIAlertController
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
            var createdGame = game
            createdGame.id = NSUUID()
            return (createdGame, nil)
        }
        
        createButton?.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 2)
    }

    func testComposeNewGameClickCreateFailure() {
        self.controller!.loadData(self.getLoginUser(), games: self.getFakeGames(), users: self.getFakeUsers())
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

    func testComposeNewGameClickCreateFailureUnauthorized() {
        self.controller!.loadData(self.getLoginUser(), games: self.getFakeGames(), users: self.getFakeUsers())
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
            return (nil, self.mockViewModel!.generateError(401, message: "Unauthorized"))
        }
        
        alertView = nil
        createButton?.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 1)
        XCTAssertTrue(alertView?.message == .Some("You will be logged off."))
        
        let mockedNavigationController = UINavigationController()
        mockedNavigationController.popToRootViewControllerAnimatedInterceptCallback = PopToRootViewControllerAnimatedInterceptCallbackWrapper({(animated)->Bool in
            self.called = true
            return false
        })

        self.controller!.navigationControllerInterceptCallback = NavigationControllerInterceptCallbackWrapper({() -> UINavigationController? in
            return mockedNavigationController
        })
        
        self.called = false
        let dismissAction = alertView?.actions[0] as? MockAlertAction
        XCTAssertTrue(dismissAction != nil)
        dismissAction!.call()
        
        XCTAssertTrue(self.waitForResponse { self.called })
    }
    
    func testComposeNewGameClickCancel() {
        self.controller!.loadData(self.getLoginUser(), games: self.getFakeGames(), users: self.getFakeUsers())
        XCTAssertTrue(self.controller!.tableView.numberOfRowsInSection(0) == 1)
        
        var alertView: UIAlertController?
        self.controller!.presentViewControllerAnimatedInterceptCallback = PresentViewControllerAnimatedInterceptCallbackWrapper({(viewController, animated) -> Bool in
            alertView = viewController as? UIAlertController
            self.called = true
            return false
        })
        
        self.controller!.compose()
        XCTAssertTrue(self.waitForResponse { self.called })
        
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
        self.controller!.loadData(self.getLoginUser(), games: self.getFakeGames(), users: self.getFakeUsers())

        var vmcount = self.controller!.viewModel!.tableView(self.controller!.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(vmcount, 1)
        
        var count = self.controller!.tableView.numberOfRowsInSection(0)
        XCTAssertEqual(count, 1)
        
        let gameCell = self.controller!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(gameCell != nil)
        
        self.mockViewModel!.deleteGameAtIndexPathCallback = {(indexPath) -> NSError? in
            if self.mockViewModel!.vm.getGameAtIndexPath(indexPath) != nil {
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

    func testSegueToMessagesForGame() {
        self.controller!.loadData(self.getLoginUser(), games: self.getFakeGames(), users: self.getFakeUsers())
        
        let count = self.controller!.tableView.numberOfRowsInSection(0)
        XCTAssertEqual(count, 1)
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        var messageListController: MessageListController?
        self.controller!.prepareForSegueInterceptCallback = PrepareForSegueInterceptCallbackWrapper({(segue) -> Bool in
            messageListController = segue.destinationViewController as? MessageListController
            return true
        })

        var fakeMessages: [Message]?
        self.mockViewModel!.getMessagesForGameCallback = {(game) -> ([Message]?, NSError?) in
            fakeMessages = self.getFakeMessages(game)
            return (fakeMessages, nil)
        }
        
        self.controller!.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)

        self.called = false
        self.controller!.performSegueWithIdentifier("ShowMessages", sender: self.controller!)
        
        XCTAssertTrue(messageListController != nil)
        XCTAssertTrue(messageListController!.viewModel!.messages! == fakeMessages!)
    }
}