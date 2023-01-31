//
//  FeedBackCommentsCollectionViewCell.swift
//  Quickride
//
//  Created by iDisha on 29/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class FeedBackCommentsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelComments: UILabel!
    
    @IBOutlet weak var backGroundView: UIView!
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                self.backGroundView.backgroundColor = Colors.darkGrey
                self.labelComments.textColor = UIColor.white
            }
            else
            {
                self.backGroundView.backgroundColor = UIColor(netHex: 0xF7F7F7)
                self.labelComments.textColor = UIColor.black
            }
        }
    }
}
