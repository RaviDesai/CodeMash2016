//
//  MockAlertAction.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

class MockAlertAction : UIAlertAction {
    
    typealias Handler = ((UIAlertAction) -> Void)
    private var handler: Handler?
    private var mockTitle: String?
    private var mockStyle: UIAlertActionStyle
    
    override var title: String? { get { return self.mockTitle } }
    override var style: UIAlertActionStyle { get { return self.mockStyle } }
    
    init(title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?) {
        mockTitle = title
        mockStyle = style
        self.handler = handler
        super.init()
    }
    
    override init() {
        mockStyle = .Default
        
        super.init()
    }
    
    func call() {
        self.handler?(self)
    }
}
