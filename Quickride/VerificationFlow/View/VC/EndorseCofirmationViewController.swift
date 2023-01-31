//
//  EndorseCofirmationViewController.swift
//  Quickride
//
//  Created by Vinutha on 09/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class EndorseCofirmationViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var confirmationView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    //MARK: Properties
    var viewModel = EndorseCofirmationViewModel()
    private var handler: clickActionCompletionHandler?
    
    //MARK: Initializer
    func initializeData(endorsementRequestNotiifcationData: EndorsementRequestNotificationData, notication: UserNotification, handler: @escaping clickActionCompletionHandler) {
        self.handler = handler
        viewModel.initializeData(endorsementRequestNotiifcationData: endorsementRequestNotiifcationData, notication: notication)
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Methods
    private func setupUI() {
        var userName = ""
        if let name = viewModel.endorsementRequestNotifcationData.name {
            userName = name
        }
        let message = String(format: Strings.endorsement_confirmation, arguments: [userName])
        let attributedString = NSMutableAttributedString(string: message)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1.4
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        descriptionLabel.attributedText = attributedString
        confirmationView.isHidden = false
        successView.isHidden = true
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(endorsementRequestAccepted(_:)), name: .endorsementRequestAccepted, object: nil)
    }
    
    private func animateView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.bottomView.center.y -= self.bottomView.bounds.height
            }, completion: nil)
    }
    
    @objc private func backGroundViewTapped(_ gesture : UITapGestureRecognizer) {
        removeView(action: nil)
    }
    
    private func removeView(action: String?) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {
            self.bottomView.center.y += self.bottomView.bounds.height
            self.bottomView.layoutIfNeeded()
        }) { (value) in
            self.handler?(action)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }

    @objc func endorsementRequestAccepted(_ notification : NSNotification){
        confirmationView.isHidden = true
        successView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.removeView(action: Strings.success)
        }
    }
    
    //MARK: Actions
    @IBAction func iAgreeTapped(_ sender: UIButton) {
        viewModel.acceptEndorsementRequest(viewController: self)
    }
}
