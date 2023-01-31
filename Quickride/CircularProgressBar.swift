//
//  CircularProgressBar.swift
//  attendance-manager
//
//  Created by Yogesh Manghnani on 02/05/18.
//  Copyright © 2018 Yogesh Manghnani. All rights reserved.
//

import UIKit


class CircularProgressBar: UIView {
    
    var progressLyr = CAShapeLayer()
    var trackLyr = CAShapeLayer()
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       makeCircularPath()
    }
    var progressClr = UIColor.white {
       didSet {
          progressLyr.strokeColor = progressClr.cgColor
       }
    }
    var trackClr = UIColor.white {
       didSet {
          trackLyr.strokeColor = trackClr.cgColor
       }
    }
    func makeCircularPath() {
       self.backgroundColor = UIColor.clear
       self.layer.cornerRadius = self.frame.size.width/2
       let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (frame.size.width - 1.5)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
       trackLyr.path = circlePath.cgPath
        trackLyr.fillColor = UIColor(netHex: 0xDCDCDC).cgColor
       trackLyr.strokeColor = trackClr.cgColor
       trackLyr.lineWidth = 8.0
       trackLyr.strokeEnd = 0.0
       layer.addSublayer(trackLyr)
       progressLyr.path = circlePath.cgPath
       progressLyr.fillColor = UIColor.clear.cgColor
       progressLyr.strokeColor = progressClr.cgColor
       progressLyr.lineWidth = 10.0
       progressLyr.strokeEnd = 0.0
       layer.addSublayer(progressLyr)
    }
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
       let animation = CABasicAnimation(keyPath: "strokeEnd")
       animation.duration = duration
       animation.fromValue = 0
       animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
       progressLyr.strokeEnd = CGFloat(value)
       progressLyr.add(animation, forKey: "animateprogress")
    }
    
}
