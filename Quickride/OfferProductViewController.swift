//
//  OfferProductViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 02/02/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class OfferProductViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var productsTableView: UITableView!
    @IBOutlet weak var doneButton: QRCustomButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    private var offerProductViewModel = OfferProductViewModel()
    
    func initialiseMyPostedProducts(requetedUserId: Int,requestId: String,categoryType: CategoryType,myPostedProducts: [PostedProduct]){
        offerProductViewModel = OfferProductViewModel(requetedUserId: requetedUserId,requestId: requestId,categoryType: categoryType,myPostedProducts: myPostedProducts)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        productsTableView.register(UINib(nibName: "OfferProductTableViewCell", bundle: nil), forCellReuseIdentifier: "OfferProductTableViewCell")
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        tableViewHeightConstraint.constant = CGFloat(offerProductViewModel.myPostedProducts.count * 130)
        productsTableView.reloadData()
    }
    
    private func animateView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        confirmNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: Notifications
    private func confirmNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(notifiedToUserRequestedUser), name: .notifiedToUserRequestedUser ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: nil)
    }
    
    @objc func notifiedToUserRequestedUser(_ notification: Notification){
        closeView()
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        QuickShareSpinner.stop()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if offerProductViewModel.selectedIndex != -1{
            offerProductViewModel.offerYourPostedProductToRequestedUser()
        }
    }
    
    @IBAction func addNewButtonTapped(_ sender: Any) {
        let addProductStepsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProductStepsViewController") as! AddProductStepsViewController
        addProductStepsViewController.initialiseAddingProductSteps(productType: offerProductViewModel.categoryType.displayName ?? "", isFromEditDetails: false, product: nil,categoryCode: offerProductViewModel.categoryType.code ?? "", requestId: offerProductViewModel.requestId, covidHome: offerProductViewModel.categoryType.categoryType == CategoryType.CATEGORY_TYPE_MEDICAL)
        self.navigationController?.pushViewController(addProductStepsViewController, animated: true)
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
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
}
//MARK: UITableViewDataSource
extension OfferProductViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offerProductViewModel.myPostedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfferProductTableViewCell", for: indexPath) as! OfferProductTableViewCell
        if offerProductViewModel.myPostedProducts.endIndex <= indexPath.row{
            return cell
        }
        cell.initialisePostedProductView(postedProduct: offerProductViewModel.myPostedProducts[indexPath.row])
        return cell
    }
}
//MARK: UITableViewDelegate
extension OfferProductViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCell = tableView.cellForRow(at: indexPath) as? OfferProductTableViewCell{
            selectedCell.radioButttonImage.image = UIImage(named: "ic_radio_button_checked")
        }
        if let prevSelectedCell = tableView.cellForRow(at: IndexPath(item: offerProductViewModel.selectedIndex, section: 0))as? OfferProductTableViewCell{
            if offerProductViewModel.selectedIndex != indexPath.row{
                prevSelectedCell.radioButttonImage.image = UIImage(named: "radio_button_1")
            }
        }
        doneButton.backgroundColor = Colors.green
        offerProductViewModel.selectedIndex = indexPath.row
    }
}
