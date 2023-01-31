//
//  EcoCategoryLevelInfoViewController.swift
//  Quickride
//
//  Created by Admin on 26/12/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class EcoCategoryLevelInfoViewController : UIViewController{
    

    @IBOutlet weak var currentCategortTitle: UILabel!
    @IBOutlet weak var categoryContent: UILabel!
    @IBOutlet weak var nextCategoryTitle: UILabel!
    
    @IBOutlet weak var categoryLevelImageView: UIImageView!
    
    @IBOutlet weak var nxtlvlTextlbl: UILabel!
    
    @IBOutlet weak var categoryLvlBanyanImageview: UIImageView!
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    var category : String?
    
    func initializeDataBeforePresenting(category : String){
        self.category = category
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleAndContentBasedOnCategory()
        setAttributedTextToCategoryContent()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func setTitleAndContentBasedOnCategory(){
        if self.category == RideSharingCommunityContribution.USER_CATEGORY_SILVER{
            
            self.currentCategortTitle.text = Strings.category_title_bamboo
            self.nextCategoryTitle.text = Strings.category_title_bonsai
            self.categoryContent.text = Strings.category_content_bamboo
            self.nextCategoryTitle.isHidden = false
            categoryLevelImageView.isHidden = false
            self.categoryLevelImageView.image = UIImage(named: "bamboo")
            categoryLvlBanyanImageview.isHidden = true
            nxtlvlTextlbl.isHidden = false
        }else if self.category == RideSharingCommunityContribution.USER_CATEGORY_GOLD{
           
            self.currentCategortTitle.text = Strings.category_title_bonsai
            self.nextCategoryTitle.text = Strings.category_title_ashoka
            self.categoryContent.text = Strings.category_content_bonsai
            self.nextCategoryTitle.isHidden = false
            categoryLevelImageView.isHidden = false
            self.categoryLevelImageView.image = UIImage(named: "bonsai")
            categoryLvlBanyanImageview.isHidden = true
             nxtlvlTextlbl.isHidden = false
        }else if self.category == RideSharingCommunityContribution.USER_CATEGORY_DIAMOND{
           
            self.currentCategortTitle.text = Strings.category_title_ashoka
            self.nextCategoryTitle.text = Strings.category_title_banyan
            self.categoryContent.text = Strings.category_content_ashoka
            self.nextCategoryTitle.isHidden = false
            categoryLevelImageView.isHidden = false
            self.categoryLevelImageView.image = UIImage(named: "ashoka")
            categoryLvlBanyanImageview.isHidden = true
             nxtlvlTextlbl.isHidden = false
        }else{
            
            self.currentCategortTitle.text = Strings.category_title_banyan
            self.categoryContent.text = Strings.category_content_banyan
            self.nextCategoryTitle.isHidden = true
            categoryLevelImageView.isHidden = true
            categoryLvlBanyanImageview.isHidden = false
            categoryLvlBanyanImageview.image = UIImage(named: "banyan")
             nxtlvlTextlbl.isHidden = true
            
        }
        
        
    }
    
    func setAttributedTextToCategoryContent(){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1.4
        
        let attributedString = NSMutableAttributedString(string: self.categoryContent.text!)
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x000000), textSize: 14.0), range: NSMakeRange(0, attributedString.length))
        
        categoryContent.attributedText = attributedString
    }



    @IBAction func closeBtnClicked(_ sender: Any) {
    
        ViewControllerUtils.finishViewController(viewController: self)
    
    }
    






}
