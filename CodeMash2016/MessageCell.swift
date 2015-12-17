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

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func setMessage(message: Message?) {
        self.message = message
    }
    
    func initializeComponentsFromViewModel() {
        subjectLabel.text = message?.subject
        messageLabel.text = message?.message
        fromLabel.text = "\(message?.from)"
        dateLabel.text = message?.date.toLocalString()
    }
}