//
//  AddHomeOrOfcTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 14/01/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

protocol AddHomeOrOfcTableViewCellDelegate: class {
    func addFavouriteLocation(favouriteLocation : UserFavouriteLocation?,locationtype: String)
    func updateFavouriteLocation(favouriteLocation : UserFavouriteLocation, locationType :   String,locationName : String?)
}

class AddHomeOrOfcTableViewCell: UITableViewCell {
    //MARK: OUTLETS
    //MARK: Add location
    @IBOutlet weak var addHomeLocationButton: CustomUIButton!
    @IBOutlet weak var addOfficeLocationButton: CustomUIButton!
    //MARK: Added location
    @IBOutlet weak var addedLocationView: UIView!
    @IBOutlet weak var homeOrOfficeLabel: UILabel!
    @IBOutlet weak var homeOrOfficeImageView: UIImageView!
    @IBOutlet weak var addedLocationLabel: UILabel!
    @IBOutlet weak var addedLocationViewHeighConstraint: NSLayoutConstraint!
    
    weak var delegate: AddHomeOrOfcTableViewCellDelegate?
    
    func updateUI() {
        addHomeLocationButton.addShadow()
        addOfficeLocationButton.addShadow()
        if UserDataCache.getInstance()?.getHomeLocation() == nil && UserDataCache.getInstance()?.getOfficeLocation() == nil {
            addHomeLocationButton.isHidden = false
            addOfficeLocationButton.isHidden = false
            addedLocationView.isHidden = true
            addedLocationViewHeighConstraint.constant = 0
        } else if UserDataCache.getInstance()?.getHomeLocation() != nil && UserDataCache.getInstance()?.getOfficeLocation() == nil {
            addHomeLocationButton.isHidden = true
            addOfficeLocationButton.isHidden = false
            handleAddedLocationView()
        } else if UserDataCache.getInstance()?.getHomeLocation() == nil && UserDataCache.getInstance()?.getOfficeLocation() != nil {
            addHomeLocationButton.isHidden = false
            addOfficeLocationButton.isHidden = true
            handleAddedLocationView()
        }
    }
    
    private func handleAddedLocationView() {
        addedLocationView.isHidden = false
        addedLocationViewHeighConstraint.constant = 80
        if let homeLocation = UserDataCache.getInstance()?.getHomeLocation() {
            homeOrOfficeLabel.text = "Home"
            homeOrOfficeImageView.image = UIImage(named: "home_location_new")
            addedLocationLabel.text = homeLocation.address
        } else if let officeLocation = UserDataCache.getInstance()?.getOfficeLocation() {
            homeOrOfficeLabel.text = "Office"
            homeOrOfficeImageView.image = UIImage(named: "office_location_new")
            addedLocationLabel.text = officeLocation.address
        }
    }
    
    @IBAction func addHomeButtonTapped(_ sender: UIButton) {
        delegate?.addFavouriteLocation(favouriteLocation: nil, locationtype: UserFavouriteLocation.HOME_FAVOURITE)
    }
    
    @IBAction func addOfficeButtonTapped(_ sender: UIButton) {
        delegate?.addFavouriteLocation(favouriteLocation: nil, locationtype: UserFavouriteLocation.OFFICE_FAVOURITE)
    }
    @IBAction func updateFavLocation(_ sender: Any) {
        if let homeLocation = UserDataCache.getInstance()?.getHomeLocation() {
            delegate?.updateFavouriteLocation(favouriteLocation: homeLocation, locationType: ChangeLocationViewController.HOME, locationName: addedLocationLabel.text)
            
        } else if let officeLocation = UserDataCache.getInstance()?.getOfficeLocation() {
            delegate?.updateFavouriteLocation(favouriteLocation: officeLocation, locationType: ChangeLocationViewController.OFFICE, locationName: addedLocationLabel.text)
        }
    }
}
