//
//  ViewCustomizationUtils.swift
//  Quickride
//
//  Created by QuickRideMac on 14/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class ViewCustomizationUtils {
  

  static let FONT_STYLE = "Helvetica Neue"
  static let ALERT_DIALOGUE_LABEL_LINE_HEIGHT = 13
  static let LABEL_TEXT_SIZE = 12
  static let LABEL_LINE_HEIGHT = 10
  static let ALERT_DIALOGUE_LABEL_TEXT_SIZE = 13
  static let ALERT_DIALOG_LABEL_LINE_HEIGHT = 14
  static let QUICKRIDE_CUSTOM_DIALOG_LABEL_LINE_HEIGHT = 17

  static func addBorderToView(view : UIView,borderWidth :Int, colorCode : Int){
    view.layer.borderWidth = CGFloat(borderWidth)
    view.layer.borderColor = UIColor(netHex: colorCode).cgColor
  }
  static func addBorderToView(view :UIView,borderWidth :CGFloat, color : UIColor){
    view.layer.borderWidth = borderWidth
    view.layer.borderColor = color.cgColor
  }
  static func addCornerRadiusToView(view : UIView, cornerRadius : CGFloat){
    view.layer.cornerRadius = cornerRadius
  }
    
  static func addCornerRadiusWithBorderToView(view : UIView,cornerRadius : CGFloat,borderWidth :CGFloat,color : UIColor) {
    view.layer.cornerRadius = cornerRadius
    view.layer.borderWidth = borderWidth
    view.layer.borderColor = color.cgColor
 }
    
  static func addCornerRadiusToSpecificCornersOfView(view :UIView,cornerRadius : CGFloat,corner1 :UIRectCorner,corner2 :UIRectCorner){
      
      if #available(iOS 11.0, *) {
          view.clipsToBounds = true
          view.layer.cornerRadius = cornerRadius
          var newCorner1 :CACornerMask?
          var newCorner2 :CACornerMask?
          switch corner1 {
          case .topLeft :
              newCorner1 = .layerMinXMinYCorner
          case .topRight :
              newCorner1 = .layerMaxXMinYCorner
          case .bottomLeft :
              newCorner1 = .layerMinXMaxYCorner
          default  :
              newCorner1 = .layerMaxXMaxYCorner
              
          }
          
          switch corner2 {
          case .topLeft :
              newCorner2 = .layerMinXMinYCorner
          case .topRight :
              newCorner2 = .layerMaxXMinYCorner
          case .bottomLeft :
              newCorner2 = .layerMinXMaxYCorner
          default  :
              newCorner2 = .layerMaxXMaxYCorner
          
          }
          view.layer.maskedCorners = [newCorner1!, newCorner2!]
      } else {
          let maskLayer = CAShapeLayer()
          maskLayer.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [corner1, corner2], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
          view.layer.mask = maskLayer
  }
  }
    
  
  static func addCornerRadiusToThreeCorners(view :UIView,cornerRadius : CGFloat,corners :UIRectCorner){
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        view.layer.mask = maskLayer
    }
    
  static func setImageWithText(text : String, icon: UIImage, label:UILabel){
    
    let attachment = NSTextAttachment()
    attachment.image = icon
    
    let attachmentString = NSAttributedString(attachment: attachment)
    
    let myString = NSMutableAttributedString(string: text)
    
    myString.append(attachmentString)
    
    label.attributedText = myString
    
  }
  static func createNSAtrribute(textColor : UIColor,textSize : CGFloat) -> [NSAttributedString.Key : Any]{
    return [NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.font : UIFont(name: ViewCustomizationUtils.FONT_STYLE, size: textSize)!]
  }
  static func createNSAtrributeWithUnderline(textColor : UIColor,textSize : CGFloat) -> [NSAttributedString.Key : Any]{
    return [NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.font : UIFont(name: ViewCustomizationUtils.FONT_STYLE, size: textSize)!,NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
  }
  static func createNSAtrributeWithStrikeOff(textColor : UIColor,textSize : CGFloat) -> [NSAttributedString.Key : Any]{
    return [NSAttributedString.Key.foregroundColor : textColor, NSAttributedString.Key.font : UIFont(name: ViewCustomizationUtils.FONT_STYLE, size: textSize)!,NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
  }
  

  static func getImageFromUIView(view: UIView) -> UIImage? {
      UIGraphicsBeginImageContextWithOptions(view.frame.size,false, 0)
      view.layer.render(in: UIGraphicsGetCurrentContext()!)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return image
    
  }
  static func getImageFromView(view: UIView) -> UIImage {
      UIGraphicsBeginImageContextWithOptions(view.frame.size,false, 0)
      view.layer.render(in: UIGraphicsGetCurrentContext()!)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return image!
  }
    
    static func createNSAttributeWithParagraphStyle(string : String) -> NSMutableAttributedString?{
        let attributedString = NSMutableAttributedString(string: string)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1.5
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        return attributedString
    }
    static func getAttributedString(string: String, rangeofString: String,textColor : UIColor,textSize : CGFloat) -> NSAttributedString{
    let attributedString = NSMutableAttributedString(string: string)
    attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: textColor, textSize: textSize), range: (string as NSString).range(of: rangeofString))
   return attributedString
  }
   static var hasTopNotch: Bool{
        if #available(iOS 11.0, *){
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
}

extension UIImage{
    var roundedCornerImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: 10
            ).addClip()
        self.draw(in: rect)
        if let newImage = UIGraphicsGetImageFromCurrentImageContext(){
            return newImage
        }else{
            return self
        }
    }
}
extension UIView {
    func rippleStarting(at origin: CGPoint, with color: UIColor?, duration: TimeInterval, radius: CGFloat, fadeAfter: TimeInterval,handler : @escaping () -> Void) {
        
        let bounds: CGRect = self.bounds
        let x = bounds.width
        let y = bounds.height
        
        // Build an array with the four corners of the view.
        let corners = [NSValue(cgPoint: CGPoint(x: 0, y: 0)), NSValue(cgPoint: CGPoint(x: 0, y: y)), NSValue(cgPoint: CGPoint(x: x, y: 0)), NSValue(cgPoint: CGPoint(x: x, y: y))]
        
        // Calculate the corner closest to the origin and the one farther from it.
        // We might not need these values, but calculate them anyway so that the code
        // is clearer.
        var minDistance = CGFloat.greatestFiniteMagnitude
        var maxDistance: CGFloat = -1
        
        for cornerValue: NSValue in corners {
            let corner: CGPoint = cornerValue.cgPointValue
            let d = distanceBetween(a : origin, b : corner)
            if d < minDistance {
                minDistance = d
            }
            
            if d > maxDistance {
                maxDistance = d
            }
        }
        
        // Calculate the start and end radius of our ripple effect.
        // If the ripple starts inside the view then the start radis is 0, if it
        // starts outside the view then make the radius the distance to the nearest corner.
        let originInside: Bool = origin.x > 0 && origin.x < x && origin.y > 0 && origin.y < y
        // Note that if 0 is used as a default value then the circle may look misshapen.
        let startRadius: CGFloat = originInside ? 0.1 : minDistance
        
        // If we set a radius use it, if not then use the distance to the farthest corner.
        let endRadius: CGFloat = radius > 0 ? radius : minDistance
        
        // Create paths for out start and end circles.
        let startPath = UIBezierPath(arcCenter: origin, radius: startRadius, startAngle: 0, endAngle: (CGFloat(2 * Double.pi)), clockwise: true)
        let endPath = UIBezierPath(arcCenter: origin, radius: endRadius, startAngle: 0, endAngle: (CGFloat(2 * Double.pi)), clockwise: true)
        
        // Create a new layer to draw the ripple on.
        let rippleLayer = CAShapeLayer()
        rippleLayer.name = "RippleLayer"
        // Make sure the ripple effect doesn't "leave" the view.
        layer.masksToBounds = true
        
        rippleLayer.fillColor = color?.cgColor
        
        // Create the animation
        let rippleAnimation = CABasicAnimation(keyPath: "path")
        rippleAnimation.fillMode = .both
        rippleAnimation.duration = CFTimeInterval(duration)
        rippleAnimation.fromValue = startPath.cgPath
        rippleAnimation.toValue = endPath.cgPath
        rippleAnimation.isRemovedOnCompletion = false
        rippleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        // Set the ripple layer to be just above the bg.
        layer.insertSublayer(rippleLayer, at: 0)
        // Give the ripple layer the animation.
        rippleLayer.add(rippleAnimation, forKey: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(fadeAfter * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            // Add a fade out animation.
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.fillMode = .both
            fadeAnimation.duration = CFTimeInterval(duration - fadeAfter)
            fadeAnimation.fromValue = 1.0
            fadeAnimation.toValue = 0.0
            fadeAnimation.isRemovedOnCompletion = false
            
            rippleLayer.add(fadeAnimation, forKey: nil)
        })
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(duration * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            // All animations are done, so remove the layer.
            rippleLayer.removeAllAnimations()
            rippleLayer.removeFromSuperlayer()
            handler()
        })
    }
    func distanceBetween( a : CGPoint, b : CGPoint) -> CGFloat {
        return sqrt(pow(abs(a.x - b.x), 2) + pow(abs(a.y - b.y), 2));
    }
    
    func slideInFromLeft(duration: TimeInterval, completionDelegate: AnyObject?) {
        
        let slideInFromLeftTransition = CATransition()
        
        
        if let delegate: AnyObject = completionDelegate {
            slideInFromLeftTransition.delegate = delegate as? CAAnimationDelegate
        }
        
        slideInFromLeftTransition.type = CATransitionType.push
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromLeft
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    func slideInFromRight(duration: TimeInterval, completionDelegate: AnyObject?) {
        
        let slideInFromLeftTransition = CATransition()
        
        if let delegate: AnyObject = completionDelegate {
            slideInFromLeftTransition.delegate = delegate as? CAAnimationDelegate
        }
        
        slideInFromLeftTransition.type = CATransitionType.push
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromRight
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    
    func dropShadow(color: UIColor, opacity: Float, offSet: CGSize, radius: CGFloat , scale: Bool, cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
       func addShadow(scale: Bool = true) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.3
        }
    
    func addShadowWithOffset(shadowOffSet : CGSize) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = shadowOffSet
        layer.shadowOpacity = 0.1
    }
    func addDashedLineAroundView(color: UIColor) {
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.name = "dashedLine"
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 20)
        yourViewBorder.path = path.cgPath
        yourViewBorder.strokeColor = color.cgColor
        yourViewBorder.lineDashPattern = [2, 2]
        yourViewBorder.frame = self.bounds
        yourViewBorder.fillColor = nil
        self.layer.addSublayer(yourViewBorder)
    }
    func addDashedBorder(view : UIView,color: UIColor) {
        //Create a CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [4,4]
        
        let path = CGMutablePath()
        let deviceWidth = UIScreen.main.bounds.size.width
        if deviceWidth <= 320{
            path.addLines(between: [CGPoint(x: view.frame.origin.x - 10, y: 0),
                                    CGPoint(x: view.frame.origin.x - 10, y: 300)])
        }else{
            path.addLines(between: [CGPoint(x: view.frame.origin.x + 15, y: 0),
                                    CGPoint(x: view.frame.origin.x + 15, y: 300)])
        }
       
        shapeLayer.path = path
       
        if layer.sublayers != nil{
            for layer in layer.sublayers! {
                if layer.name == "dashedLine" {
                    return
                }
            }
        }
        
        shapeLayer.name = "dashedLine"
        layer.addSublayer(shapeLayer)
        
    }
    
    func addDashedView(color: CGColor){
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [2,2]
        
        let path = CGMutablePath()
        let deviceWidth = UIScreen.main.bounds.size.width
        if deviceWidth <= 320{
            path.addLines(between: [CGPoint(x: 0, y: 0),
                                    CGPoint(x: self.frame.width + 20, y: 0)])
        }
        else{
            path.addLines(between: [CGPoint(x: 0, y: 0),
                                    CGPoint(x: self.frame.width + 50, y: 0)])
        }
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
    func drawDashedLineArroundView(view: UIView,color: UIColor){
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = color.cgColor
        yourViewBorder.lineDashPattern = [2, 2]
        yourViewBorder.frame = view.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.cornerRadius = 10
        view.layer.cornerRadius = 10
        yourViewBorder.path = UIBezierPath(rect: view.bounds).cgPath
        view.layer.addSublayer(yourViewBorder)
    }
    
}
