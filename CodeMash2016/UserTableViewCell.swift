//
//  UserTableViewCell.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 10/28/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    
    var viewModel: UserCellViewModel?
    
    func setUser(user: User?) {
        viewModel = UserCellViewModel(user: user)
        initializeComponentsFromViewModel()
    }
    
    func initializeComponentsFromViewModel() {
        self.nameLabel.text = self.viewModel?.contactName
        self.emailAddressLabel.text = self.viewModel?.contactAddress
        self.uuidLabel.text = self.viewModel?.uuidString
    }
}