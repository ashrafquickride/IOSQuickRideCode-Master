//
//  NumberOfSeatsSelector.swift
//  Quickride
//
//  Created by Halesh on 22/04/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import BottomPopup
typealias seatsSelectionCompletionHandler = (_ seats : Int) -> Void

class SeatsSelectionViewController: BottomPopupViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var seatsIcon: UIImageView!
    
    @IBOutlet weak var seatSelectionView: UIView!
    
    @IBOutlet weak var seatSelectionCollectionView: UICollectionView!
    
    var handler : seatsSelectionCompletionHandler?
    var noOfSeatSelected : Int?
    
    func initializeDataBeforePresenting(handler : seatsSelectionCompletionHandler?, seatsSelected: Int ){
        self.handler = handler
        self.noOfSeatSelected = seatsSelected
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seatSelectionCollectionView.delegate = self
        seatSelectionCollectionView.dataSource = self
        seatSelectionCollectionView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        ViewCustomizationUtils.addCornerRadiusToView(view: seatSelectionView, cornerRadius: 20.0)
        updatePopupHeight(to: 420)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SeatSelectionCollectionViewCell
        cell.seatButton.setTitle(String(indexPath.row + 1), for: .normal)
        cell.seatButton.setTitleColor(UIColor.black, for: .normal)
        ViewCustomizationUtils.addBorderToView(view: cell.seatButton, borderWidth: 1, color: UIColor.gray)
        ViewCustomizationUtils.addCornerRadiusToView(view: cell.seatButton, cornerRadius: 5.0)
        if noOfSeatSelected == indexPath.row + 1{
            ChangeCarIconDependingOnSeats(seats: noOfSeatSelected!)
            cell.seatButton.backgroundColor = UIColor.gray
            cell.seatButton.setTitleColor(UIColor.white, for: .normal)
        }else{
            cell.seatButton.backgroundColor = UIColor.white
            cell.seatButton.setTitleColor(UIColor.black, for: .normal)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let selectedView = collectionView.cellForItem(at: indexPath) as? SeatSelectionCollectionViewCell{
            selectedView.seatButton.backgroundColor = UIColor.gray
            selectedView.seatButton.setTitleColor(UIColor.white, for: .normal)
        }
        if let prevSelectedView = collectionView.cellForItem(at: IndexPath(item: noOfSeatSelected!-1, section: 0)) as? SeatSelectionCollectionViewCell{
            prevSelectedView.seatButton.backgroundColor = UIColor.white
            prevSelectedView.seatButton.setTitleColor(UIColor.black, for: .normal)
        }
        noOfSeatSelected = indexPath.row + 1
        ChangeCarIconDependingOnSeats(seats: noOfSeatSelected!)
    }
    func ChangeCarIconDependingOnSeats(seats: Int){
        switch seats {
        case 1:
            seatsIcon.image = UIImage(named: "one_seat")
        case 2:
            seatsIcon.image = UIImage(named: "two_seat")
        case 3:
            seatsIcon.image = UIImage(named: "three_seat")
        case 4:
            seatsIcon.image = UIImage(named: "four_seat")
        case 5:
            seatsIcon.image = UIImage(named: "five_seat")
        default:
            seatsIcon.image = UIImage(named: "one_seat")
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 10) / 3, height: (collectionView.bounds.width - 10) / 2)
    }
    @IBAction func confirmButtonTapped(_ sender: Any) {
        handler!(noOfSeatSelected!)
        self.view.removeFromSuperview()
        self.removeFromParent()
        self.dismiss(animated: true)
    }
}
