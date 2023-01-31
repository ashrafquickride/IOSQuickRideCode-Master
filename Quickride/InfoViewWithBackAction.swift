//
//  InfoViewWithBackAction.swift
//  Quickride
//
//  Created by Vinutha on 13/04/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias actionCompletionHandler = () -> Void

class InfoViewWithBackAction: ModelViewController {
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var labelHeading: UILabel!
    
    @IBOutlet weak var lableMessage: UILabel!
    
    var heading: String?
    var message: String?
    var handler: actionCompletionHandler?
    
    func initialiseView(heading: String, message: String, handler: @escaping actionCompletionHandler){
        self.heading = heading
        self.message = message
        self.handler = handler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1.4
        let attributedString1 = NSMutableAttributedString(string: message!)
        attributedString1.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString1.length))
        lableMessage.attributedText = attributedString1
        labelHeading.text = self.heading
    }
    
    @IBAction func backButtonClicked(_ sender: Any){
        self.view.removeFromSuperview()
        self.removeFromParent()
        handler!()
    }
    
}
