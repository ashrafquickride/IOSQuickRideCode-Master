//
//  InfoDailogWithImage.swift
//  Quickride
//
//  Created by Halesh on 25/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

class InfoDailogWithImage: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var infoTextLabel: UILabel!
    @IBOutlet weak var gotItButton: UIButton!
    
    //MARK: Variables
    private var image: UIImage?
    private var message: String?
    
    func initializeInfoDailog(image: UIImage, message: String){
        self.image = image
        self.message = message
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        let attributedString = NSMutableAttributedString(string: message ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        infoTextLabel.attributedText = attributedString
        infoImageView.image = image
        ViewCustomizationUtils.addCornerRadiusToView(view: gotItButton, cornerRadius: 8)
        ViewCustomizationUtils.addBorderToView(view: gotItButton, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
    }
    
    @objc private func backGroundViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    //MARK: Action
    @IBAction func gotItTapped(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
