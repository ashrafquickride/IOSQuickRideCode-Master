//
//  QuickridePledgeViewController.swift
//  Quickride
//
//  Created by Admin on 11/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class QuickridePledgeViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var pledgeTableView: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    
    //MARK: Properties
    private var quickridePledgeViewModel: QuickridePledgeViewModel?
    
    //MARK: ViewModelInitializer
    func initializeDataBeforePresenting(titles: [String], messages: [String], images: [UIImage], actionName: String, heading: String?, handler: actionCompletionHandler?) {
        quickridePledgeViewModel = QuickridePledgeViewModel(titles: titles, messages: messages, images: images, actionName: actionName, heading: heading, handler: handler)
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
     }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        pledgeTableView.isScrollEnabled = pledgeTableView.contentSize.height > pledgeTableView.frame.size.height
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    //MARK: Methods
    func setupUI(){
        headerLabel.text = quickridePledgeViewModel?.heading
        actionButton.setTitle(quickridePledgeViewModel?.actionName, for: .normal)
        pledgeTableView.register(UINib(nibName: "QuickRidePledgeTableViewCell", bundle: nil), forCellReuseIdentifier: "QuickRidePledgeTableViewCell")
        pledgeTableView.estimatedRowHeight = pledgeTableView.bounds.height/3
        pledgeTableView.rowHeight = UITableView.automaticDimension
        ViewCustomizationUtils.addCornerRadiusToView(view: headerView, cornerRadius: 3.0)
    }
    
    //MARK: Action
    @IBAction func agreeButtonClicked(_ sender: Any) {
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.QR_PLEDGE_AGREED, params: [
                                                    "UserId" : QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
        self.navigationController?.popViewController(animated: false)
        quickridePledgeViewModel?.handler?()
    }
}

//MARK: UITableView Methods
extension QuickridePledgeViewController : UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quickridePledgeViewModel!.titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuickRidePledgeTableViewCell", for: indexPath) as! QuickRidePledgeTableViewCell
        if quickridePledgeViewModel!.titles.endIndex <= indexPath.row || quickridePledgeViewModel!.images.endIndex <= indexPath.row || quickridePledgeViewModel!.messages.endIndex <= indexPath.row{
            return cell
        }
        cell.initializeViews(pledgeTitle: quickridePledgeViewModel!.titles[indexPath.row], pledgeImage: quickridePledgeViewModel!.images[indexPath.row], pledgeDetails: quickridePledgeViewModel!.messages[indexPath.row])
        if indexPath.row == 3{
            cell.separatorView.isHidden = true
        }else{
            cell.separatorView.isHidden = false
        }
        return cell
    }
}

