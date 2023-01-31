//
//  HomeScreenAndLiveRideOfferTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 12/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class HomeScreenAndLiveRideOfferTableViewCell: UITableViewCell {
    @IBOutlet weak var OfferCollectionView: UICollectionView!
    private var offerList: [Offer] = []
    private var isFromLiveRide : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        registerCell()
    }
    
    func prepareData(offerList: [Offer],isFromLiveRide: Bool) {
        self.offerList = offerList
        self.isFromLiveRide = isFromLiveRide
        OfferCollectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func registerCell() {
        OfferCollectionView.register(UINib(nibName: "OffersWithTextCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OffersWithTextCollectionViewCell")
        OfferCollectionView.register(UINib(nibName: "ViewAllOfferCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ViewAllOfferCollectionViewCell")
    }
}

extension HomeScreenAndLiveRideOfferTableViewCell : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return offerList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == offerList.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewAllOfferCollectionViewCell", for: indexPath) as! ViewAllOfferCollectionViewCell
            return cell
        }else{
            let offerWithTextCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OffersWithTextCollectionViewCell", for: indexPath) as! OffersWithTextCollectionViewCell
            offerWithTextCell.updateUI(offerData: offerList[indexPath.row])
            return offerWithTextCell
        }
    }
}

extension HomeScreenAndLiveRideOfferTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == offerList.count {//ViewAll Tapped
            let offerVC = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myOffersViewController) as! MyOffersViewController
            if isFromLiveRide {
                offerVC.prepareData(selectedFilterString: Strings.all)
            }else{
                offerVC.prepareData(selectedFilterString: offerList[indexPath.row - 1].category ?? Strings.all)
            }
            self.parentViewController?.navigationController?.pushViewController(offerVC, animated: true)
        }else{
            let offer = offerList[indexPath.row]
            updateTheOfferSeen(index : indexPath.row)
            OfferImpressionHandler.sharedInstance.offerClicked(offerId: StringUtils.getStringFromDouble(decimalNumber: offer.id))
            if let offerLinkURL = offer.linkUrl {
                let queryItems = URLQueryItem(name: "&isMobile", value: "true")
                var urlcomps = URLComponents(string: offerLinkURL)
                var existingQueryItems = urlcomps?.queryItems ?? []
                if !existingQueryItems.isEmpty {
                    existingQueryItems.append(queryItems)
                }else {
                    existingQueryItems = [queryItems]
                }
                urlcomps?.queryItems = existingQueryItems
                if urlcomps?.url != nil{
                    let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                    webViewController.initializeDataBeforePresenting(titleString: Strings.offers, url: urlcomps!.url!, actionComplitionHandler: nil)
                    self.parentViewController?.navigationController?.pushViewController(webViewController, animated: false)
                } else {
                    UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for indexPath in self.OfferCollectionView.indexPathsForVisibleItems {
                if indexPath.row != self.offerList.count {
                    self.updateTheOfferSeen(index: indexPath.row)
                }
            }
        }
    }
    
    private func updateTheOfferSeen(index : Int) {
        if  !offerList[index].isImpressionSaved {
            offerList[index].isImpressionSaved = true
            OfferImpressionHandler.sharedInstance.addOffersForImpressionSaving(offerIdString: StringUtils.getStringFromDouble(decimalNumber: offerList[index].id))
        }
    }
}

extension HomeScreenAndLiveRideOfferTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.row == offerList.count {
            return CGSize(width: 130, height: 120)
        }else{
            return CGSize(width: OfferCollectionView.frame.size.width - 40, height: 120)
        }
    }
}
