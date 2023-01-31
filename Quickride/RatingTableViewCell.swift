//
//  RatingTableViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 17/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol RatingTableViewCellDelegate: class {
    func ratingButtonTapped(rating: Int)
}

class RatingTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak fileprivate var firstRatingButton: UIButton!
    @IBOutlet weak fileprivate var secondRatingButton: UIButton!
    @IBOutlet weak fileprivate var thirdRatingButton: UIButton!
    @IBOutlet weak fileprivate var fourthRatingButton: UIButton!
    @IBOutlet weak fileprivate var fifthRatingButton: UIButton!
    
    //MARK: Variables
    private var ratingButtonData = [UIButton]()
    weak var delegate: RatingTableViewCellDelegate?
    
    func setupRatingView(selectedRating: Int){
        ratingButtonData = [firstRatingButton, secondRatingButton, thirdRatingButton, fourthRatingButton, fifthRatingButton]
        setRating(selectedRating: selectedRating)
    }
    
    func setRating(selectedRating: Int) {
        for (index,data) in ratingButtonData.enumerated() {
            if index <= selectedRating {
                data.setImage(UIImage(named: "rating_Star"), for: .normal)
            }else{
                data.setImage(UIImage(named: "ic_ratingbar_star_dark"), for: .normal)
            }
        }
    }
    
    @IBAction func ratingButtonTapped(_ sender: UIButton) {
        setRating(selectedRating: sender.tag)
        delegate?.ratingButtonTapped(rating: sender.tag)
    }
}

