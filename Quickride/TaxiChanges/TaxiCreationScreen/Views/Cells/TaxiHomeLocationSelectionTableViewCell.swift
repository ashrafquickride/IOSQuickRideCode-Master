//
//  TaxiHomeLocationSelectionTableViewCell.swift
//  Quickride
//
//  Created by HK on 04/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiHomeLocationSelectionTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var startLocationButton: UIButton!
    @IBOutlet weak var destinationLocationButton: UIButton!
    
    @IBOutlet weak var taxiOfferView: UIView!
    @IBOutlet weak var taxiOfferLabel: UILabel!
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var favouriteLocationView: UIView!
    @IBOutlet weak var favouriteLocationCollectionView: UICollectionView!
    //MARK: Properties
    private var pickup : Location?
    private var drop : Location?
    private var userSelectionDelegate: RideLocationSelectionTableViewCellDelegate?
    private var favouriteLocations = [UserFavouriteLocation]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCell()
    }
    
    //MARK: Initializer
    func initializeTaxiLocation(pickup: Location?,drop : Location?, userSelectionDelegate: RideLocationSelectionTableViewCellDelegate?) {
        self.pickup = pickup
        self.drop = drop
        self.userSelectionDelegate = userSelectionDelegate
        if let favLocs = UserDataCache.getInstance()?.getFavoriteLocations(),!favLocs.isEmpty{
            favouriteLocations = favLocs
            favouriteLocationView.isHidden = false
            favouriteLocationCollectionView.reloadData()
        }else{
            favouriteLocationView.isHidden = true
        }
        if let coupon = SharedPreferenceHelper.getTaxiOfferCoupon(){
            taxiOfferView.isHidden = false
            taxiOfferLabel.text = String(format: Strings.use_taxi_offer, arguments: [StringUtils.getStringFromDouble(decimalNumber: coupon.maxDiscount),coupon.couponCode])
            offerImage.image = offerImage.image?.withRenderingMode(.alwaysTemplate)
            offerImage.tintColor = UIColor(netHex: 0x000000)
        }else{
            taxiOfferView.isHidden = true
        }
        setStartLocation()
        setEndLocation()
        ViewCustomizationUtils.addCornerRadiusToView(view: taxiOfferView, cornerRadius: 10)
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
    private func registerCell() {
        favouriteLocationCollectionView.register(UINib(nibName: "RideTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RideTypeCollectionViewCell")
    }
    
    //MARK: Actions
    @IBAction func startLocationButtonTapped(_ sender: UIButton) {
        userSelectionDelegate?.fromLocationTapped()
    }
    
    @IBAction func destinationLocationButtonTapped(_ sender: UIButton) {
        userSelectionDelegate?.toLocationTapped()
    }
}
//MARK: UICollectionViewDataSource
extension TaxiHomeLocationSelectionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favouriteLocations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
//MARK: UICollectionViewDelegate
extension TaxiHomeLocationSelectionTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let favLoc = favouriteLocations[indexPath.row]
        let location = Location(id: favLoc.locationId ?? 0, latitude: favLoc.latitude ?? 0, longitude: favLoc.longitude ?? 0, shortAddress: favLoc.address, completeAddress: favLoc.address, country: favLoc.country, state: favLoc.state, city: favLoc.city, areaName: favLoc.areaName, streetName: favLoc.streetName)
        userSelectionDelegate?.selectedFavLocation(location: location)
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension TaxiHomeLocationSelectionTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = favouriteLocations[indexPath.row].name
        label.sizeToFit()
        return CGSize(width: label.frame.size.width + 50, height: 35)
    }
}
