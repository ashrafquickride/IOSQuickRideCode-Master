//
//  RideNotesTableViewCell.swift
//  Quickride
//
//  Created by HK on 06/08/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RideNotesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addRideNotesView: UIView!
    @IBOutlet weak var editRideNotesVew: UIView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var rideNotesLabel: UILabel!
    
    private var isEditTapped = false
    func initialiseRideNotes(){
        guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences().copy() as? RidePreferences else {
            addRideNotesView.isHidden = false
            editRideNotesVew.isHidden = true
            return
        }
        notesTextView.delegate = self
        if isEditTapped{
            addRideNotesView.isHidden = false
            editRideNotesVew.isHidden = true
            rideNotesLabel.text = ridePreferences.rideNote
        }else{
            if let rideNote = ridePreferences.rideNote,!rideNote.isEmpty{
                addRideNotesView.isHidden = true
                editRideNotesVew.isHidden = false
                rideNotesLabel.text = rideNote
                notesTextView.textColor = .black
            }else{
                addRideNotesView.isHidden = false
                editRideNotesVew.isHidden = true
                notesTextView.text = Strings.type_your_message
                notesTextView.textColor = UIColor.black.withAlphaComponent(0.4)
            }
        }
    }
    
    @IBAction func rideNoteTapped(_ sender: Any) {
        isEditTapped = false
        if !notesTextView.text.isEmpty && notesTextView.text != Strings.type_your_message{
            updateRideNotes(rideNote: notesTextView.text)
        }
    }
    
    @IBAction func editRideNotesTapped(_ sender: Any) {
        addRideNotesView.isHidden = false
        editRideNotesVew.isHidden = true
        let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences().copy() as? RidePreferences
        notesTextView.text = ridePreferences?.rideNote
        isEditTapped = true
        NotificationCenter.default.post(name: .updateUiWithNewData, object: nil)
    }
    
    @IBAction func deleteRideNotesTapped(_ sender: Any) {
        updateRideNotes(rideNote: nil)
    }
    private func updateRideNotes(rideNote: String?){
        guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences() else { return }
        ridePreferences.rideNote = rideNote
        QuickRideProgressSpinner.startSpinner()
        SaveRidePreferencesTask(ridePreferences: ridePreferences, viewController: parentViewController, receiver: self).saveRidePreferences()
    }
}
extension RideNotesTableViewCell: SaveRidePreferencesReceiver {
    func ridePreferencesSaved() {
        QuickRideProgressSpinner.stopSpinner()
        NotificationCenter.default.post(name: .updateUiWithNewData, object: nil)
    }
    
    func ridePreferencesSavingFailed() {
        QuickRideProgressSpinner.stopSpinner()
    }
}
//MARK:UITextViewDelegate
extension RideNotesTableViewCell:UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        AppDelegate.getAppDelegate().log.debug("")
        if notesTextView.text == nil || notesTextView.text.isEmpty || notesTextView.text ==  Strings.type_your_message{
            notesTextView.text = ""
            notesTextView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if notesTextView.text.isEmpty{
            resignFirstResponder()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        notesTextView.endEditing(true)
        if notesTextView.text.isEmpty == true {
            notesTextView.text =  Strings.type_your_message
            notesTextView.textColor = UIColor.black.withAlphaComponent(0.4)
        }
    }
}
