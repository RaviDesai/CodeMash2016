//
//  UIViewExtensions.swift
//  Pods
//
//  Created by Ravi Desai on 12/28/15.
//
//

import UIKit

public extension UIView {
    public func embeddedView<T: UIView>() -> T? {
        return embeddedView(nil)
    }

    public func embeddedView<T: UIView>(tag: Int) -> T? {
        return embeddedView { $0.tag == tag }
    }
    
    public func embeddedView<T: UIView>(comparer: ((T)->Bool)?) -> T? {
        var result: T?
        for subview in self.subviews {
            result = subview as? T
            if (result == nil) {
                result = subview.embeddedView(comparer)
            } else {
                guard let compareFn = comparer else {
                    break
                }
                if compareFn(result!) {
                    break
                }
                result = nil
            }
        }
        return result
    }

}
