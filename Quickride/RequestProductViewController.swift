//
//  RequestProductViewController.swift
//  Quickride
//
//  Created by Halesh on 15/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RequestProductViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var tradetypeLabel: QRHeaderLabel!
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var requestDetailsTableView: UITableView!
    @IBOutlet weak var postButton: UIButton!
    
    //MARK: Variables
    private var requestProductViewModel = RequestProductViewModel()
    
    func initialiseRequestView(productType: String,categoryCode: String,requestProduct: RequestProduct?,isFromCovid: Bool){
        requestProductViewModel = RequestProductViewModel(productType: productType,categoryCode: categoryCode,requestProduct: requestProduct,isFromCovid: isFromCovid)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        confirmNotifiaction()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func prepareUI(){
        requestDetailsTableView.register(UINib(nibName: "StepProgressTableViewCell", bundle: nil), forCellReuseIdentifier: "StepProgressTableViewCell")
        requestDetailsTableView.register(UINib(nibName: "AddRequirementTableViewCell", bundle: nil), forCellReuseIdentifier: "AddRequirementTableViewCell")
        requestDetailsTableView.register(UINib(nibName: "addRequirementDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "addRequirementDetailsTableViewCell")
        requestDetailsTableView.register(UINib(nibName: "PriceAndLoactionSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "PriceAndLoactionSelectionTableViewCell")
        requestDetailsTableView.reloadData()
        tradetypeLabel.text = requestProductViewModel.productType
        requestProductViewModel.requestProduct.categoryCode = requestProductViewModel.categoryCode
        if requestProductViewModel.requestProduct.requestLocationInfo == nil{
            requestProductViewModel.requestProduct.requestLocationInfo = ProductLocation(location: QuickShareCache.getInstance()?.getUserLocation() ?? Location())
        }
    }
    
    //MARK: Notifications
    private func confirmNotifiaction(){
        NotificationCenter.default.addObserver(self, selector: #selector(changeButtonColorIfAllFieldsFilled(_:)), name: .changeButtonColorIfAllFieldsFilled ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productDetailsAddedOrChanged), name: .productDetailsAddedOrChanged ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationSelected), name: .locationSelected ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productRequestedSuccessfully), name: .productRequestedSuccessfully ,object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(requestingTradeType), name: .requestingTradeType ,object: nil)
    }
    
    @objc func changeButtonColorIfAllFieldsFilled(_ notification: Notification){
        handleSignUpBtnColorChange()
    }
    
    @objc func locationSelected(_ notification: Notification){
        let requestLocationInfo = notification.userInfo?["requestLocationInfo"] as? ProductLocation
        requestProductViewModel.requestProduct.requestLocationInfo = requestLocationInfo
        handleSignUpBtnColorChange()
    }
    @objc func productDetailsAddedOrChanged(_ notification: Notification){
        let requestProduct = notification.userInfo?["requestProduct"] as? RequestProduct ?? RequestProduct()
        requestProductViewModel.requestProduct.title = requestProduct.title
        requestProductViewModel.requestProduct.description = requestProduct.description
        handleSignUpBtnColorChange()
    }
    
    @objc func requestingTradeType(_ notification: Notification){
        requestProductViewModel.requestProduct.tradeType = notification.userInfo?["requestingTradeType"] as? String
        handleSignUpBtnColorChange()
    }
    @objc func productRequestedSuccessfully(_ notification: Notification){
        QuickShareSpinner.stop()
        guard let postedRequest = requestProductViewModel.postedRequest else { return }
        let requestProductSuccessViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RequestProductSuccessViewController") as! RequestProductSuccessViewController
        requestProductSuccessViewController.initailseSuccesView(postedRequest: postedRequest, requestProduct: requestProductViewModel.requestProduct, covidHome: requestProductViewModel.isFromCovid)
        self.navigationController?.pushViewController(requestProductSuccessViewController, animated: true)
    }
    @objc func handleApiFailureError(_ notification: Notification){
        QuickShareSpinner.stop()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    private func handleSignUpBtnColorChange() {
        if requestProductViewModel.checkRequiredFieldsfilledOrNot(){
            CustomExtensionUtility.changeBtnColor(sender: postButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            postButton.isUserInteractionEnabled = true
        }else{
            CustomExtensionUtility.changeBtnColor(sender: postButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
            postButton.isUserInteractionEnabled = false
        }
    }
    
    //Actions
    @IBAction func continuButtonTapped(_ sender: UIButton) {
        if requestProductViewModel.checkRequiredFieldsfilledOrNot(){
            QuickShareSpinner.start()
            requestProductViewModel.requestPreparedProduct()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK:UITableViewDataSource
extension RequestProductViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
            return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddRequirementTableViewCell", for: indexPath) as! AddRequirementTableViewCell
            cell.initialiseView(requestProduct: requestProductViewModel.requestProduct,isFromCovid: requestProductViewModel.isFromCovid) 
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addRequirementDetailsTableViewCell", for: indexPath) as! addRequirementDetailsTableViewCell
            cell.initialiseView(requestProduct: requestProductViewModel.requestProduct)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PriceAndLoactionSelectionTableViewCell", for: indexPath) as! PriceAndLoactionSelectionTableViewCell
            cell.initialiseView(requestProduct: requestProductViewModel.requestProduct)
            return cell
        default:
            return UITableViewCell()
        }
    }
}
