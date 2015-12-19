//
//  UserCellViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation

class UserCellViewModel {
    private var user: User?
    init(user: User?) {
        self.user = user
    }
    
    var contactName: String? {
        return self.user?.name
    }
    
    var contactAddress: String? {
        return self.user?.emailAddress?.description
    }
    
    var uuidString: String? {
        return self.user?.id?.compressedUUIDString
    }
}