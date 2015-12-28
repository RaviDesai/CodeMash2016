//
//  GamesController.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/16/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

protocol ComposableControllerProtocol {
    func compose()
}

class GamesController: UITableViewController, UITextFieldDelegate, ComposableControllerProtocol, NamedTabProtocol {
    var viewModel: GamesViewModelProtocol?
    var gameTitle: UITextField?
    var tabName: String { return "Games" }

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
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        self.tabBarController?.title = "Games"
//    }

    func setCurrentUserAndGames(owner: User?, games: [Game]?, users: [User]?) {
        guard let mygames = games, myowner = owner, myusers = users else {
            self.notifyUserOfError(self.generateMissingDataMessage(), withCallbackOnDismissal: { () -> () in })
            return
        }
        ensureViewModelIsCreated()
        self.viewModel?.setCurrentUserAndGames(myowner, games: mygames, users: myusers)
        instantiateFromViewModel()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowMessages") {
            if let controller = segue.destinationViewController as? MessageListController,
                let indexPath = self.tableView.indexPathForSelectedRow {
                self.viewModel?.getMessagesForGame(indexPath, completionHandler: { (messages, error) -> () in
                    controller.setMessages(self.viewModel?.currentUser, game: self.viewModel?.games?[indexPath.row], users: self.viewModel?.users, messages: messages, error: error)
                })
            }
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(title: "Delete", style: UITableViewRowActionStyle.Default) { (action, indexPath) -> Void in
            self.viewModel?.deleteGameAtIndexPath(indexPath, completionHandler: { (error) -> () in
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            })
        }
        if (self.viewModel?.canDeleteGameAtIndexPath(indexPath) == .Some(true)) {
            return [deleteAction]
        }
        return []
    }

    
    func compose() {
        let gameLabel = UILabel(frame: CGRectMake(20, 40, 100, 25))
        gameLabel.text = "Game: "
        self.gameTitle = UITextField(frame: CGRectMake(80, 40, 240, 25))
        self.gameTitle?.borderStyle = UITextBorderStyle.Line
        self.gameTitle?.delegate = self
        
        let alert = UIAlertController(title: "Create Game", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let toolFrame = CGRectMake(0, 0, 270, 210);
        alert.view.frame = toolFrame
        let toolView: UIView = UIView(frame: toolFrame)
        
        let buttonOKFrame: CGRect = CGRectMake(190, 180, 80, 30)
        let buttonOK: UIButton = UIButton(frame: buttonOKFrame)
        buttonOK.setTitle("OK", forState: UIControlState.Normal)
        buttonOK.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)

        
        let buttonCancelFrame: CGRect = CGRectMake(80, 180, 80, 30)
        let buttonCancel: UIButton = UIButton(frame: buttonCancelFrame)
        buttonCancel.setTitle("Cancel", forState: UIControlState.Normal)
        buttonCancel.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        
        toolView.addSubview(buttonOK)
        toolView.addSubview(buttonCancel)
        toolView.addSubview(gameLabel)
        toolView.addSubview(self.gameTitle!)
        
        buttonCancel.addTarget(self, action: "cancelSelection:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonOK.addTarget(self, action: "createGame:", forControlEvents: UIControlEvents.TouchUpInside)
        
        alert.view.addSubview(toolView)
        
        let height = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: toolView, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0)
        let width = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: toolView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0)
        
        
        alert.view.addConstraints([height, width])
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

    func cancelSelection(sender: UIButton) {
        self.gameTitle = nil
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func createGame(sender: UIButton) {
        if let owner = self.viewModel?.currentUser?.id, title = gameTitle?.text where title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
            let game = Game(id: nil, title: title, owner: owner, users: self.viewModel?.users?.map({ $0.id }).filter({ $0 != nil }).map({ $0! }).filter({ $0 != owner}))
            self.viewModel?.createGame(game, completionHandler: {(game, error)->() in
                if let returnedError = error {
                    self.notifyUserOfError(returnedError, withCallbackOnDismissal: { () -> () in
                        self.gameTitle = nil
                    })
                } else {
                    self.tableView.reloadData()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.gameTitle = nil
                }
            })
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
            self.gameTitle = nil
        }
    }
}
