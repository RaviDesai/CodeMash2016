//
//  MessageViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 11/1/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import Foundation

class MessageViewModel: ViewModelBase {
    var toTokens: [EmailAddress] = []
    var ccTokens: [EmailAddress] = []
    var contacts: [EmailAddress] = []
    var isLoaded: Bool = false
    var messageHtml: String = "Hello"

    
    func setContacts(contacts: [EmailAddress]?) {
        self.contacts = contacts ?? []
        self.isLoaded = true
    }
    
    func addToToken(address: EmailAddress) {
        let found = toTokens.filter { $0 == address }
        if (found.count == 0) {
            self.toTokens.append(address)
        }
    }

    func addCCToken(address: EmailAddress) {
        let found = ccTokens.filter { $0 == address }
        if (found.count == 0) {
            self.ccTokens.append(address)
        }
    }

    func removeToToken(address: EmailAddress) {
        self.toTokens = self.toTokens.filter { $0 != address }
    }

    func removeCCToken(address: EmailAddress) {
        self.ccTokens = self.ccTokens.filter { $0 != address }
    }

}