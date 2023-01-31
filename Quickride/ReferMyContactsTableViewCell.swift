//
//  ReferMyContactsTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 22/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol ReferMyContactsTableViewCellDelegate: class{
    func referContactsClicked()
}

class ReferMyContactsTableViewCell: UITableViewCell {

   //MARK:Outlets
    @IBOutlet weak var referMsgLabel: UILabel!
    @IBOutlet weak var referContactButton: UIButton!
    
    weak private var delegate: ReferMyContactsTableViewCellDelegate?
    
    func initializeCell(delegate: ReferMyContactsTableViewCellDelegate){
        self.delegate = delegate
        let attrString = NSMutableAttributedString(string: Strings.refer_contact_msg)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3 
        style.minimumLineHeight = 3
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: Strings.refer_contact_msg.count))
        referMsgLabel.attributedText = attrString
    }
    
    //MARK: Actions
    @IBAction func referMyContactsClicked(_ sender: Any) {
        delegate?.referContactsClicked()
    }
}
