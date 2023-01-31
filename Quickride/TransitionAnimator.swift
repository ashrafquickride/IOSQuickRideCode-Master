//
//  CircularAnimationTransitionDelegate.swift
//  Quickride
//
//  Created by apple on 2/26/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TransitionAnimator: NSObject,UIViewControllerAnimatedTransitioning{

    let duration = 0.2
    var presenting = true
    var originFrame = CGRect.zero
    
    var dismissCompletion: (()->Void)?
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
         return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to), let detailView = presenting ? toView: transitionContext.view(forKey: .from) else {
            return
        }
        
        let initialFrame = presenting ? originFrame : detailView.frame
        let finalFrame = presenting ? detailView.frame : originFrame
        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor,
                                               y: yScaleFactor)
        
        if presenting {
            detailView.transform = scaleTransform
            detailView.center = CGPoint( x: initialFrame.midX, y: initialFrame.midY)
            detailView.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(detailView)
        
        if presenting {
            //update opening animation
            UIView.animate(withDuration: duration, delay:0.0, options: .curveEaseIn,
                           animations: {
                        detailView.transform = CGAffineTransform.identity
                        detailView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            },
                           completion:{_ in
                            transitionContext.completeTransition(true)
            }
            )

        } else {
            //update closing animation
            
            UIView.animate(withDuration: duration, delay:0.0, options: .curveEaseOut,
                           animations: {
                            detailView.transform = scaleTransform
                            detailView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            },
                           completion:{_ in
                            if !self.presenting {
                                self.dismissCompletion?()
                            }
                            transitionContext.completeTransition(true)
            }
          )
        }
    }
}


    

    

