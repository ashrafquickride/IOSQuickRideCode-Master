//
//  FrequentRideShowingTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 02/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol FrequentRideShowingTableViewCellDelegate: class {
    func findOrOfferRidePressed(ride: Ride)
    func editRidePressed(ride: Ride)
}

class FrequentRideShowingTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet weak var frequentRideCollectionView: UICollectionView!
    
    //MARK: Variables
    private var closeRidesdata = [Ride]()
    private var numberOfCells = 0
    weak var delegate: FrequentRideShowingTableViewCellDelegate?
    
    func initialiseData(numberOfCells: Int,ride: [Ride]) {
        closeRidesdata = ride
        self.numberOfCells = numberOfCells
        setUpUI()
    }
    
    private func setUpUI() {
        frequentRideCollectionView.addShadow()
        frequentRideCollectionView.register(UINib(nibName: "FrequentRideCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FrequentRideCollectionViewCell")
        frequentRideCollectionView.reloadData()
    }
}

extension FrequentRideShowingTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrequentRideCollectionViewCell", for: indexPath) as! FrequentRideCollectionViewCell
        cell.updateUI(rideToShow: closeRidesdata[indexPath.row])
        cell.findOrOfferRideButton.tag = indexPath.row
        cell.findOrOfferRideButton.addTarget(self, action: #selector(findOrOfferRideTapped(_:)), for: .touchUpInside)
        cell.editRideButton.tag = indexPath.row
        cell.editRideButton.addTarget(self, action: #selector(editRideTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc private func findOrOfferRideTapped(_ sender: AnyObject) {
        delegate?.findOrOfferRidePressed(ride: closeRidesdata[sender.tag])
    }
    
    @objc private func editRideTapped(_ sender: AnyObject) {        
        let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.routeViewController) as! RouteViewController
        routeViewController.initializeDataBeforePresenting(ride: closeRidesdata[sender.tag])
        self.parentViewController?.navigationController?.pushViewController(routeViewController, animated: false)
    }
}
extension FrequentRideShowingTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frequentRideCollectionView.frame.size.width - 40, height: frequentRideCollectionView.frame.size.height)
    }
}
