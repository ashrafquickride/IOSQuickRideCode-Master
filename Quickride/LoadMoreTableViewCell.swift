//
//  LoadMoreTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 22/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class LoadMoreTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var loadMoreButton: UIButton!
    @IBOutlet weak var loadingResults: UILabel!
    @IBOutlet weak var weShownBestMathesLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    func inisalizeLoadMoreView(isLoadMoreTapped: Bool){
        if isLoadMoreTapped{
            loadingIndicator.isHidden = false
            loadingResults.isHidden = false
            weShownBestMathesLabel.isHidden = true
            loadingIndicator.startAnimating()
            loadMoreButton.isHidden = true
        }else{
            loadingResults.isHidden = true
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
            loadMoreButton.isHidden = false
            weShownBestMathesLabel.isHidden = false
        }
    }
    
    @IBAction func loadMoreTapped(_ sender: Any){
        NotificationCenter.default.post(name: .loadMore, object: nil)
    }
}
