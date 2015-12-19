//
//  MessageCellViewModel.swift
//  CodeMash2016
//
//  Created by Ravi Desai on 12/16/15.
//  Copyright © 2015 RSD. All rights reserved.
//

import UIKit

extension NSDate {
    func toLocalString() -> String {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone.localTimeZone()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(self);
    }
}

class MessageCell: UITableViewCell {
    var message: Message?
    var users: [User]?

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func setMessage(message: Message?, users: [User]?) {
        self.message = message
        self.users = users
        self.initializeComponentsFromViewModel()
    }
    
    func initializeComponentsFromViewModel() {
        if let fromUser = self.users?.filter({ $0.id == self.message?.from }).first {
            fromLabel.text = (message != nil) ? "\(fromUser.name)" : nil
        }
        subjectLabel.text = message?.subject
        messageLabel.text = message?.message
        dateLabel.text = message?.date.toLocalString()
    }
}