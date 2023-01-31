//
//  DaysSelectionView.swift
//  Quickride
//
//  Created by Ashutos on 18/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol DaysSelectionViewDelegate: class {
    func recurringData(selectedDays: [Int])
}

class DaysSelectionView: UIView {
    @IBOutlet weak var daysCollectionView: UICollectionView!
    @IBOutlet var containerView: UIView!
    
    var dayList = [Strings.mon_short,Strings.tue_short,Strings.wed_short,Strings.thu_short,Strings.fri_short,Strings.sat_short,Strings.sun_short]
    var selectedDays = [0,1,2,3,4]
    weak var delegate: DaysSelectionViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.CommonFunc()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        CommonFunc()
    }
    
    private func CommonFunc(){
        Bundle.main.loadNibNamed("DaysSelectionView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth ,.flexibleHeight]
        daysCollectionView.register(UINib(nibName: "RecurringRideDaysCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecurringRideDaysCollectionViewCell")
    }
}

extension DaysSelectionView: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dayList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecurringRideDaysCollectionViewCell", for: indexPath) as! RecurringRideDaysCollectionViewCell
        cell.daysBtn.tag = indexPath.row
        cell.daysBtn.setTitle(dayList[indexPath.row], for: .normal)
        if selectedDays.contains(indexPath.row) {
            cell.daysBtn.setTitleColor(.white, for: .normal)
            cell.contentView.backgroundColor = UIColor(netHex: 0x595959)
        } else {
            cell.daysBtn.setTitleColor(UIColor.init(netHex: 0x9C9C9C), for: .normal)
             cell.contentView.backgroundColor = UIColor(netHex: 0xE2E6E4)
        }
        cell.daysBtn.addTarget(self, action: #selector(dayBtnTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc private func dayBtnTapped(_ sender: AnyObject) {
        let index = sender.tag
        if selectedDays.contains(index ?? 0) {
            let indexToRemove = selectedDays.index(of: index ?? 0)
            selectedDays.remove(at: indexToRemove!)
        } else {
            selectedDays.append(index ?? 0)
        }
        delegate?.recurringData(selectedDays: selectedDays)
        let indexPath = IndexPath(row: sender.tag, section: 0)
        daysCollectionView.reloadItems(at: [indexPath])
    }
}
extension DaysSelectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 35, height: 35)
    }
}
