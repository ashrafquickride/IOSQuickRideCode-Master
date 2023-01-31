//
//  ShowTermsAndConditionsViewController.swift
//  Quickride
//
//  Created by Admin on 14/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ShowTermsAndConditionsViewController : UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var termsAndConditionTableView: UITableView!
    
    @IBOutlet weak var detailsView: UIView!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var detailsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    var termsAndConditions = [String]()
    var titleString = ""
    
    func initializeDataBeforePresenting(termsAndConditions : [String],titleString: String){
        self.termsAndConditions = termsAndConditions
        self.titleString = titleString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        termsAndConditionTableView.allowsSelection = false
        termsAndConditionTableView.estimatedRowHeight = 40.0
        termsAndConditionTableView.rowHeight = UITableView.automaticDimension
        termsAndConditionTableView.delegate = self
        termsAndConditionTableView.dataSource = self
        titleLabel.text = titleString
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: {
                        self.detailsView.frame = CGRect(x: 0, y: -300, width: self.detailsView.frame.width, height: self.detailsView.frame.height)
                        self.detailsView.layoutIfNeeded()
        }, completion: nil)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShowTermsAndConditionsViewController.backgroundViewTapped(_:))))
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ShowTermsAndConditionsViewController.swiped(_:)))
        swipeUp.direction = .up
        detailsView.addGestureRecognizer(swipeUp)
    }
    
    override func viewDidLayoutSubviews() {
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: detailsView, cornerRadius: 20.0, corner1: .topLeft, corner2: .topRight)
    }
    
    @IBAction func closeBtnClicked(_ sender: Any) {
      closeView()
    }
   @objc func backgroundViewTapped(_ gesture : UITapGestureRecognizer){
       closeView()
    }
    
    func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {
            self.detailsView.center.y += self.detailsView.bounds.height
            self.detailsView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return termsAndConditions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RideAssuredIncentiveTermsAndConditionTableViewCell
        cell.initializeViews(termsAndConditions: self.termsAndConditions, row: indexPath.row)
        return cell
    }
    
    @objc func swiped(_ gesture : UISwipeGestureRecognizer){
        UIView.animate(withDuration: 0.5, animations: {
            self.detailsViewHeightConstraint.constant = self.view.frame.height - 70
            self.view.layoutIfNeeded()
            self.termsAndConditionTableView.isScrollEnabled = true
           
        })
         self.cancelButton.isHidden = false
    }
    
    
    
}
