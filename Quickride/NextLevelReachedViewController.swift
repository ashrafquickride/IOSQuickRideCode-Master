//
//  NextLevelReachedViewController.swift
//  Quickride
//
//  Created by Halesh on 01/05/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class NextLevelReachedViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var reachedLabel: UILabel!
    @IBOutlet weak var lavelInfoLabel: UILabel!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var levelView: UIView!
    
    private var referralStats: ReferralStats?
    
    func initializeNextLevelView(referralStats: ReferralStats){
        self.referralStats = referralStats
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        levelLabel.text = String(format: Strings.category_level, arguments: [String(referralStats?.level ?? 0)])
        reachedLabel.text = String(format: Strings.reached_next_level, arguments: [String(referralStats?.level ?? 0)])
        assignLevelAndColor(userLevel: referralStats?.level ?? 0)
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    private func assignLevelAndColor(userLevel: Int){
        switch userLevel {
        case 1:
            levelView.backgroundColor = UIColor(netHex: 0x3298A5)
        case 2:
            levelView.backgroundColor = UIColor(netHex: 0x636CCE)
        case 3:
            levelView.backgroundColor = UIColor(netHex: 0xE66464)
        case 4:
            levelView.backgroundColor = UIColor(netHex: 0x509CC6)
        case 5:
            levelView.backgroundColor = UIColor(netHex: 0xA1A13F)
        default:
            levelView.backgroundColor = UIColor(netHex: 0xEBEBEB)
        }
    }
    
    @IBAction func checkBenefitsTapped(_ sender: Any) {
        guard let refStats = referralStats else { return }
        let levelsViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.levelsViewController) as! LevelsViewController
        levelsViewController.initializeLevels(referralStats: refStats)
        self.navigationController?.pushViewController(levelsViewController, animated: true)
    }
}
