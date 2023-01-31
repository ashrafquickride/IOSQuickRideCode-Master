//
//  AddProductStepsViewController.swift
//  Quickride
//
//  Created by Halesh on 24/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddProductStepsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var stepsTableView: UITableView!
    @IBOutlet weak var continueAndSubmitButton: UIButton!
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var headerLabel: QRHeaderLabel!
    
    //MARK: Variables
    private var addProductStepsViewModel = AddProductStepsViewModel()
    
    func initialiseAddingProductSteps(productType: String,isFromEditDetails: Bool, product: Product?,categoryCode: String,requestId: String?,covidHome : Bool){
        addProductStepsViewModel = AddProductStepsViewModel(productType: productType,isFromEditDetails: isFromEditDetails,product: product,categoryCode: categoryCode,requestId: requestId,covidHome : covidHome)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
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
        headerLabel.text = addProductStepsViewModel.productType
        continueAndSubmitButton.setTitle(Strings.continue_text_caps, for: .normal)
        stepsTableView.register(UINib(nibName: "StepProgressTableViewCell", bundle: nil), forCellReuseIdentifier: "StepProgressTableViewCell")
        stepsTableView.register(UINib(nibName: "AddPhotosTableViewCell", bundle: nil), forCellReuseIdentifier: "AddPhotosTableViewCell")
        stepsTableView.register(UINib(nibName: "AddProductDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "AddProductDetailTableViewCell")
        stepsTableView.register(UINib(nibName: "ProductPriceTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductPriceTableViewCell")
        stepsTableView.register(UINib(nibName: "AddCovidItemTableViewCell", bundle: nil), forCellReuseIdentifier: "AddCovidItemTableViewCell")
    }
    //MARK: Notifications
    private func confirmNotifiaction(){
        NotificationCenter.default.addObserver(self, selector: #selector(changeButtonColorIfAllFieldsFilled(_:)), name: .changeButtonColorIfAllFieldsFilled ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationSelected), name: .locationSelected ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productAddedSuccessfully), name: .productAddedSuccessfully ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productDetailsAddedOrChanged), name: .productDetailsAddedOrChanged ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productUpdatedSuccessfully), name: .productUpdatedSuccessfully ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAddedProductPicture), name: .removeAddedProductPicture ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAddedProductPicture), name: .removeAddedProductPicture ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productTitleAdded), name: .productTitleAdded ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productPriceAddedOrChanged), name: .productPriceAddedOrChanged ,object: nil)
    }
    @objc func productPriceAddedOrChanged(_ notification: Notification){
        addProductStepsViewModel.product = notification.userInfo?["product"] as? Product ?? Product()
        handleSignUpBtnColorChange()
    }
    @objc func productTitleAdded(_ notification: Notification){
        addProductStepsViewModel.product.title = notification.userInfo?["productTitle"] as? String
        handleSignUpBtnColorChange()
    }
    
    @objc func removeAddedProductPicture(_ notification: Notification){
        let index = notification.userInfo?["index"] as? Int ?? 0
        removeImageFromList(index: index)
    }
    
    private func removeImageFromList(index: Int){
        if index < addProductStepsViewModel.imageList.count {
           addProductStepsViewModel.imageList.remove(at: index)
        }
        if index < addProductStepsViewModel.productPhotos.count{
            addProductStepsViewModel.productPhotos.remove(at: index)
        }
        stepsTableView.reloadData()
    }
    
    @objc func changeButtonColorIfAllFieldsFilled(_ notification: Notification){
        handleSignUpBtnColorChange()
    }
    @objc func locationSelected(_ notification: Notification){
        addProductStepsViewModel.product = notification.userInfo?["product"] as? Product ?? Product()
        handleSignUpBtnColorChange()
    }
    @objc func productDetailsAddedOrChanged(_ notification: Notification){
        let product = notification.userInfo?["product"] as? Product ?? Product()
        addProductStepsViewModel.product.tradeType = product.tradeType
        addProductStepsViewModel.product.condition = product.condition
        addProductStepsViewModel.product.manufacturedDate = product.manufacturedDate
        addProductStepsViewModel.product.description = product.description
        handleSignUpBtnColorChange() 
    }
    @objc func handleApiFailureError(_ notification: Notification){
        QuickShareSpinner.stop()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @objc func productAddedSuccessfully(_ notification: Notification){
        QuickShareSpinner.stop()
        guard let postedProduct = addProductStepsViewModel.postedProduct else { return }
        let addProductSuccessViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProductSuccessViewController") as! AddProductSuccessViewController
        addProductSuccessViewController.initailseSuccesView(postedProduct: postedProduct, product: addProductStepsViewModel.product,covidCareHome : addProductStepsViewModel.covidHome)
        self.navigationController?.pushViewController(addProductSuccessViewController, animated: true)
    }
    
    @objc func productUpdatedSuccessfully(_ notification: Notification){
        QuickShareSpinner.stop()
        guard let postedProduct = addProductStepsViewModel.postedProduct else { return }
        let addProductSuccessViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProductSuccessViewController") as! AddProductSuccessViewController
        addProductSuccessViewController.initailseSuccesView(postedProduct: postedProduct, product: addProductStepsViewModel.product,covidCareHome: addProductStepsViewModel.covidHome)
        self.navigationController?.pushViewController(addProductSuccessViewController, animated: true)
    }
    
    private func handleSignUpBtnColorChange() {
        if addProductStepsViewModel.checkRequiredFieldsfilledOrNot(){
            CustomExtensionUtility.changeBtnColor(sender: continueAndSubmitButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        }else{
            CustomExtensionUtility.changeBtnColor(sender: continueAndSubmitButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
        }
    }
    
    @IBAction func continuButtonTapped(_ sender: UIButton) {
        if addProductStepsViewModel.imageList.isEmpty{
            UIApplication.shared.keyWindow?.makeToast(Strings.please_add_photo)
            return
        }
        if addProductStepsViewModel.step == 1 && addProductStepsViewModel.checkRequiredFieldsfilledOrNot(){
            addProductStepsViewModel.step = 2
            continueAndSubmitButton.setTitle(Strings.submit.uppercased(), for: .normal)
            handleSignUpBtnColorChange()
            stepsTableView.reloadData()
            addProductStepsViewModel.prepareImageList()
        }else if addProductStepsViewModel.step == 2  && addProductStepsViewModel.checkRequiredFieldsfilledOrNot(){
            if addProductStepsViewModel.isFromEditDetails{
                QuickShareSpinner.start()
                addProductStepsViewModel.updateAddedProduct()
            }else{
                QuickShareSpinner.start()
                addProductStepsViewModel.sumbitAddedProduct()
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        if addProductStepsViewModel.step == 1{
            self.navigationController?.popViewController(animated: true)
        }else{
            addProductStepsViewModel.step = 1
            self.view.endEditing(true)
            continueAndSubmitButton.setTitle(Strings.continue_text.uppercased(), for: .normal)
            stepsTableView.reloadData()
        }
    }
    
}
//MARK:UITableViewDataSource
extension AddProductStepsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if addProductStepsViewModel.step == 1{
            return 3
        }else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if addProductStepsViewModel.step == 1{
            if section == 0{
                return 1
            }else if section == 1{
                return 1
            }else{
                return 1
            }
        }else{
            if section == 0{
                return 1
            }else if section == 1{
                return 1
            }else{
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if addProductStepsViewModel.step == 1{
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "StepProgressTableViewCell", for: indexPath) as! StepProgressTableViewCell
                cell.initialiseStepProgress(step: addProductStepsViewModel.step)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddPhotosTableViewCell", for: indexPath) as! AddPhotosTableViewCell
                cell.initialisePhotos(product: addProductStepsViewModel.product, videoFileName: nil, photos: addProductStepsViewModel.productPhotos, delagate: self)
                return cell
            case 2:
                if addProductStepsViewModel.covidHome {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AddCovidItemTableViewCell", for: indexPath) as! AddCovidItemTableViewCell
                    cell.initialiseProductDetails(product: addProductStepsViewModel.product)
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AddProductDetailTableViewCell", for: indexPath) as! AddProductDetailTableViewCell
                    cell.initialiseProductDetails(product: addProductStepsViewModel.product)
                    return cell
                }
            default:
                break
            }
        }else{
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "StepProgressTableViewCell", for: indexPath) as! StepProgressTableViewCell
                cell.initialiseStepProgress(step: addProductStepsViewModel.step)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProductPriceTableViewCell", for: indexPath) as! ProductPriceTableViewCell
                cell.initialiseView(product: addProductStepsViewModel.product)
                return cell
            default:
                break
            }
        }
        return UITableViewCell()
    }
}
//MARK: AddPhotosTableViewCellDelegate
extension AddProductStepsViewController: AddPhotosTableViewCellDelegate{
    func productVideo(videoFile: String?) {
        
    }
    
    func addedProductPictures(pictures: [UIImage],upadtedPhoto: UIImage?,index: Int) {
        addProductStepsViewModel.productPhotos = pictures
        stepsTableView.reloadData()
        if let photo = upadtedPhoto{
            ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: photo), targetViewController: self, completionHandler: {(responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                    let imageUrl = responseObject!["resultData"] as? String
                    self.addProductStepsViewModel.imageList.append(imageUrl?.trimmingCharacters(in: .whitespaces) ?? "")
                    self.handleSignUpBtnColorChange()
                }
            })
        }else{
            self.removeImageFromList(index: index)
        }
    }
}
