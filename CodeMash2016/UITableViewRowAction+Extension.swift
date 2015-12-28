//
//  UITableViewRowAction+Extension.swift
//  DirectSwift
//
//  Created by Ravi Desai on 7/29/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import UIKit
import ObjectiveC

var ActionTriggerHandle: UInt8 = 0

private class ActionTrigger {
    private var handler: (UITableViewRowAction!, NSIndexPath!) -> ()
    private var action: UITableViewRowAction
    
    private init(action: UITableViewRowAction, handler: (UITableViewRowAction!, NSIndexPath!) -> Void) {
        self.handler = handler
        self.action = action
    }
    
    private func trigger(indexPath: NSIndexPath) {
        handler(action, indexPath)
    }
}

public extension  UITableViewRowAction  {
    public convenience init(title: String!, style: UITableViewRowActionStyle, exposedHandler: (UITableViewRowAction!, NSIndexPath!) -> Void) {
        self.init(style: style, title: title, handler: exposedHandler)
        let actionTrigger = ActionTrigger(action: self, handler: exposedHandler)
        objc_setAssociatedObject(self, &ActionTriggerHandle, actionTrigger, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public func trigger(indexPath:NSIndexPath) {
        if let storedActionTrigger = objc_getAssociatedObject(self, &ActionTriggerHandle) as? ActionTrigger {
            storedActionTrigger.trigger(indexPath)
        }
    }
}