//
//  TopThereeReferralsTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 24/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol TopThereeReferralsTableViewCellDelegate: class {
    func checkLeaderBoardClicked()
}
class TopThereeReferralsTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var topOneUserImage: UIImageView!
    @IBOutlet weak var topOneUserNameLabel: UILabel!
    @IBOutlet weak var topTwoUserImage: UIImageView!
    @IBOutlet weak var topTwoUserNameLabel: UILabel!
    @IBOutlet weak var topThreeUserImage: UIImageView!
    @IBOutlet weak var topThreeUserNameLabel: UILabel!
    @IBOutlet weak var checkLeaderButton: UIButton!
    @IBOutlet weak var loadingView1: UIView!
    @IBOutlet weak var loadingView2: UIView!
    @IBOutlet weak var loadingView3: UIView!
    
    //MARK: Variables
    weak private var delegate: TopThereeReferralsTableViewCellDelegate?
    
    func initializeTopThreeReferrals(referralLeaderList: [ReferralLeader],delegate: TopThereeReferralsTableViewCellDelegate){
        if referralLeaderList.isEmpty{
            topOneUserImage.backgroundColor = UIColor.black.withAlphaComponent(0.05)
            topTwoUserImage.backgroundColor = UIColor.black.withAlphaComponent(0.05)
            topThreeUserImage.backgroundColor = UIColor.black.withAlphaComponent(0.05)
            checkLeaderButton.isHidden = true
            loadingView1.isHidden = false
            loadingView2.isHidden = false
            loadingView3.isHidden = false
        }else{
            self.delegate = delegate
            checkLeaderButton.isHidden = false
            topOneUserImage.backgroundColor = .clear
            topTwoUserImage.backgroundColor = .clear
            topThreeUserImage.backgroundColor = .clear
            loadingView1.isHidden = true
            loadingView2.isHidden = true
            loadingView3.isHidden = true
            if referralLeaderList.count >= 1{
                if let leaderGender = referralLeaderList[0].gender{
                    ImageCache.getInstance().setImageToView(imageView: topOneUserImage, imageUrl: referralLeaderList[0].imageUrl, gender: leaderGender,imageSize: ImageCache.DIMENTION_SMALL)
                }else{
                    topOneUserImage.image = ImageCache.getInstance().getDefaultUserImage(gender: "U")
                }
                topOneUserNameLabel.text = (referralLeaderList[0].userName?.capitalized ?? "") + "(\(referralLeaderList[0].activatedReferralCount))"
            }
            
            if referralLeaderList.count >= 2{
                if let leaderGender = referralLeaderList[1].gender{
                    ImageCache.getInstance().setImageToView(imageView: topTwoUserImage, imageUrl: referralLeaderList[1].imageUrl, gender: leaderGender,imageSize: ImageCache.DIMENTION_SMALL)
                }else{
                    topTwoUserImage.image = ImageCache.getInstance().getDefaultUserImage(gender: "U")
                }
                topTwoUserNameLabel.text = (referralLeaderList[1].userName?.capitalized ?? "") + "(\(referralLeaderList[1].activatedReferralCount))"
            }
            
            if referralLeaderList.count >= 3{
                if let leaderGender = referralLeaderList[2].gender{
                    ImageCache.getInstance().setImageToView(imageView: topThreeUserImage, imageUrl: referralLeaderList[2].imageUrl, gender: leaderGender,imageSize: ImageCache.DIMENTION_SMALL)
                }else{
                    topThreeUserImage.image = ImageCache.getInstance().getDefaultUserImage(gender: "U")
                }
                topThreeUserNameLabel.text = (referralLeaderList[2].userName?.capitalized ?? "") + "(\(referralLeaderList[2].activatedReferralCount))"
            }
        }
    }
    
    //MARK: Actions
    @IBAction func checkLeaderBoardButtonClicked(_ sender: Any) {
        delegate?.checkLeaderBoardClicked()
    }
}
