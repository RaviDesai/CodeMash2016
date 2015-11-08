//
//  UIViewController+Extensions.swift
//  Pods
//
//  Created by Ravi Desai on 10/26/15.
//
//

import UIKit
import ObjectiveC

private var performSegueAssociation: UInt8 = 0
private var prepareSegueAssociation: UInt8 = 0
private var prepareForSegueInterceptCallbackAssociation: UInt8 = 0
private var performSegueWithIdentifierInterceptCallbackAssociation: UInt8 = 0
private var presentViewControllerAnimatedInterceptCallbackAssociation: UInt8 = 0
private var presentedViewControllerAssociation: UInt8 = 0
private var navigationControllerAssociation: UInt8 = 0
private var dismissViewControllerAnimatedInterceptCallbackAssociation: UInt8 = 0


public class PrepareForSegueInterceptCallbackWrapper {
    var closure: ((UIStoryboardSegue)->Bool)?
    public init(_ closure: ((UIStoryboardSegue)->Bool)?) {
        self.closure = closure
    }
    
    public func call(segue: UIStoryboardSegue) -> Bool {
        return self.closure?(segue) ?? true
    }
}


public class PerformSegueWithIdentifierInterceptCallbackWrapper {
    var closure: ((String?)->Bool)?
    public init(_ closure: ((String?)->Bool)?) {
        self.closure = closure
    }
    
    public func call(identifier: String?) -> Bool {
        return self.closure?(identifier) ?? true
    }
    
}

public class PresentViewControllerAnimatedInterceptCallbackWrapper {
    var closure: ((UIViewController, Bool)->Bool)?
    public init(_ closure: ((UIViewController, Bool)->Bool)?) {
        self.closure = closure
    }
    
    public func call(viewController: UIViewController, animated: Bool) -> Bool{
        return self.closure?(viewController, animated) ?? true
    }
}

public class DismissViewControllerAnimatedInterceptCallbackWrapper {
    var closure: ((Bool)->Bool)?
    public init(_ closure: ((Bool)->Bool)?) {
        self.closure = closure
    }
    
    public func call(animated: Bool) -> Bool{
        return self.closure?(animated) ?? true
    }
}


public extension UIViewController {
    var prepareForSegueInterceptCallback: PrepareForSegueInterceptCallbackWrapper? {
        get {
            let wrapper: AnyObject? = objc_getAssociatedObject(self, &prepareForSegueInterceptCallbackAssociation)
            return wrapper as? PrepareForSegueInterceptCallbackWrapper
        }
        set {
            objc_setAssociatedObject(self, &prepareForSegueInterceptCallbackAssociation, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    var performSegueWithIdentifierInterceptCallback: PerformSegueWithIdentifierInterceptCallbackWrapper? {
        get {
            let wrapper: AnyObject? = objc_getAssociatedObject(self, &performSegueWithIdentifierInterceptCallbackAssociation)
            return wrapper as? PerformSegueWithIdentifierInterceptCallbackWrapper
        }
        set {
            objc_setAssociatedObject(self, &performSegueWithIdentifierInterceptCallbackAssociation, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var presentViewControllerAnimatedInterceptCallback: PresentViewControllerAnimatedInterceptCallbackWrapper? {
        get {
            let wrapper: AnyObject? = objc_getAssociatedObject(self, &presentViewControllerAnimatedInterceptCallbackAssociation)
            return wrapper as? PresentViewControllerAnimatedInterceptCallbackWrapper
        }
        set {
            objc_setAssociatedObject(self, &presentViewControllerAnimatedInterceptCallbackAssociation, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
    }
    
    var dismissViewControllerAnimatedInterceptCallback: DismissViewControllerAnimatedInterceptCallbackWrapper? {
        get {
            let wrapper: AnyObject? = objc_getAssociatedObject(self, &dismissViewControllerAnimatedInterceptCallbackAssociation)
            return wrapper as? DismissViewControllerAnimatedInterceptCallbackWrapper
        }
        set {
            objc_setAssociatedObject(self, &dismissViewControllerAnimatedInterceptCallbackAssociation, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
    }

    
    func testImpl_performSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> () {
        let callOriginalMethod = self.performSegueWithIdentifierInterceptCallback?.call(identifier) ?? true
        if (callOriginalMethod) {
            testImpl_performSegueWithIdentifier(identifier, sender: sender)
        }
    }
    
    func testImpl_prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let callOriginalMethod = self.prepareForSegueInterceptCallback?.call(segue) ?? true
        if (callOriginalMethod) {
            testImpl_prepareForSegue(segue, sender: sender)
        }
    }
    
    func testImpl_presentViewController(viewController: UIViewController, animated: Bool, completion:(()->())?) {
        let callOriginalMethod = self.presentViewControllerAnimatedInterceptCallback?.call(viewController, animated: animated) ?? true
        if (callOriginalMethod) {
            testImpl_presentViewController(viewController, animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    func testImpl_dismissViewControllerAnimated(animated: Bool, completion:(()->())?) {
        let callOriginalMethod = self.dismissViewControllerAnimatedInterceptCallback?.call(animated) ?? true
        if (callOriginalMethod) {
            testImpl_dismissViewControllerAnimated(animated, completion: completion)
        } else {
            completion?()
        }
    }
}

// Mock global navigation controller - useful for intercepting segues across Storyboards
// (when performSegue isn't used)
public class MockNavigationController: UINavigationController {
    public var pushedViewController: UIViewController?
    public var presentedNavigationController: UINavigationController?
    
    override public func pushViewController(viewController: UIViewController, animated: Bool) {
        self.pushedViewController = viewController
    }
    
    override public func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        self.presentedNavigationController = viewControllerToPresent as? UINavigationController
    }
}

public var GlobalMockNavigationController: MockNavigationController = MockNavigationController()

public extension UIViewController {
    public var mockNavigationController: MockNavigationController? {
        get {
            let navCtl: AnyObject? = objc_getAssociatedObject(self, &navigationControllerAssociation)
            return (navCtl as? MockNavigationController) ?? GlobalMockNavigationController
        }
        set {
            objc_setAssociatedObject(self, &navigationControllerAssociation, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func testImpl_navigationController() -> UINavigationController? {
        return self.mockNavigationController
    }
}


public class Swizzler<T where T: UIViewController> {
    public class func swizzlePrepareForSegue() {
        let vcClass: AnyClass = T.classForCoder()
        let realMethod: Method = class_getInstanceMethod(
            vcClass,
            Selector("prepareForSegue:sender:"))
        
        let testMethod: Method = class_getInstanceMethod(
            vcClass,
            Selector("testImpl_prepareForSegue:sender:"))
        
        method_exchangeImplementations(realMethod, testMethod)
    }

    public class func swizzlePerformSegueWithIdentifier() {
        let vcClass: AnyClass = T.classForCoder()
        let realMethod: Method = class_getInstanceMethod(
            vcClass,
            Selector("performSegueWithIdentifier:sender:"))
        
        let testMethod: Method = class_getInstanceMethod(
            vcClass,
            Selector("testImpl_performSegueWithIdentifier:sender:"))
        
        method_exchangeImplementations(realMethod, testMethod)
    }
    
    
    public class func swizzleNavigationControllerProperty() {
        let vcClass: AnyClass = T.classForCoder()
        
        let realMethod: Method = class_getInstanceMethod(
            vcClass,
            Selector("navigationController"))
        
        let testMethod: Method = class_getInstanceMethod(
            vcClass,
            Selector("testImpl_navigationController"))
        
        method_exchangeImplementations(realMethod, testMethod)
    }
    
    public class func swizzlePresentViewControllerAnimated() {
        let vcClass: AnyClass = T.classForCoder()
        
        let realMethod: Method = class_getInstanceMethod(
            vcClass,
            Selector("presentViewController:animated:completion:"))
        
        let testMethod: Method = class_getInstanceMethod(
            vcClass,
            Selector("testImpl_presentViewController:animated:completion:"))
        
        method_exchangeImplementations(realMethod, testMethod)
    }
    
    public class func swizzleDismissViewControllerAnimated() {
        let vcClass: AnyClass = T.classForCoder()
        
        let realMethod: Method = class_getInstanceMethod(
            vcClass,
            Selector("dismissViewControllerAnimated:completion:"))
        
        let testMethod: Method = class_getInstanceMethod(
            vcClass,
            Selector("testImpl_dismissViewControllerAnimated:completion:"))
        
        method_exchangeImplementations(realMethod, testMethod)
    }
}
