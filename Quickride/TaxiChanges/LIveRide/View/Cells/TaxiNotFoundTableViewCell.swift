//
//  TaxiNotFoundTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 30/06/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias UpdateTaxiCellCompletionHandler = (_ updateUi :Bool) -> ()

class TaxiNotFoundTableViewCell: UITableViewCell {
    var viewModel: TaxiPoolLiveRideViewModel?
    var isFromRental: Bool?
        var completionHandler: UpdateTaxiCellCompletionHandler?

    @IBOutlet weak var retryBtn: UIButton!

    func initialiseView(viewModel: TaxiPoolLiveRideViewModel, updatetaxiCellCompletionHandler: @escaping UpdateTaxiCellCompletionHandler) {
        self.viewModel = viewModel
      self.completionHandler = updatetaxiCellCompletionHandler
    }



    @IBAction func retryBtnTapped(_ sender: Any) {
        self.completionHandler!(true)
    }





}
