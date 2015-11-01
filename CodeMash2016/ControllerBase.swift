//
//  ControllerBase.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

enum DeletedOrSaved {
    case Deleted
    case Saved
}

extension UIViewController {
    public func popBackToCallerWithMissingDataMessage() {
        let userInfo = [NSLocalizedDescriptionKey: "Cannot show screen", NSLocalizedFailureReasonErrorKey: "Required data could not be retrieved"]
        
        let error = NSError(domain: "com.careevolution.direct", code: 48103001, userInfo: userInfo)
        
        self.notifyUserOfError(error, withCallbackOnDismissal: { () -> () in
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
    
    public func notifyUserOfError(error: NSError, withCallbackOnDismissal callback: ()->()) {
        let alert = UIAlertController(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: UIAlertControllerStyle.Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            callback()
        })
        
        alert.addAction(dismissAction);
        self.presentViewController(alert, animated: true, completion: { () -> Void in })
    }
}

extension UIViewController {
    func navigationShouldPopOnBackButton() -> Bool {
        return true
    }
}

extension UINavigationController {
    func navigationBar(navigationBar: UINavigationBar, shouldPopItem item: UINavigationItem) -> Bool {
        if (self.viewControllers.count < navigationBar.items?.count ?? 0) {
            return true;
        }

        var shouldPop = true;
        if let vc = self.topViewController {
            shouldPop = vc.navigationShouldPopOnBackButton()
        }
        
        if (shouldPop) {
            dispatch_async(dispatch_get_main_queue(), {
                self.popViewControllerAnimated(true)
            })
        } else {
            // Workaround for iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
            for view in navigationBar.subviews {
                if view.alpha < 1.0 {
                    [UIView .animateWithDuration(0.25, animations: { () -> Void in
                        view.alpha = 1.0
                    })]
                }
            }
        }
        
        return false
    }
}
