//
//  AsynchronousTestCase.swift
//
//  Created by Ravi Desai on 4/30/15.
//  Copyright (c) 2015 RSD. All rights reserved.
//

import UIKit
import XCTest

public class AsynchronousTestCase : XCTestCase {
    private var runLoop: NSRunLoop?
    private var animationDone = false
    
    public override func setUp() {
        super.setUp()
        
        self.runLoop = NSRunLoop.currentRunLoop()
        self.animationDone = false
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.animationDone = true
        }
    }
    
    public override func tearDown() {
        CATransaction.commit()
        self.waitForAnimationComplete()
        
        self.runLoop = nil
        self.animationDone = false
        
        super.tearDown()
    }
    
    public func waitForResponse(testBlock: ()-> Bool) -> Bool {
        var count = 0
        var success = testBlock()
        while ((!success) && count < 50) {
            self.runLoop!.runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.1))
            count++
            success = testBlock()
        }
        
        if (self.animationDone) {
            self.animationDone = false
            CATransaction.setCompletionBlock({ () -> Void in
                self.animationDone = true
            })
        }
        
        return success;
    }
    
    private func waitForAnimationComplete() -> Bool {
        var count = 0
        while ((!self.animationDone) && count < 50) {
            self.runLoop!.runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.1))
            count++
        }
        
        return self.animationDone;
    }
}