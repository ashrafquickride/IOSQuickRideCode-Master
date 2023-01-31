//
//  HobbiesAndSkillsViewController.swift
//  Quickride
//
//  Created by Vinutha on 30/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class HobbiesAndSkillsViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Properties
    private var hobbiesAndSkillsViewModel = HobbiesAndSkillsViewModel()
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        addObserver()
        hobbiesAndSkillsViewModel.getUserSkillsAndInterest()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Methods
    private func setupUI() {
        collectionView.allowsMultipleSelection = true
        collectionView.register(UINib(nibName: "HobbiesAndSkillsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HobbiesAndSkillsCollectionViewCell")
        collectionView.register(UINib(nibName: "HobbiesAndSkillsHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HobbiesAndSkillsHeaderCollectionReusableView")
        collectionView.register(UINib(nibName: "HobbiesAndSkillsFooterCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "HobbiesAndSkillsFooterCollectionReusableView")
    }
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .hobbiesAndSkillRetrieved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userProfileUpdated), name: .userProfileUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addHobbiesAndSkills(_:)), name: .addHobbiesAndSkillsTapped, object: nil)
    }

    @objc private func reloadData() {
        collectionView.reloadData()
    }
    
    @objc private func userProfileUpdated() {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc private func addHobbiesAndSkills(_ notification: Notification) {
        if let skillsOrHobbies = notification.userInfo?["skillsOrHobbies"] as? [Int:String] {
            hobbiesAndSkillsViewModel.updateSkillsAndHobbies(hobbyOrSkill: skillsOrHobbies)
            collectionView.reloadData()
        }
    }
    
    //MARK: Actions
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        hobbiesAndSkillsViewModel.updateUserProfile()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}
extension HobbiesAndSkillsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return hobbiesAndSkillsViewModel.defaultHobbiesList.count
        } else {
            return hobbiesAndSkillsViewModel.defaultSkillsList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HobbiesAndSkillsCollectionViewCell", for: indexPath) as! HobbiesAndSkillsCollectionViewCell
        if indexPath.section == 0 {
            if hobbiesAndSkillsViewModel.defaultHobbiesList.endIndex <= indexPath.row {
                return cell
            }
            cell.setupUI(hobbyOrSkill: hobbiesAndSkillsViewModel.defaultHobbiesList[indexPath.row], selectedHobbies: hobbiesAndSkillsViewModel.selectedHobbies, selectedSkills: hobbiesAndSkillsViewModel.selectedSkills, section: indexPath.section)
        } else {
            if hobbiesAndSkillsViewModel.defaultSkillsList.endIndex <= indexPath.row {
                return cell
            }
            cell.setupUI(hobbyOrSkill: hobbiesAndSkillsViewModel.defaultSkillsList[indexPath.row], selectedHobbies: hobbiesAndSkillsViewModel.selectedHobbies, selectedSkills: hobbiesAndSkillsViewModel.selectedSkills, section: indexPath.section)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: view.frame.size.width, height: 175)
        } else {
            return CGSize(width: view.frame.size.width, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 122)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HobbiesAndSkillsHeaderCollectionReusableView", for: indexPath) as! HobbiesAndSkillsHeaderCollectionReusableView
            headerView.tag = 0
            if indexPath.section == 0 {
                headerView.setupUI(headerText: Strings.add_hobbies)
            } else {
                headerView.setupUI(headerText: Strings.add_skills)
            }
            return headerView
        } else {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HobbiesAndSkillsFooterCollectionReusableView", for: indexPath) as! HobbiesAndSkillsFooterCollectionReusableView
            if indexPath.section == 0 {
                footerView.addButton.tag = 0
                footerView.hobbyOrSkilltextField.tag = 0
                footerView.seperatorView.isHidden = false
                footerView.setupUI(searchDataForHobbies: hobbiesAndSkillsViewModel.getAutoSuggestionName(type: Strings.hobbies), searchDataForSkills: hobbiesAndSkillsViewModel.getAutoSuggestionName(type: Strings.skills), defaultText: Strings.hobbies)
            } else {
                footerView.addButton.tag = 1
                footerView.hobbyOrSkilltextField.tag = 1
                footerView.seperatorView.isHidden = true
                footerView.setupUI(searchDataForHobbies: hobbiesAndSkillsViewModel.getAutoSuggestionName(type: Strings.hobbies), searchDataForSkills: hobbiesAndSkillsViewModel.getAutoSuggestionName(type: Strings.skills), defaultText: Strings.skills)
            }
            return footerView
        }
    }
    
}
extension HobbiesAndSkillsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if hobbiesAndSkillsViewModel.defaultHobbiesList.endIndex <= indexPath.row {
                return
            }
            if !hobbiesAndSkillsViewModel.selectedHobbies.contains(hobbiesAndSkillsViewModel.defaultHobbiesList[indexPath.row]) {
                hobbiesAndSkillsViewModel.selectedHobbies.append(hobbiesAndSkillsViewModel.defaultHobbiesList[indexPath.row])
                if let selectedCell = collectionView.cellForItem(at: indexPath) as? HobbiesAndSkillsCollectionViewCell {
                    selectedCell.hobbyOrSkillLabel.textColor = UIColor.white
                    selectedCell.hobbyOrSkillView.backgroundColor = UIColor(netHex: 0x4F4937)
                    selectedCell.cancelButton.isHidden = false
                    selectedCell.cancelButtonWidthConstraint.constant = 20
                }
            } else {
                if let selectedItems = collectionView.indexPathsForSelectedItems {
                    for item in selectedItems{
                        if item == indexPath{
                            if let selectedCell = collectionView.cellForItem(at: indexPath) as? HobbiesAndSkillsCollectionViewCell {
                                selectedCell.hobbyOrSkillLabel.textColor = UIColor(netHex: 0x9B6C57)
                                selectedCell.hobbyOrSkillView.backgroundColor = UIColor(netHex: 0xF5F0E1)
                                selectedCell.cancelButton.isHidden = true
                                selectedCell.cancelButtonWidthConstraint.constant = 0
                                if let index = hobbiesAndSkillsViewModel.selectedHobbies.index(of: selectedCell.hobbyOrSkillLabel.text!) {
                                    hobbiesAndSkillsViewModel.selectedHobbies.remove(at: index)
                                }
                            }
                            collectionView.deselectItem(at: indexPath, animated: true)
                            
                        }
                    }
                }
            }
            
        } else {
            if !hobbiesAndSkillsViewModel.selectedSkills.contains(hobbiesAndSkillsViewModel.defaultSkillsList[indexPath.row]) {
                hobbiesAndSkillsViewModel.selectedSkills.append(hobbiesAndSkillsViewModel.defaultSkillsList[indexPath.row])
                if let selectedCell = collectionView.cellForItem(at: indexPath) as? HobbiesAndSkillsCollectionViewCell {
                    selectedCell.hobbyOrSkillLabel.textColor = UIColor.white
                    selectedCell.hobbyOrSkillView.backgroundColor = UIColor(netHex: 0x303030)
                    selectedCell.cancelButton.isHidden = false
                    selectedCell.cancelButtonWidthConstraint.constant = 20
                }
            } else {
                if let selectedItems = collectionView.indexPathsForSelectedItems {
                    for item in selectedItems{
                        if item == indexPath{
                            if let selectedCell = collectionView.cellForItem(at: indexPath) as? HobbiesAndSkillsCollectionViewCell {
                                selectedCell.hobbyOrSkillLabel.textColor = UIColor(netHex: 0x474747)
                                selectedCell.hobbyOrSkillView.backgroundColor = UIColor(netHex: 0xF3F3F3)
                                selectedCell.cancelButton.isHidden = true
                                selectedCell.cancelButtonWidthConstraint.constant = 0
                                if let index = hobbiesAndSkillsViewModel.selectedSkills.index(of: selectedCell.hobbyOrSkillLabel.text!) {
                                    hobbiesAndSkillsViewModel.selectedSkills.remove(at: index)
                                }
                            }
                            collectionView.deselectItem(at: indexPath, animated: true)
                            
                        }
                    }
                }
            }
        }
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            if let selectedItems = collectionView.indexPathsForSelectedItems {
                for item in selectedItems{
                    if item == indexPath{
                        if let selectedCell = collectionView.cellForItem(at: indexPath) as? HobbiesAndSkillsCollectionViewCell {
                            selectedCell.hobbyOrSkillLabel.textColor = UIColor(netHex: 0x9B6C57)
                            selectedCell.hobbyOrSkillView.backgroundColor = UIColor(netHex: 0xF5F0E1)
                            selectedCell.cancelButton.isHidden = true
                            selectedCell.cancelButtonWidthConstraint.constant = 0
                            if let index = hobbiesAndSkillsViewModel.selectedHobbies.index(of: selectedCell.hobbyOrSkillLabel.text!) {
                                hobbiesAndSkillsViewModel.selectedHobbies.remove(at: index)
                            }
                        }
                        collectionView.deselectItem(at: indexPath, animated: true)
                        return false
                    }
                }
            }
        } else {
            if let selectedItems = collectionView.indexPathsForSelectedItems {
                for item in selectedItems{
                    if item == indexPath{
                        if let selectedCell = collectionView.cellForItem(at: indexPath) as? HobbiesAndSkillsCollectionViewCell {
                            selectedCell.hobbyOrSkillLabel.textColor = UIColor(netHex: 0x474747)
                            selectedCell.hobbyOrSkillView.backgroundColor = UIColor(netHex: 0xF3F3F3)
                            selectedCell.cancelButton.isHidden = true
                            selectedCell.cancelButtonWidthConstraint.constant = 0
                            if let index = hobbiesAndSkillsViewModel.selectedSkills.index(of: selectedCell.hobbyOrSkillLabel.text!) {
                                hobbiesAndSkillsViewModel.selectedSkills.remove(at: index)
                            }
                        }
                        collectionView.deselectItem(at: indexPath, animated: true)
                        return false
                    }
                }
            }
        }
        return true
    }
}
extension HobbiesAndSkillsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var text = ""
        
        if indexPath.section == 0 {
            text = hobbiesAndSkillsViewModel.defaultHobbiesList[indexPath.item]
        } else {
            text = hobbiesAndSkillsViewModel.defaultSkillsList[indexPath.item]
        }
        
        let cellWidth = text.size(withAttributes:[.font: UIFont(name: "Roboto-Medium", size: 16) as Any]).width + 35.0
        return CGSize(width: cellWidth + 35, height: 40.0)
    }
}

class HobbiesAndSkillsViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesForElementsInRect = super.layoutAttributesForElements(in: rect)
        var newAttributesForElementsInRect = [UICollectionViewLayoutAttributes]()

        var leftMargin: CGFloat = self.sectionInset.left

        for attributes in attributesForElementsInRect! {
            if (attributes.frame.origin.x == self.sectionInset.left) {
                leftMargin = self.sectionInset.left
            } else {
                var newLeftAlignedFrame = attributes.frame

                if leftMargin + attributes.frame.width < self.collectionViewContentSize.width {
                    newLeftAlignedFrame.origin.x = leftMargin
                } else {
                    newLeftAlignedFrame.origin.x = self.sectionInset.left
                }

                attributes.frame = newLeftAlignedFrame
            }
            leftMargin += attributes.frame.size.width + 15
            newAttributesForElementsInRect.append(attributes)
        }

        return newAttributesForElementsInRect
    }
}
