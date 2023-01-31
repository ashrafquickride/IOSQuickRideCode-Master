//
//  TaxiDetailsCardTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 17/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiDetailsCardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardView: QuickRideCardView!
    @IBOutlet weak var carTypeImageView: UIImageView!
    @IBOutlet weak var carTypeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var discountPriceLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dicountImage: UIImageView!
    
    @IBOutlet weak var maximumFareView: UIView!
    @IBOutlet weak var newlabel: UILabel!
    @IBOutlet weak var maxFareTextLabel: UILabel!
    @IBOutlet weak var maximumFareViewHeightConstaraint: NSLayoutConstraint!
    @IBOutlet weak var maximumFareLabel: UILabel!
    @IBOutlet weak var setMaximumFareButton: UIButton!
    @IBOutlet weak var carModelNameLabel: UILabel!
    
    private var fareForVehicle: FareForVehicleClass?
    private var discountAmount = 0.0
    override func prepareForReuse() {
        fareForVehicle = nil
    }
    
    func setUpUI(fareForVehicle: FareForVehicleClass?,isSelectedIndex: Bool,discountAmount: Double) {
        if let fareForVehicle = fareForVehicle {
            self.fareForVehicle = fareForVehicle
            self.discountAmount = discountAmount
            let resources = getResourcesForVehicle(fareForVehicleClass: fareForVehicle)
            carTypeImageView.image = resources.0
//            subtitleLabel.text = resources.1
            carTypeLabel.text = resources.2
            if fareForVehicle.minTotalFare == fareForVehicle.maxTotalFare  {
                let amount = (fareForVehicle.minTotalFare ?? 0) - discountAmount
                priceLabel.text = "₹\(Int(amount))"
                setMaxiMumFareView(maxFare: fareForVehicle.selectedMaxFare, isMaxIsEnable: false,isSelectedIndex: isSelectedIndex)
                showDiscountedPrice(amount: Int(fareForVehicle.minTotalFare ?? 0))
            }else{
                let minmumFare = (fareForVehicle.minTotalFare ?? 0) - discountAmount
                let maximumFare = (fareForVehicle.maxTotalFare ?? 0) - discountAmount
                priceLabel.text = "₹\(Int(minmumFare)) - ₹\(Int(maximumFare))"
                if fareForVehicle.shareType == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE {
                    setMaxiMumFareView(maxFare: fareForVehicle.selectedMaxFare, isMaxIsEnable: true,isSelectedIndex: isSelectedIndex)
                }else{
                    setMaxiMumFareView(maxFare: 0, isMaxIsEnable: false,isSelectedIndex: isSelectedIndex)
                }
                showBothMinAndMaxDiscountedPrice(minAmount: Int(fareForVehicle.minTotalFare ?? 0), maxAmount: Int(fareForVehicle.maxTotalFare ?? 0))
            }
        }else{
            carTypeLabel.text = ""
            priceLabel.text = ""
            subtitleLabel.text  = ""
            infoButton.isHidden = true
            maximumFareView.isHidden = true
        }
        if let vehicleDescription = fareForVehicle?.vehicleDescription, !vehicleDescription.isEmpty {
            carModelNameLabel.isHidden = false
            carModelNameLabel.text = vehicleDescription
        } else {
            carModelNameLabel.isHidden = true
        }
    }
    func setupUI(taxiType: String?, pkgFare: String?,isSelectedIndex: Bool?) {
        if taxiType == TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SUV_LUXURY{
            carTypeLabel.text = "SUV Luxury"
        }else {
            carTypeLabel.text = taxiType
        }
        if let pkgFare = pkgFare{
            priceLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [pkgFare])
        }
        maximumFareView.isHidden = true
        infoButton.isHidden = true
        if isSelectedIndex ?? false {
            cardView.backgroundColor = UIColor(netHex: 0xf2f2f2)
        } else{
            cardView.backgroundColor = .white
        }
        setTaxiImage(taxiType: taxiType)
        carModelNameLabel.isHidden = true
    }
    private func showDiscountedPrice(amount: Int){
        if discountAmount != 0{
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "₹\(amount)")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            discountPriceLabel.attributedText = attributeString
            discountPriceLabel.isHidden = false
            dicountImage.isHidden = false
        }else{
            discountPriceLabel.isHidden = true
            dicountImage.isHidden = true
        }
    }
    
    private func showBothMinAndMaxDiscountedPrice(minAmount: Int,maxAmount: Int){
        if discountAmount != 0{
            discountPriceLabel.isHidden = false
            dicountImage.isHidden = false
            
            let string = ("₹\(minAmount)"+" - "+"₹\(maxAmount)") as NSString
            let attributedString = NSMutableAttributedString(string: string as String)
            
            attributedString.addAttribute(NSAttributedString.Key.baselineOffset, value: 0, range: string.range(of: "₹\(minAmount)"))
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeWithStrikeOff(textColor: UIColor.black.withAlphaComponent(0.5), textSize: 14), range: string.range(of: "₹\(minAmount)"))
            
            attributedString.addAttribute(NSAttributedString.Key.baselineOffset, value: 0, range: string.range(of: "₹\(maxAmount)"))
           attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeWithStrikeOff(textColor: UIColor.black.withAlphaComponent(0.5), textSize: 14), range: string.range(of: "₹\(maxAmount)"))
            discountPriceLabel.attributedText = attributedString
        }else{
            discountPriceLabel.isHidden = true
            dicountImage.isHidden = true
        }
    }
    
    func getResourcesForVehicle( fareForVehicleClass : FareForVehicleClass) -> (UIImage?, String?, String?) {
            if TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE != fareForVehicleClass.shareType {
                return (UIImage(named: "sharing"), fareForVehicleClass.vehicleDescription ?? Strings.economic_rides, Strings.sharing)
            } else if TaxiPoolConstants.TAXI_TYPE_AUTO == fareForVehicleClass.taxiType {
                return (UIImage(named: "auto"), "", fareForVehicleClass.vehicleClass)
            } else if TaxiPoolConstants.TAXI_TYPE_BIKE == fareForVehicleClass.taxiType {
                return (UIImage(named: "bike_taxi_pool"), "", fareForVehicleClass.vehicleClass)
            } else if TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_HATCH_BACK == fareForVehicleClass.vehicleClass {
                return (UIImage(named: "icon_hatchback"), fareForVehicleClass.vehicleDescription, fareForVehicleClass.vehicleClass)
            } else if TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SEDAN == fareForVehicleClass.vehicleClass {
                return (UIImage(named: "sedan_taxi"), fareForVehicleClass.vehicleDescription, fareForVehicleClass.vehicleClass)
            } else if TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SUV == fareForVehicleClass.vehicleClass {
                return (UIImage(named: "outstation_SUV"), fareForVehicleClass.vehicleDescription, fareForVehicleClass.vehicleClass)
            }else if TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_CROSS_OVER == fareForVehicleClass.vehicleClass {
                return (UIImage(named: "outstation_SUV"), fareForVehicleClass.vehicleDescription, fareForVehicleClass.vehicleClass)
            } else if TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_TT == fareForVehicleClass.vehicleClass {
                return (UIImage(named: "Tempo"), fareForVehicleClass.vehicleDescription, "Tempo")
            }else if TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SUV_LUXURY == fareForVehicleClass.vehicleClass{
                return (UIImage(named: "outstation_SUV"), fareForVehicleClass.vehicleDescription, "SUV LUXURY")
            } else {
                return (UIImage(named: "icon_hatchback"), fareForVehicleClass.vehicleDescription, fareForVehicleClass.vehicleClass)
            }
        }
    
    func setTaxiImage(taxiType: String?){
        if taxiType == TaxiPoolConstants.TAXI_TYPE_AUTO{
            carTypeImageView.image = UIImage(named: "auto")
        } else if taxiType == TaxiPoolConstants.TAXI_TYPE_BIKE {
            carTypeImageView.image = UIImage(named: "bike_taxi_pool")
        } else if taxiType == TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_HATCH_BACK {
            carTypeImageView.image = UIImage(named: "icon_hatchback")
        } else if taxiType == TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SEDAN {
            carTypeImageView.image = UIImage(named: "sedan_taxi")
        } else if taxiType == TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SUV {
            carTypeImageView.image = UIImage(named: "outstation_SUV")
        }else if taxiType == TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_CROSS_OVER  {
            carTypeImageView.image = UIImage(named: "outstation_SUV")
        } else if taxiType == TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_TT {
            carTypeImageView.image = UIImage(named: "Tempo")
        }else if taxiType == TaxiPoolConstants.TAXI_VEHICLE_CATEGORY_SUV_LUXURY {
            carTypeImageView.image = UIImage(named: "outstation_SUV")
        } else {
            carTypeImageView.image = UIImage(named: "icon_hatchback")
        }
    }
    
    private func setMaxiMumFareView(maxFare: Double?,isMaxIsEnable: Bool,isSelectedIndex: Bool) {
        if isSelectedIndex {
            if isMaxIsEnable {
                if let maxFare = maxFare {
                    newlabel.isHidden = true
                    maximumFareLabel.isHidden = false
                    maximumFareLabel.text = "₹\(StringUtils.getStringFromDouble(decimalNumber: maxFare))"
                    maxFareTextLabel.text = Strings.max_fare_taxi
                }else{
                    newlabel.isHidden = false
                    maximumFareLabel.isHidden = true
                    maxFareTextLabel.text = Strings.set_max_fare_taxi
                }
            }
            infoButton.isHidden = !isMaxIsEnable
            maximumFareView.isHidden = !isMaxIsEnable
            cardView.backgroundColor = UIColor(netHex: 0xf2f2f2)
            maximumFareView.backgroundColor = UIColor(netHex: 0xf2f2f2)
        }else{
            infoButton.isHidden = true
            maximumFareView.isHidden = true
            cardView.backgroundColor = .white
            maximumFareView.backgroundColor = .white
        }
    }
    
    private func setSelectedTaxiIndex(isSelectedIndex: Bool){
        
    }
    
    
    
    @IBAction func infoBtnPressed(_ sender: UIButton) {        
        MessageDisplay.displayInfoViewAlert(title: nil, titleColor: nil, message: Strings.taxi_info_message, infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps) {
        }
    }
    
    @IBAction func setMaxiMumFareButtonTapped(_ sender: UIButton) {
        guard let fareForVehicle = fareForVehicle else {return}
        let taxiMaxFareViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiMaxFareViewController") as! TaxiMaxFareViewController
        var selectedValue = fareForVehicle.maxTotalFare
        if let selectedFareValue = fareForVehicle.selectedMaxFare {
            selectedValue = selectedFareValue
        }
       
        taxiMaxFareViewController.prepareDataForUI(selectedValue: Int(selectedValue ?? 0), minValue: Int(fareForVehicle.minTotalFare ?? 0), maxValue: Int(fareForVehicle.maxTotalFare ?? 0)) { [weak self] (selectedFare) in
            self?.fareForVehicle?.selectedMaxFare = Double(selectedFare)
            self?.setUpUI(fareForVehicle: self?.fareForVehicle,isSelectedIndex: true,discountAmount: self?.discountAmount ?? 0)
        }
        parentViewController?.navigationController?.pushViewController(taxiMaxFareViewController, animated: false)
    }
}
