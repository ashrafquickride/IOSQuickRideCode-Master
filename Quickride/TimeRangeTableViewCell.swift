//
//  TimeRangeTableViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 03/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol TimeRangeTableViewCellDelagate: class{
    func timeRangeSelected(time: String)
}

class TimeRangeTableViewCell: UITableViewCell {
    
    //MARK: Outlet
    @IBOutlet weak var timeRangeCollectionView: UICollectionView!
    
    //MARK:Variables
    weak var delegate: TimeRangeTableViewCellDelagate?
    private var selectedIndex = 0
    
    func prepareTimeRangeList(selectedTimeRange: String?){
        timeRangeCollectionView.delegate = self
        timeRangeCollectionView.dataSource = self
        if let index = DynamicFiltersCache.timeRangeList.index(of: selectedTimeRange ?? ""){
            selectedIndex = index
        }
    }
}

//MARK: UICollectionViewDataSource
extension TimeRangeTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DynamicFiltersCache.timeRangeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeRangeCollectionViewCell", for: indexPath) as! TimeRangeCollectionViewCell
        var isSelected = false
        if selectedIndex == indexPath.row{
            isSelected = true
        }
        var hideMinus = false
        if indexPath.row == DynamicFiltersCache.timeRangeList.count - 1 || indexPath.row == DynamicFiltersCache.timeRangeList.count - 2{
            hideMinus = true
        }
        cell.initializeCell(timeValue: DynamicFiltersCache.timeRangeList[indexPath.row],isSelected: isSelected, hideMinus: hideMinus)
        return cell
    }
}

//MARK: UICollectionViewDelegate
extension TimeRangeTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedView = collectionView.cellForItem(at: indexPath) as? TimeRangeCollectionViewCell{
            selectedView.timeTitleLabel.textColor = UIColor(netHex: 0x007AFF)
            ViewCustomizationUtils.addBorderToView(view: selectedView.outerView, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
            selectedView.plusIcon.textColor = UIColor(netHex: 0x007AFF)
            selectedView.minusIcon.textColor = UIColor(netHex: 0x007AFF)
        }
        if let prevSelectedView = collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? TimeRangeCollectionViewCell{
            if selectedIndex != indexPath.row{
                prevSelectedView.timeTitleLabel.textColor = UIColor.black.withAlphaComponent(0.6)
                ViewCustomizationUtils.addBorderToView(view: prevSelectedView.outerView, borderWidth: 1, color: UIColor(netHex: 0xf1f1f1))
                prevSelectedView.plusIcon.textColor = UIColor.black.withAlphaComponent(0.6)
                prevSelectedView.minusIcon.textColor = UIColor.black.withAlphaComponent(0.6)
            }
        }
        selectedIndex = indexPath.row
        delegate?.timeRangeSelected(time: DynamicFiltersCache.timeRangeList[selectedIndex])
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension TimeRangeTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = DynamicFiltersCache.timeRangeList[indexPath.item]
        label.sizeToFit()
        return CGSize(width: label.frame.size.width + 25, height: 30)
    }
}

