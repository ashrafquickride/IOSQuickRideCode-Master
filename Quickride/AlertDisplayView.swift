//
//  AlertDisplayView.swift
//  Quickride
//
//  Created by Admin on 04/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

typealias moveToSpecificViewCompletionHandler = (_ result: Bool) -> Void

class AlertDisplayView: ModelView{
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var alertViewWidthConstriant: NSLayoutConstraint!
    
    @IBOutlet weak var actionBtn: UIButton!
    
    @IBOutlet weak var actionBtnHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var alertViewTopConstraint: NSLayoutConstraint!
   
    @IBOutlet weak var offerImageView: UIImageView!
    
    @IBOutlet weak var closeAlertButton: UIButton!
    
    @IBOutlet weak var backgroundView: UIView!
    
    weak var viewController: UIViewController?
    var handler: moveToSpecificViewCompletionHandler?
    var offer : Offer?
    
    func initializeViews(title: String?, message : String?, image: UIImage?, viewController: UIViewController, actionTitle: String?, offer: Offer?, offerImage: UIImage?, backgroundColor: UIColor?,  x: CGFloat, y: CGFloat, handler: moveToSpecificViewCompletionHandler?){
        if offer == nil{
            self.messageLabel.text = message
            self.viewController = viewController
            self.imageView.image = image
            self.title.text = title
            self.handler = handler
            self.actionBtn.setTitle(actionTitle, for: .normal)
            alertView.backgroundColor = backgroundColor
            ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 10)
            ViewCustomizationUtils.addCornerRadiusToView(view: actionBtn, cornerRadius: 5.0)
        }else{
            offerImageView.image = offerImage?.roundedCornerImage
            self.viewController = viewController
            self.offer = offer
            alertView.backgroundColor = .clear
            actionBtn.isHidden = true
        }
        alertView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alertViewTapped(_:))))
        closeAlertButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAlertViewTapped(_:))))
        alertViewWidthConstriant.constant = viewController.view.frame.size.width - 30
       
        if ViewCustomizationUtils.hasTopNotch{
            self.frame = CGRect(x: x, y: y + 25, width: alertViewWidthConstriant.constant, height: alertView.frame.size.height + 50)
        }else{
           self.frame = CGRect(x: x, y: y, width: alertViewWidthConstriant.constant, height: alertView.frame.size.height + 50)
        }
        self.loadView()
    }
    
    func loadView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionFlipFromLeft],
                       animations: {
                        self.alertView.frame.origin.y = 0
                        self.alertView.frame.origin.x += self.alertView.bounds.width
        }, completion: nil)
        self.alertView.isHidden = false
        viewController!.view.addSubview(self)
    }
    
    @objc private func dismissAlertViewTapped(_ gesture : UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionFlipFromLeft],
                       animations: {
                       self.alertView.frame.origin.x += self.alertView.bounds.width
        }, completion: {(_ completed: Bool) -> Void in
            self.alertView.isHidden = true
            self.removeFromSuperview()
        })
    }
    
    @objc private func alertViewTapped(_ gesture : UITapGestureRecognizer){
        if offer == nil{
            handler!(true)
            self.alertView.isHidden = true
            self.removeFromSuperview()
        }else{
            if offer?.linkUrl == nil{
                self.alertView.isHidden = true
                self.removeFromSuperview()
                return
            }else{
                let queryItems = URLQueryItem(name: "&isMobile", value: "true")
                var urlcomps = URLComponents(string :  offer!.linkUrl!)
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
                    viewController?.navigationController?.pushViewController(webViewController, animated: false)
                    self.alertView.isHidden = true
                    self.removeFromSuperview()
                }
            }
        }
    }
}
