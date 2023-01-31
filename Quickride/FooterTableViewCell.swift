//
//  FooterTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 27/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol FooterTableViewCellDelegate{
    func userTappedOnFooter(section: Int)
}
class FooterTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var footerButton: UIButton!
    @IBOutlet weak var viewAllmatchesView: UIView!
    private var delegate: FooterTableViewCellDelegate?
    
    func initailizeFooter(footerTitle: String,delegate: FooterTableViewCellDelegate){
        footerLabel.text = footerTitle
        self.delegate = delegate
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: viewAllmatchesView, cornerRadius: 15, corner1: .bottomLeft , corner2: .bottomRight)
    }
    
    @IBAction func footerTapped(_ sender: UIButton){
        delegate?.userTappedOnFooter(section: sender.tag)
    }
}
