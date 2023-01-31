//
//  MyRidesRecurringTableViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 29/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol MyRidesRecurringTableViewCellDelegate: class {
    func reloadRegularRideCell()
    func showRecurringRideScreen(for ride: Ride)
    func createRecurringRide(isRecurringRideRequiredFrom: String?)
}

class MyRidesRecurringTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak fileprivate var recurringRideCollectionView: UICollectionView!
    @IBOutlet weak fileprivate var showButton: UIButton!
    @IBOutlet weak fileprivate var recurringRideStatusView: UIView!
    @IBOutlet weak fileprivate var recurringRideStatusLabel: UILabel!
    @IBOutlet weak var rideCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var seperatorView: UIView!
    //MARK: Properties
    lazy var myRideRecurringViewModel: MyRideRecurringViewModel = {
        return MyRideRecurringViewModel()
    }()
    weak var delegate: MyRidesRecurringTableViewCellDelegate?
    let activeColorOfRegularRide = UIColor(netHex: 0x00B557)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadCollectionViewNib()
        initialiseUI()
        myRideRecurringViewModel.isOfficeToHomeAdress = false
        myRideRecurringViewModel.isHomeToOfficeAdress = false
    }
    
    //MARK: Methods
    private func loadCollectionViewNib() {
        recurringRideCollectionView.register(UINib(nibName: "RecurringRideCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecurringRideCollectionViewCell")
        recurringRideCollectionView.register(UINib(nibName: "AddNewRecurringRideCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AddNewRecurringRideCollectionViewCell")
        recurringRideCollectionView.dataSource = self
        recurringRideCollectionView.delegate = self
    }

    private func initialiseUI() {
        ViewCustomizationUtils.addCornerRadiusToView(view: recurringRideStatusView, cornerRadius: recurringRideStatusView.frame.height / 2)
        ViewCustomizationUtils.addBorderToView(view: recurringRideStatusView, borderWidth: 1.0, color: .white)
        checkShowHideButtonStatus()
    }
    
    func checkShowHideButtonStatus() {
        if SharedPreferenceHelper.getRegularRideDisplayStatus() == "true" {
            rideCollectionViewHeightConstraint.constant = 102 //collection view cell size
            showButton.setTitle(Strings.recurring_ride_hide_status, for: .normal)
        } else if SharedPreferenceHelper.getRegularRideDisplayStatus() == "false"{
            rideCollectionViewHeightConstraint.constant = 0 //collection view cell size
            showButton.setTitle(Strings.recurring_ride_show_status, for: .normal)
            recurringRideCollectionView.reloadData()
        } else {
            rideCollectionViewHeightConstraint.constant = 102 //collection view cell size
            showButton.setTitle(Strings.recurring_ride_hide_status, for: .normal)
        }
    }
    
    func configureRideCollectionView(regularRide: [RegularRide]) {
        myRideRecurringViewModel.regularRide = regularRide
        checkOverAllRecurringStatus(for: regularRide)
        myRideRecurringViewModel.isHomeToOfficeAdress = false
        myRideRecurringViewModel.isOfficeToHomeAdress = false
        recurringRideCollectionView.reloadData()
        checkShowHideButtonStatus()
    }
    
    func checkOverAllRecurringStatus(for regularRides: [RegularRide]) {
        //when button title is show- then only display overall regular ride status and 
        if regularRides.count > 0, SharedPreferenceHelper.getRegularRideDisplayStatus() == "false" {
            for regularRide in regularRides {
                if myRideRecurringViewModel.getRideStatus(for: regularRide) {
                    recurringRideStatusLabel.textColor = activeColorOfRegularRide
                    recurringRideStatusLabel.text = "ON"
                    recurringRideStatusView.backgroundColor = activeColorOfRegularRide
                    return
                } else {
                    recurringRideStatusLabel.textColor = .red
                    recurringRideStatusLabel.text = "OFF"
                    recurringRideStatusView.backgroundColor = .red
                }
            }
        } else {
            recurringRideStatusLabel.textColor = .clear
            recurringRideStatusLabel.text = ""
            recurringRideStatusView.backgroundColor = .clear
        }
    }
    
    func configureRegularRideShowStatus() {
        if  SharedPreferenceHelper.getRegularRideDisplayStatus() == "true" {
            rideCollectionViewHeightConstraint.constant = 102 //collection view cell size
            showButton.setTitle(Strings.recurring_ride_hide_status, for: .normal)
        } else {
            rideCollectionViewHeightConstraint.constant = 0
            showButton.setTitle(Strings.recurring_ride_show_status, for: .normal)
        }
        delegate?.reloadRegularRideCell()
    }
    
    //MARK: Action
    @IBAction func showButtonTapped(_ sender: UIButton) {
        //store status in cache
        if SharedPreferenceHelper.getRegularRideDisplayStatus() == "true" {
           SharedPreferenceHelper.saveRegularRideActiveState(status: "false")
        } else if SharedPreferenceHelper.getRegularRideDisplayStatus() == "false" {
          SharedPreferenceHelper.saveRegularRideActiveState(status: "true")
        } else {
            SharedPreferenceHelper.saveRegularRideActiveState(status: "false")
        }
        configureRegularRideShowStatus()
    }
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        MessageDisplay.displayInfoViewAlert(title: Strings.recurring_ride_info_title, titleColor: nil, message: Strings.recurring_ride_info, infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps) {
        }
    }
}
//MARK: UICollectionViewDataSource
extension MyRidesRecurringTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let recurringRideData = myRideRecurringViewModel.getRegularRideDetails(), recurringRideData.count > 0 {
            if recurringRideData.count == 1 {
                return recurringRideData.count + myRideRecurringViewModel.getHomeAndOfficeRegularRideDetails()
            }
            return recurringRideData.count + myRideRecurringViewModel.getHomeAndOfficeRegularRideDetails() + 1
        }
        return myRideRecurringViewModel.getHomeAndOfficeRegularRideDetails() //If regular rides are not avalibale then show two default cell to create recurring ride
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecurringRideCollectionViewCell", for: indexPath) as! RecurringRideCollectionViewCell
        let addNewRecurringRideCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddNewRecurringRideCollectionViewCell", for: indexPath) as! AddNewRecurringRideCollectionViewCell
        if let regularRides = myRideRecurringViewModel.getRegularRideDetails(), regularRides.count > 0 {
            if regularRides.count >= 2 {
                if indexPath.row == regularRides.count {
                    cell.configureAddRecurringRideCell()
                    return cell
                }
            }
            if regularRides[indexPath.row].startAddress == "" {
                let status = myRideRecurringViewModel.checkHomeAndOfficeAddressForRegularRide()
                if !status.0 {
                    regularRides[indexPath.row].isRecurringRideRequiredFrom = RegularRideCreationViewController.HOME_TO_OFFICE
                    if !myRideRecurringViewModel.checkHomeAndOfficeAddressForParticularRide(regularRide: regularRides[indexPath.row]), myRideRecurringViewModel.isHomeToOfficeAdress == false {
                        myRideRecurringViewModel.isHomeToOfficeAdress = true
                        addNewRecurringRideCell.configureViewBasedOnAddress(isShowOffice: false)
                        return addNewRecurringRideCell
                    }
                }
                if !status.1 {
                    regularRides[indexPath.row].isRecurringRideRequiredFrom = RegularRideCreationViewController.OFFICE_TO_HOME
                    if !myRideRecurringViewModel.checkOfficeAndHomeAddressForParticularRide(regularRide: regularRides[indexPath.row]), myRideRecurringViewModel.isOfficeToHomeAdress == false {
                        myRideRecurringViewModel.isOfficeToHomeAdress = true
                        addNewRecurringRideCell.configureViewBasedOnAddress(isShowOffice: true)
                        return addNewRecurringRideCell
                    }
                }
            } else {
                regularRides[indexPath.row].isRecurringRideRequiredFrom = nil
                cell.configureViewWith(regularRides[indexPath.row])
                return cell
            }
        }
        return addNewRecurringRideCell
    }
}
//MARK: UICollectionViewDelegate
extension MyRidesRecurringTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let regularRides = myRideRecurringViewModel.getRegularRideDetails(), regularRides.count > 0 {
            
            if regularRides.count >= 2 {
                if indexPath.row == regularRides.count {
                    delegate?.createRecurringRide(isRecurringRideRequiredFrom: nil)
                } else {
                    if regularRides[indexPath.row].startAddress == "" {
                      delegate?.createRecurringRide(isRecurringRideRequiredFrom: regularRides[indexPath.row].isRecurringRideRequiredFrom)
                    } else {
                        delegate?.showRecurringRideScreen(for: regularRides[indexPath.row])
                    }
                }
            } else {
                if regularRides[indexPath.row].startAddress == "" {
                    delegate?.createRecurringRide(isRecurringRideRequiredFrom: regularRides[indexPath.row].isRecurringRideRequiredFrom)
                } else {
                    delegate?.showRecurringRideScreen(for: regularRides[indexPath.row])
                }
            }
        } else {
            delegate?.createRecurringRide(isRecurringRideRequiredFrom: nil)
        }
    }
    
}
//MARK: UICollectionViewDelegateFlowLayout
extension MyRidesRecurringTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 116)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
}
