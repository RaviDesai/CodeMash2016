//
//  ActionFactory.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

class ActionFactory {
    private static var DefaultAction = {(title: String, style: UIAlertActionStyle, handler: ((UIAlertAction)->()))->UIAlertAction in
        return UIAlertAction(title: title, style: style, handler: handler)
    }

    internal static var Action = ActionFactory.DefaultAction
    
    internal static func restoreDefault() {
        ActionFactory.Action = ActionFactory.DefaultAction
    }
}

