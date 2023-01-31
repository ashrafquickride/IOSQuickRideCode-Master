//
//  OffersListTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 05/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol OffersListTableViewCellDelegate: class {
    func moveToOfferDetails(offerData: Offer)
}

class OffersListTableViewCell: UITableViewCell {
    @IBOutlet weak var offerListColletionView: UICollectionView!
    
    private  var offersData = [Offer]()
    
    weak var delegate: OffersListTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setUpUI() {
        offerListColletionView.register(UINib(nibName: "offersListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "offersListCollectionViewCell")
        guard let offersList =  ConfigurationCache.getInstance()?.offersList else { return }
         offersData = filterOffers(offerList : offersList)
        offerListColletionView.reloadData()
    }
    
    func filterOffers(offerList: [Offer]) -> [Offer]{
        var filterList = [Offer]()
        for offer in offerList{
            if (offer.displayType == Strings.displaytype_both || offer.displayType == Strings.displaytype_offerscreen)  && (offer.targetDevice == Strings.targetdevice_all || offer.targetDevice == Strings.targetdevice_ios) && offer.offerScreenImageUri != nil && offer.offerScreenImageUri!.isEmpty == false{
                filterList.append(offer)
            }
        }
        var finalOfferList = [Offer]()
        for offer in filterList {
            let userProfile = UserDataCache.getInstance()!.getLoggedInUserProfile()
            if userProfile != nil && (UserProfile.PREFERRED_ROLE_PASSENGER == userProfile!.roleAtSignup && offer.targetRole == Strings.targetrole_passenger) || (UserProfile.PREFERRED_ROLE_RIDER == userProfile!.roleAtSignup && offer.targetRole == Strings.targetrole_rider) {
                finalOfferList.append(offer)
            } else if offer.targetRole == Strings.targetrole_both {
                finalOfferList.append(offer)
            }
        }
        return finalOfferList
    }
    
    @IBAction func allOfferBtnPressed(_ sender: UIButton) {
        let destViewController : UIViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myOffersViewController)
        self.parentViewController?.navigationController?.pushViewController(destViewController, animated: true)

    }
    
}

extension OffersListTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if offersData.isEmpty{
            return 0
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = offerListColletionView.dequeueReusableCell(withReuseIdentifier: "offersListCollectionViewCell", for: indexPath) as! offersListCollectionViewCell
        let offer = getOffer()
        cell.offerData(offer: offer)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        let offer = getOffer()
        OfferImpressionHandler.sharedInstance.offerClicked(offerId: StringUtils.getStringFromDouble(decimalNumber: offer.id))
        delegate?.moveToOfferDetails(offerData: offer)
    }
        
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            var offer = self.getOffer()
            if !offer.isImpressionSaved {
                offer.isImpressionSaved = true
                OfferImpressionHandler.sharedInstance.addOffersForImpressionSaving(offerIdString: StringUtils.getStringFromDouble(decimalNumber: offer.id))
            }
        }
    }
    func getOffer() -> Offer{
        var index  = SharedPreferenceHelper.getTripReportOfferShownIndex()
        if index >= offersData.count{
            index = offersData.count-1
        }
        return offersData[index]
    }
}

extension OffersListTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: offerListColletionView.frame.size.width, height: offerListColletionView.frame.size.height)
    }
}
