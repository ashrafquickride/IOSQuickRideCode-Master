//
//  SimplAndFirstRideFreeOfferViewController.swift
//  Quickride
//
//  Created by Halesh on 25/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import TransitionButton

class SimplAndFirstRideFreeOfferViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var simplView: UIView!
    @IBOutlet weak var firstRideView: UIView!
    @IBOutlet weak var simplTickMarkButton: UIButton!
    @IBOutlet weak var firstRideTickMarkButton: UIButton!
    @IBOutlet weak var continueButton: TransitionButton!
    
    private var simplAndFirstRideFreeOfferViewModel = SimplAndFirstRideFreeOfferViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
        }, completion: nil)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        simplView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(simplViewTapped(_:))))
        firstRideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(firstRideViewTapped(_:))))
        ViewCustomizationUtils.addBorderToView(view: simplView, borderWidth: 1, color: UIColor(netHex: 0xE1E1E1))
        ViewCustomizationUtils.addBorderToView(view: firstRideView, borderWidth: 1, color: UIColor(netHex: 0xE1E1E1))
        continueButton.backgroundColor = UIColor(netHex: 0xD3D3D3)
    }
    
    @objc private func backGroundViewTapped(_ gesture : UITapGestureRecognizer){
        closeView()
    }
    
    @objc private func simplViewTapped(_ gesture : UITapGestureRecognizer){
        if !simplAndFirstRideFreeOfferViewModel.isSimplSelected{
            simplTickMarkButton.setImage(UIImage(named: "check"), for: .normal)
            simplAndFirstRideFreeOfferViewModel.isSimplSelected = true
        }
        firstRideTickMarkButton.setImage(UIImage(named: "uncheck"), for: .normal)
        simplAndFirstRideFreeOfferViewModel.isFirstRideSelected = false
        continueButton.backgroundColor = UIColor(netHex: 0x00B557)
    }
    
    @objc private func firstRideViewTapped(_ gesture : UITapGestureRecognizer){
        if !simplAndFirstRideFreeOfferViewModel.isFirstRideSelected{
            firstRideTickMarkButton.setImage(UIImage(named: "check"), for: .normal)
            simplAndFirstRideFreeOfferViewModel.isFirstRideSelected = true
        }
        simplTickMarkButton.setImage(UIImage(named: "uncheck"), for: .normal)
        simplAndFirstRideFreeOfferViewModel.isSimplSelected = false
        continueButton.backgroundColor = UIColor(netHex: 0x00B557)
    }
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        if simplAndFirstRideFreeOfferViewModel.isSimplSelected{
            simplAndFirstRideFreeOfferViewModel.linkSimplWallet(viewController: self,delegate: self)
            continueButton.startAnimation()
        }else{
            self.view.removeFromSuperview()
            self.removeFromParent()
            showActivatedAlert(message: Strings.got_first_ride_free)
        }
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    func showActivatedAlert(message: String){
        let animationAlertController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AnimationAlertController") as! AnimationAlertController
        animationAlertController.initializeDataBeforePresenting(activatedMessage: message, isFromLinkedWallet: true, handler: nil)
        ViewControllerUtils.addSubView(viewControllerToDisplay: animationAlertController)
    }
    @IBAction func whatSimplClicked(_ sender: Any) {
        let infoDailogWithImage = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InfoDailogWithImage") as! InfoDailogWithImage
        infoDailogWithImage.initializeInfoDailog(image: UIImage(named: "simpl_logo_with_text") ?? UIImage(), message: Strings.whats_simpl_text)
        ViewControllerUtils.addSubView(viewControllerToDisplay: infoDailogWithImage)
    }
    
    @IBAction func termsAndConditionClicked(_ sender: Any) {
        let url = NSURL(string :  AppConfiguration.simpl_terms_url)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }
}
extension SimplAndFirstRideFreeOfferViewController: SimplAndFirstRideFreeOfferViewModelDelegate{
    func handleSuccesResponse() {
        continueButton.stopAnimation()
        continueButton.cornerRadius = 8
        self.view.removeFromSuperview()
        self.removeFromParent()
        showActivatedAlert(message: Strings.got_free_ride)
    }
    
    func hnadleFailureResponse() {
        continueButton.stopAnimation()
        continueButton.cornerRadius = 8
    }
}
