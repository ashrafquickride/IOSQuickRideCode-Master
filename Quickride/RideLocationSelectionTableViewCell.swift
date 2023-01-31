//
//  RideLocationSelectionTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 01/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol RideLocationSelectionTableViewCellDelegate {
    func fromLocationTapped()
    func toLocationTapped()
    func rideTypeChanged(primary : String)
    func selectedFavLocation(location: Location)
}
extension RideLocationSelectionTableViewCellDelegate{
    func selectedFavLocation(location: Location){}
}

class RideLocationSelectionTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var rideTypeCollectionView: UICollectionView!
    @IBOutlet weak var startLocationButton: UIButton!
    @IBOutlet weak var destinationLocationButton: UIButton!
    @IBOutlet weak var collectionViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var verifyProfileView: UIView!
    @IBOutlet weak var favouriteLocationView: UIView!
    @IBOutlet weak var favouriteLocationCollectionView: UICollectionView!
    
    //MARK: Properties
    private var pickup : Location?
    private var drop : Location?
    private var userSelectionDelegate: RideLocationSelectionTableViewCellDelegate?
    private var selectionTypes = [String]()
    private var selectedType = ""
    private var selectedIndex = -1
    private var favouriteLocations = [UserFavouriteLocation]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCell()
    }
    
    //MARK: Initializer
    func initializeData(pickup: Location?,drop : Location?, userSelectionDelegate: RideLocationSelectionTableViewCellDelegate?,selectedRideType: String) {
        self.pickup = pickup
        self.drop = drop
        self.userSelectionDelegate = userSelectionDelegate
        self.selectedType = selectedRideType
        if let favLocs = UserDataCache.getInstance()?.getFavoriteLocations(),!favLocs.isEmpty{
            favouriteLocations = favLocs
            favouriteLocationView.isHidden = false
            favouriteLocationCollectionView.reloadData()
        }else{
            favouriteLocationView.isHidden = true
        }
        setStartLocation()
        setEndLocation()
        getRideTypes()
        rideTypeCollectionView.reloadData()
        if let profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData(),profileVerificationData.emailVerifiedAtleastOnce{
            verifyProfileView.isHidden = true
        }else{
            verifyProfileView.isHidden = false
        }
    }
    
    private func getRideTypes(){
        selectionTypes = [Ride.PASSENGER_RIDE,Ride.RIDER_RIDE]
        collectionViewTrailingConstraint.constant = 20
        collectionViewLeadingConstraint.constant = 20
        if let index = selectionTypes.index(of: selectedType){
            selectedIndex = index
        }
    }
    
    private func registerCell() {
        rideTypeCollectionView.register(UINib(nibName: "RideTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RideTypeCollectionViewCell")
        favouriteLocationCollectionView.register(UINib(nibName: "RideTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RideTypeCollectionViewCell")
    }
    
    private func setStartLocation(){
        if let address = pickup?.completeAddress, !address.isEmpty {
            startLocationButton.setTitle(address, for: .normal)
            startLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        } else {
            startLocationButton.setTitle(Strings.enter_start_location, for: .normal)
            startLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        }
    }
    
    private func setEndLocation() {
        if let address = drop?.completeAddress, !address.isEmpty {
            destinationLocationButton.setTitle(address, for: .normal)
            destinationLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        }else{
            destinationLocationButton.setTitle(Strings.enter_end_location, for: .normal)
            destinationLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        }
    }
    private func getDisplayRideTypeString(rideType: String) -> String{
        switch rideType {
        case TaxiPoolConstants.TRIP_TYPE_LOCAL:
            return "Local Taxi"
        case TaxiPoolConstants.TRIP_TYPE_OUTSTATION:
            return "Outstation Taxi"
        case TaxiPoolConstants.TRIP_TYPE_DRIVER_REQUEST:
            return "Driver"
        case Ride.RIDER_RIDE:
            return "Offer Pool"
        case Ride.PASSENGER_RIDE:
            return "Find Pool"
        default:
            return "Local Taxi"
        }
    }
    
    //MARK: Actions
    @IBAction func startLocationButtonTapped(_ sender: UIButton) {
        userSelectionDelegate?.fromLocationTapped()
    }
    
    @IBAction func destinationLocationButtonTapped(_ sender: UIButton) {
        userSelectionDelegate?.toLocationTapped()
    }
    
    @IBAction func verifyProfileTapped(_ sender: Any) {
        let verifyProfileViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerifyProfileViewController") as! VerifyProfileViewController
        verifyProfileViewController.intialData(isFromSignUpFlow: false)
        self.parentViewController?.navigationController?.pushViewController(verifyProfileViewController, animated: false)
     
    }
}
//MARK: UICollectionViewDataSource
extension RideLocationSelectionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == rideTypeCollectionView{
            return selectionTypes.count
        }else{
            return favouriteLocations.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == rideTypeCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RideTypeCollectionViewCell", for: indexPath) as! RideTypeCollectionViewCell
            if selectionTypes[indexPath.row] ==  selectedType{
                cell.rideTypeView.backgroundColor = UIColor(netHex: 0x00B557)
                cell.rideTypeLabel.textColor = .white
            }else{
                cell.rideTypeView.backgroundColor = UIColor(netHex: 0xEDF6ED)
                cell.rideTypeLabel.textColor = UIColor(netHex: 0x00B557)
            }
            cell.rideTypeLabel.text = getDisplayRideTypeString(rideType: selectionTypes[indexPath.row])
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RideTypeCollectionViewCell", for: indexPath) as! RideTypeCollectionViewCell
            if indexPath.row >= favouriteLocations.endIndex{
                return cell
            }
            cell.rideTypeLabel.text = favouriteLocations[indexPath.row].name
            cell.rideTypeView.layer.borderWidth = 1
            cell.rideTypeView.layer.borderColor = UIColor(netHex: 0xE1E1E1).cgColor
            return cell
        }
    }
}
//MARK: UICollectionViewDelegate
extension RideLocationSelectionTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == rideTypeCollectionView{
            if let selectedCell = collectionView.cellForItem(at: indexPath) as? RideTypeCollectionViewCell{
                selectedCell.rideTypeView.backgroundColor = UIColor(netHex: 0x00B557)
                selectedCell.rideTypeLabel.textColor = .white
            }
            if let prevSelectedCell = collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? RideTypeCollectionViewCell{
                if selectedIndex != indexPath.row{
                    prevSelectedCell.rideTypeView.backgroundColor = UIColor(netHex: 0xEDF6ED)
                    prevSelectedCell.rideTypeLabel.textColor = UIColor(netHex: 0x00B557)
                }
            }
            selectedIndex = indexPath.row
            userSelectionDelegate?.rideTypeChanged(primary: selectionTypes[indexPath.row])
        }else{
            let favLoc = favouriteLocations[indexPath.row]
            let location = Location(id: favLoc.locationId ?? 0, latitude: favLoc.latitude ?? 0, longitude: favLoc.longitude ?? 0, shortAddress: favLoc.shortAddress, completeAddress: favLoc.address, country: favLoc.country, state: favLoc.state, city: favLoc.city, areaName: favLoc.areaName, streetName: favLoc.streetName)
            userSelectionDelegate?.selectedFavLocation(location: location)
        }
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension RideLocationSelectionTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == rideTypeCollectionView{
            return CGSize(width: rideTypeCollectionView.frame.width/2, height: self.rideTypeCollectionView.frame.height)
        }else{
            let label = UILabel(frame: CGRect.zero)
            label.text = favouriteLocations[indexPath.row].name
            label.sizeToFit()
            return CGSize(width: label.frame.size.width + 50, height: 35)
        }
    }
}

struct CommuteSegment {
    static let CARPOOL = "CARPOOL"
    static let TAXI = "TAXI"
    static let DRIVER = "DRIVER"
    var selected : Bool
    var selectedImage : String
    var unselectedImage : String
    var name : String
    var type :String
    var subSegments = [CommuteSubSegment]()
    
    init(selectedImage : String,unselectedImage : String,name : String,type : String,subSegments : [CommuteSubSegment]) {
        self.selectedImage = selectedImage
        self.unselectedImage = unselectedImage
        self.type = type
        self.name = name
        self.selected = false
        self.subSegments = subSegments
    }
    func getSelectedItem() -> CommuteSubSegment{
        for item in subSegments {
            if item.selected {
                return item
            }
        }
        return subSegments[0]
    }
}
struct CommuteSubSegment {
    
    var selected :Bool
    var name : String
    var type :String
    init(name : String,type : String) {
        self.type = type
        self.name = name
        self.selected = false
    }
}
