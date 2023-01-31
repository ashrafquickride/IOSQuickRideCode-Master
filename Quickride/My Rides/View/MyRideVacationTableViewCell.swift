//
//  MyRideVacationTableViewCell.swift
//  Quickride
//
//  Created by Quick Ride on 5/3/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias resultHandler = () -> Void

class MyRideVacationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var vacationFromLabel: UILabel!
    
    @IBOutlet weak var vacationToLabel: UILabel!
    
    @IBOutlet weak var vacationFromAndToIV: UIImageView!
    
    @IBOutlet weak var endVacationView: UIView!
    
    
    
    @IBAction func endVacationAction(_ sender: Any) {
        guard let userVacation = vacation else { return  }
        userVacation.fromDate = nil
        userVacation.toDate = nil
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.updateUserVacation(userVacation: userVacation, viewController: nil, responseHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            let result = RestResponseParser<UserVacation>().parse(responseObject: responseObject, error: error)
            if let updated = result.0 {
                UserDataCache.getInstance()!.storeUserVacation(userVacation: updated)
                UIApplication.shared.keyWindow?.makeToast( Strings.vacation_ended)
                self.hanlder?()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
            
        })
        
    }
    
    var vacation: UserVacation?
    var hanlder: resultHandler?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setUpUI(vacation: UserVacation, hanlder: @escaping resultHandler) {
        self.vacation = vacation
        self.hanlder = hanlder
        ViewCustomizationUtils.addCornerRadiusToView(view: endVacationView, cornerRadius: 15)
        endVacationView.addShadow()
        
        if let fromDate = vacation.fromDate{
            vacationFromLabel.isHidden = false
            vacationFromLabel.text = DateUtils.getDateStringFromNSDate(date: NSDate(timeIntervalSince1970: fromDate/1000), dateFormat: DateUtils.DATE_FORMAT_dd_MMM)
        }else{
            vacationFromLabel.isHidden = true
        }
        if let toDate = vacation.toDate{
            vacationFromLabel.isHidden = false
            vacationToLabel.text = DateUtils.getDateStringFromNSDate(date: NSDate(timeIntervalSince1970: toDate/1000), dateFormat: DateUtils.DATE_FORMAT_dd_MMM)
        }else{
            vacationToLabel.isHidden = true
        }
        vacationFromAndToIV.isHidden =  vacation.fromDate == nil || vacation.toDate == nil ? true : false
        
    }
    
}
