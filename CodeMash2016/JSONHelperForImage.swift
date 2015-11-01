//
//  ModelHelperForImage.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/31/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation
import UIKit
import RSDRESTServices
import RSDSerialization

func asImage(object: JSON) -> UIImage? {
    if let base64String = object as? String {
        if let data = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions()) {
            return UIImage(data: data)
        }
    }
    return nil
}

func toBase64FromImage(image: UIImage?) -> String? {
    if let myImage = image {
        if let rep = UIImageJPEGRepresentation(myImage, 1.0) {
            return rep.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        }
    }
    return nil
}
