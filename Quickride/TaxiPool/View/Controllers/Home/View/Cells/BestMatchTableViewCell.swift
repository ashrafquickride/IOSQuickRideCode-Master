//
//  BestMatchTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 9/5/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class BestMatchTableViewCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var shareTypeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var joinBtn: QRCustomButton!
    @IBOutlet weak var participentCollectionView: UICollectionView!
    
    private var availableTaxi : MatchedShareTaxi?
   
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCell()
        // Initialization code
    }
    
    private func registerCell() {
        participentCollectionView.register(UINib(nibName: "PassengerInfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PassengerInfoCollectionViewCell")
    }
    
    func showRideParticipentDetails(taxiShare: MatchedShareTaxi?,shareType: String) {
        headerLabel.text = String(format: Strings.available_taxi_option_header, arguments: [taxiShare?.shareType ?? "",shareType])
        shareTypeLabel.text = taxiShare?.shareType ?? ""
        priceLabel.text = "₹\(Int(taxiShare?.minPoints ?? 0))"
        infoLabel.isHidden = true
        availableTaxi = taxiShare
        participentCollectionView.isHidden = false
        participentCollectionView.reloadData()
    }
    
    func showShareType(shareType: String, price: String) {
        headerLabel.text = ""
        infoLabel.isHidden = false
        participentCollectionView.isHidden = true
        shareTypeLabel.text = shareType
        priceLabel.text = price
    }
}

extension BestMatchTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableTaxi?.capacity ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PassengerInfoCollectionViewCell", for: indexPath) as! PassengerInfoCollectionViewCell
        if indexPath.row < availableTaxi?.taxiShareRidePassengerInfos?.count ?? 0 {
            ImageCache.getInstance().setImageToView(imageView: cell.participentImageView, imageUrl: availableTaxi?.taxiShareRidePassengerInfos?[indexPath.row].passengerImageURI, gender: "U",imageSize: ImageCache.DIMENTION_SMALL)
            cell.participentNameLabel.text = availableTaxi?.taxiShareRidePassengerInfos?[indexPath.row].passengerName ?? ""
        }else{
            cell.participentImageView.image = UIImage(named: "empty_passenger")
            cell.participentNameLabel.text = ""
        }
        return cell
    }
    
}
