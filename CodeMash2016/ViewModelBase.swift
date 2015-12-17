//
//  ViewModelBase.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/23/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation

internal class ViewModelBase : NSObject {
    
    internal func fireNoResultOnMainThread(handler: ()->()) -> (()->()) {
        return {
            dispatch_async(dispatch_get_main_queue(), handler)
        }
    }
    
    internal func fireOnMainThread(handler: (NSError?)->()) -> ((NSError?) -> ()) {
        return { (error) in
            dispatch_async(dispatch_get_main_queue(), {
                handler(error)
            })
        }
    }
    
    internal func fireOnMainThread<T>(handler: (value: T?, error: NSError?)->()) -> ((T?, NSError?) -> ()) {
        return { (value, error) in
            dispatch_async(dispatch_get_main_queue(), {
                handler(value: value, error: error)
            })
        }
    }
    
    internal func fireOnMainThread<T>(handler: (T)->()) -> ((T) -> ()) {
        return { (error) in
            dispatch_async(dispatch_get_main_queue(), {
                handler(error)
            })
        }
    }
    
    internal func fireOnMainThread<T, U>(handler: (first: T?, second: U?, error: NSError?)->()) -> ((T?, U?, NSError?)->()) {
        return { (first, second, error) in
            dispatch_async(dispatch_get_main_queue(), {
                handler(first: first, second: second, error: error)
            })
        }
    }

    internal func fireOnNoResultMainThreadAfterDelay(delayInSeconds: Double, handler: ()->()) -> (() -> ()) {
        return { (error) in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                handler(error)
            })
        }
    }

    
    internal func fireOnMainThreadAfterDelay(delayInSeconds: Double, handler: (NSError?)->()) -> ((NSError?) -> ()) {
        return { (error) in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                handler(error)
            })
        }
    }
    
    internal func fireOnMainThreadAferDelay<T>(delayInSeconds: Double, handler: (value: T?, error: NSError?)->()) -> ((T?, NSError?) -> ()) {
        return { (value, error) in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                handler(value: value, error: error)
            })
        }
    }
    
    internal func fireOnMainThreadAfterDelay<T>(delayInSeconds: Double, handler: (T)->()) -> ((T) -> ()) {
        return { (error) in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                handler(error)
            })
        }
    }
    
    internal func fireOnMainThreadAfterDelay<T, U>(delayInSeconds: Double, handler: (first: T?, second: U?, error: NSError?)->()) -> ((T?, U?, NSError?)->()) {
        return { (first, second, error) in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                handler(first: first, second: second, error: error)
            })
        }
    }
    
    
    internal func fireOnMainThread<T, U>(performBlock: ()->())(handler: (first: T?, second: U?, error: NSError?)->()) -> ((T?, U?, NSError?)->()) {
        return { (first, second, error) in
            dispatch_async(dispatch_get_main_queue(), {
                performBlock()
                handler(first: first, second: second, error: error)
            })
        }
    }
    
    internal func fireOnMainThread(performBlock: ()->())(handler: (NSError?)->()) -> ((NSError?)->()) {
        return { (error) in
            dispatch_async(dispatch_get_main_queue(), {
                performBlock()
                handler(error)
            })
        }
    }
    
    internal func fireOnMainThread<T>(performBlock: ()->())(handler: (value: T?, error: NSError?)->()) -> ((T?, NSError?) -> ()) {
        return { (value, error) in
            dispatch_async(dispatch_get_main_queue(), {
                performBlock()
                handler(value: value, error: error)
            })
        }
    }
    
    internal func fireOnMainThread<T>(performBlock: ()->())(handler: (value: T)->()) -> ((T) -> ()) {
        return { (value) in
            dispatch_async(dispatch_get_main_queue(), {
                performBlock()
                handler(value: value)
            })
        }
    }
}