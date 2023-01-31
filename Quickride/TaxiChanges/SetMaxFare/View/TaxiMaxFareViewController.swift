//
//  TaxiMaxFareViewController.swift
//  Quickride
//
//  Created by Ashutos on 19/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias maxFareValue = (_ value: Int) -> Void

class TaxiMaxFareViewController: UIViewController {
    @IBOutlet weak var sliderCurrentValueLabel: UILabel!
    @IBOutlet weak var sliderminValueLabel: UILabel!
    @IBOutlet weak var sliderMaxValueLabel: UILabel!
    @IBOutlet weak var maxFareSlider: UISlider!
    
    private var maxValue = 0
    private var minValue = 0
    private var selectedValue = 0
    private var handler : maxFareValue?
    
    func prepareDataForUI(selectedValue: Int, minValue: Int, maxValue: Int,handler : maxFareValue?) {
        self.maxValue = maxValue
        self.minValue = minValue
        self.selectedValue = selectedValue
        self.handler = handler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maxFareSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:))))
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        setUpUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc private func sliderTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        if let slider = gestureRecognizer.view as? UISlider {
            if slider.isHighlighted { return }
            let point = gestureRecognizer.location(in: slider)
            let percentage = Float(point.x / slider.bounds.width)
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            let newValue = slider.minimumValue + delta
            maxFareSlider.setValue(Float(newValue), animated: true)
            sliderCurrentValueLabel.text = "₹\(Int(newValue))"
        }
    }
    
    private func setUpUI() {
        maxFareSlider.minimumValue = Float(minValue)
        maxFareSlider.maximumValue = Float(maxValue)
        sliderminValueLabel.text = "₹\(minValue)"
        sliderMaxValueLabel.text = "₹\(maxValue)"
        sliderCurrentValueLabel.text = "₹\(selectedValue)"
        maxFareSlider.setValue(Float(selectedValue),animated: false)
    }
    
    @IBAction func sliderValueDidChanged(_ sender: UISlider) {
        sliderCurrentValueLabel.text = "₹\(Int(maxFareSlider.value))"
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    
    @IBAction func maximumFareSetBtnPressed(_ sender: UIButton) {
        handler?(Int(maxFareSlider.value))
        self.navigationController?.popViewController(animated: false)
    }
}
