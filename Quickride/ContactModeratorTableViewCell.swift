//
//  ContactModeratorTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 03/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ContactModeratorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!

    func initaialiseView(rideModerator: RideParticipant) {
        ImageCache.getInstance().setImageToView(imageView: profileImageView, imageUrl: rideModerator.imageURI, gender: rideModerator.gender ?? "U",imageSize: ImageCache.DIMENTION_TINY)
        nameLabel.text = rideModerator.name
    }
}
