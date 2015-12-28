//
//  PartialMockViewModelBase.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation
import RSDRESTServices
@testable import CodeMash2016


class PartialMockViewModelBase: NSObject {
    func generateError(statusCode: Int, message: String) -> NSError? {
        let response = NetworkResponse.HTTPStatusCodeFailure(statusCode, message)
        return response.getError()
    }
    
}