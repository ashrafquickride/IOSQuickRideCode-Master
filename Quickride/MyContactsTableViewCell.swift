//
//  MyContactsTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 12/05/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MyContactsTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    
    func initializeCell(contact: ContactRegistrationStatus){
        contactNameLabel.text = contact.contactName?.capitalized
        contactNumberLabel.text = contact.contactNo ?? ""
        if contact.isContactSelected{
            contactImage.image = UIImage(named: "check")
        }else{
           contactImage.image = UIImage(named: "uncheck")
        }
    }
}
