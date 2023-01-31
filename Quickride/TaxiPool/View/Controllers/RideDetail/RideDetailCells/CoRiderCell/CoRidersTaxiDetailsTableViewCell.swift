//
//  CoRidersTaxiDetailsTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 5/17/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

class CoRidersTaxiDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var passengerCollectionViewCell: UICollectionView!
    @IBOutlet weak var coRiderHeaderLabel: UILabel!
    @IBOutlet weak var notificationHandlerInfoLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    private var coRiderData = [TaxiShareRidePassengerInfos]()
    private var potentialRiders = [PotentialRiderDetails]()
    private var taxiInviteData : TaxiInviteEntity?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCells()
        // Initialization code
    }
    
    private func registerCells() {
        passengerCollectionViewCell.register(UINib(nibName: "CoRidersTaxiPoolCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CoRidersTaxiPoolCollectionViewCell")
    }
    
    func getDataAndUpdate(data: [TaxiShareRidePassengerInfos]?,potenTialCoRide: [PotentialRiderDetails]?,taxiInviteData: TaxiInviteEntity?) {
        self.coRiderData = data ?? []
        self.potentialRiders = potenTialCoRide ?? []
        self.taxiInviteData = taxiInviteData
        passengerCollectionViewCell.reloadData()
        setUpUI()
    }
    
    private func setUpUI() {
        if coRiderData.isEmpty {
            notificationHandlerInfoLabel.text = Strings.best_matches_taxipool
            notificationHandlerInfoLabel.isHidden = false
            coRiderHeaderLabel.text = Strings.potential_co_riders
        }else{
            notificationHandlerInfoLabel.isHidden = true
            notificationHandlerInfoLabel.text = ""
            
            coRiderHeaderLabel.text = Strings.co_riders
        }
        if taxiInviteData != nil {
            separatorView.isHidden = false
        } else {
            separatorView.isHidden = true
        }
    }
}

extension CoRidersTaxiDetailsTableViewCell: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.coRiderData.isEmpty {
            return potentialRiders.count
        }
        return coRiderData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoRidersTaxiPoolCollectionViewCell", for: indexPath) as! CoRidersTaxiPoolCollectionViewCell
        if coRiderData.isEmpty {
            ImageCache.getInstance().setImageToView(imageView: cell.rideProfileImageView, imageUrl: potentialRiders[indexPath.row].imageURI, gender: potentialRiders[indexPath.row].gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
            cell.riderNameLabel.isHidden = false
            cell.riderNameLabel.text = potentialRiders[indexPath.row].name ?? ""
            
        }else{
            ImageCache.getInstance().setImageToView(imageView: cell.rideProfileImageView, imageUrl: coRiderData[indexPath.row].passengerImageURI, gender: "U",imageSize: ImageCache.DIMENTION_SMALL)
            cell.riderNameLabel.isHidden = false
            cell.riderNameLabel.text = coRiderData[indexPath.row].passengerName
        }
        return cell
    }
    
}
