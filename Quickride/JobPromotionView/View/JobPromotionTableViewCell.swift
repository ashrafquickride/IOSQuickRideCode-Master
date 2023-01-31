//
//  JobPromotionTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 16/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class JobPromotionTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var exclusiveLabel: UILabel!
    @IBOutlet weak var exclusiveLabelHeightConstraint: NSLayoutConstraint!
    
    private var jobPromotionData = [JobPromotionData]()
    private var screenName: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: "JobPromotionCollectionViewCell", bundle : nil), forCellWithReuseIdentifier: "JobPromotionCollectionViewCell")
    }
    
    func setupUI(jobPromotionData: [JobPromotionData],screenName: String) {
        self.jobPromotionData = jobPromotionData
        self.screenName = screenName
        if tag == 1 {
            exclusiveLabel.isHidden = true
            self.backgroundColor = UIColor(netHex: 0xf6f6f6)
        }else if tag == 2 {
            exclusiveLabel.isHidden = false
            exclusiveLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        } else {
            exclusiveLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
            exclusiveLabel.isHidden = false
        }
    }
}

extension JobPromotionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jobPromotionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JobPromotionCollectionViewCell", for: indexPath) as! JobPromotionCollectionViewCell
        if jobPromotionData.endIndex <= indexPath.row || jobPromotionData[indexPath.row].html == nil || jobPromotionData[indexPath.row].html?.isEmpty == true{
            return cell
        }
        cell.setupUI(jobPromotionHTMLString: jobPromotionData[indexPath.row].html ?? "")
        return cell
    }
}
extension JobPromotionTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        QuickJobsURLHandler.showPerticularJobInQuickJobPortal(jobUrl: jobPromotionData[indexPath.row].deeplinkForPostedJob ?? "")
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
             for indexPath in self.collectionView.indexPathsForVisibleItems {
                if indexPath.row < self.jobPromotionData.count && !self.jobPromotionData[indexPath.row].isImpressionSaved{
                    self.jobPromotionData[indexPath.row].isImpressionSaved = true
                    let impressionAudit = ImpressionAudit(userId: self.jobPromotionData[indexPath.row].userId, campaignId: self.jobPromotionData[indexPath.row].id, createdTime: self.jobPromotionData[indexPath.row].createdTime, type: self.jobPromotionData[indexPath.row].type ?? "", deviceType: ImpressionAudit.DEVICE_TYPE_IOS, screenName: self.screenName ?? "")
                    JobPromotionUtils.updateJobPromotionViewCount(impressionAudit: impressionAudit)
                }
            }
        }
    }
}
extension JobPromotionTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 22, height: 135)
    }
}
