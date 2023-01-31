//
//  CustomerElementsInfoViewController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 18/10/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class CustomerElementsInfoViewController: UIViewController{
    
    @IBOutlet weak var tilteLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var messageDescriptionLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var supportLinkButton: UIButton!
    
    @IBOutlet weak var heightOfTitle: NSLayoutConstraint!
    
    var customerSupportElement : CustomerSupportElement?
    var navigationItemTitle : String?
    
    func initializeDataBeforepresentingView(customerSupportElement : CustomerSupportElement?,navigationItemTitle : String?)
    {
        self.customerSupportElement = customerSupportElement
        self.navigationItemTitle = navigationItemTitle
    }
    override func viewDidLoad() {
        if customerSupportElement?.title != nil
        {
            tilteLabel.text = customerSupportElement!.title
            let attributes = [NSAttributedString.Key.font : UIFont(name: ViewCustomizationUtils.FONT_STYLE, size: 14)!]
            let rect = customerSupportElement!.title!.boundingRect(with: CGSize(width: self.view.frame.size.width - 40, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
            heightOfTitle.constant = rect.height + 23
        }
        else
        {
            heightOfTitle.constant = 0
        }
        if customerSupportElement?.message != nil
        {
            descriptionLabel.text = customerSupportElement?.message
            adjsutheightOfTheMessageLabel()
        }
        else{
            messageDescriptionLabelHeight.constant = 0
        }
        ViewCustomizationUtils.addCornerRadiusToView(view: supportLinkButton, cornerRadius: 3.0)
        supportLinkButton.setTitle(Strings.ok, for: .normal)
        self.navigationItem.title = navigationItemTitle
    }
    func adjsutheightOfTheMessageLabel()
    {
        let attributes = [NSAttributedString.Key.font : UIFont(name: ViewCustomizationUtils.FONT_STYLE, size: 14)!]
       let rect = customerSupportElement?.message?.boundingRect(with: CGSize(width: self.view.frame.size.width - 40, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
       messageDescriptionLabelHeight.constant = rect!.height + 20
        
    }

    @IBAction func okButtonTapped(_ sender: Any) {
        ContainerTabBarViewController.indexToSelect = 1
        self.navigationController?.popToRootViewController(animated: false)
    }
    
       @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }

}
