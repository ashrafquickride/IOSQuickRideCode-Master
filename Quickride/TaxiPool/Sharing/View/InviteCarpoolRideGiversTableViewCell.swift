//
//  InviteCarpoolRideGiversTableViewCell.swift
//  Quickride
//
//  Created by HK on 11/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class InviteCarpoolRideGiversTableViewCell: UITableViewCell {

    @IBOutlet weak var carpoolRidesAtLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var routeMatchPercentage: UILabel!
    private var matchedRideGivers = [MatchedRider]()
    private var taxiRide: TaxiRidePassenger?
    
    func showCarpoolRideGivers(matchedRideGivers: [MatchedRider],taxiRide: TaxiRidePassenger){
        self.matchedRideGivers = matchedRideGivers
        self.taxiRide = taxiRide
        let clientConfiguartion = ConfigurationCache.getObjectClientConfiguration()
        routeMatchPercentage.text = String(format: Strings.found_matches_and_route_match_per, arguments: [String(matchedRideGivers.count),String(clientConfiguartion.minMatchingPercentForTaxiRidesToRetrieveCarpoolRiders),Strings.percentage_symbol])
        carpoolRidesAtLabel.text = String(format: Strings.carpoolRides_at, arguments: [StringUtils.getStringFromDouble(decimalNumber: matchedRideGivers.first?.points)])
        collectionView.register(UINib(nibName: "InviteCarpoolRideGiverCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InviteCarpoolRideGiverCollectionViewCell")
        collectionView.reloadData()
    }
}

extension InviteCarpoolRideGiversTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matchedRideGivers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InviteCarpoolRideGiverCollectionViewCell", for: indexPath) as! InviteCarpoolRideGiverCollectionViewCell
        if matchedRideGivers.endIndex <= indexPath.row{
            return cell
        }
        cell.showMatchedRider(matchedRider: matchedRideGivers[indexPath.row], taxiRide: taxiRide!, viewcontroller: parentViewController ?? ViewControllerUtils.getCenterViewController())
        return cell
    }
}
extension InviteCarpoolRideGiversTableViewCell : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let taxiRide = self.taxiRide else { return }
        let ride = PassengerRide(taxiRide: taxiRide)
            let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
            mainContentVC.initializeData(ride: ride, matchedUserList: matchedRideGivers, viewType: DetailViewType.RideDetailView, selectedIndex: indexPath.item, startAndEndChangeRequired: false, selectedUserDelegate: nil)
            let transition:CATransition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromBottom
        self.parentViewController?.view.layer.add(transition, forKey: kCATransition)
        self.parentViewController?.navigationController?.pushViewController(mainContentVC, animated: false)
    }
}
//UICollectionViewDelegateFlowLayout
extension InviteCarpoolRideGiversTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.frame.size.width - 15
        if matchedRideGivers.count > 1{
            width = collectionView.frame.size.width - 40
        }
        return CGSize(width: width, height: collectionView.frame.size.height)
    }
}
