//
//  UpcomingTripsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 11/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class UpcomingTripsTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var tripsCollectionView: UICollectionView!

    private var taxiTrips = [TaxiRidePassenger]()

    func initialiseNextTrip() {
        taxiTrips = MyActiveTaxiRideCache.getInstance().getActiveTaxiRides()
        taxiTrips.sort(by: { $0.startTimeMs ?? 0 < $1.startTimeMs ?? 0 })
        tripsCollectionView.register(UINib(nibName: "UpcomingTripCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingTripCollectionViewCell")
        tripsCollectionView.reloadData()
    }

    @IBAction func viewAllTapped(_ sender: Any) {
        let myTripsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "MyTripsViewController") as! MyTripsViewController
        self.parentViewController?.navigationController?.pushViewController(myTripsViewController, animated: false)
    }
}

extension UpcomingTripsTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taxiTrips.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpcomingTripCollectionViewCell", for: indexPath) as! UpcomingTripCollectionViewCell
        if taxiTrips.endIndex <= indexPath.row {
            return cell
        }
        cell.initialiseTripDetails(taxiRidePassenger: taxiTrips[indexPath.row])
        return cell
    }
}

extension UpcomingTripsTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !taxiTrips.isEmpty, let id = taxiTrips[indexPath.row].id {
            let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
            taxiLiveRide.initializeDataBeforePresenting(rideId: id)
            ViewControllerUtils.displayViewController(currentViewController: self.parentViewController, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

extension UpcomingTripsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = tripsCollectionView.frame.size.width
        if taxiTrips.count > 1 {
            width = tripsCollectionView.frame.size.width - 40
        }
        return CGSize(width: width, height: tripsCollectionView.frame.size.height)
    }
}
