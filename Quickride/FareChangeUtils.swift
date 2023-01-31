//
//  FareChangeUtils.swift
//  Quickride
//
//  Created by KNM Rao on 22/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
class FareChangeUtils
{

  static func isFareChangeApplicable(matchedUser : MatchedUser)-> Bool{
    
    if Int(matchedUser.points!) <= ClientConfigurtion().minPointsForARide{
        return false
    }
   
      if matchedUser.allowFareChange == false{
        return false
      }else if matchedUser.rideid == 0{
        return false
      }else if matchedUser.userRole == MatchedUser.REGULAR_RIDER || matchedUser.userRole == MatchedUser.REGULAR_PASSENGER {
        return false
      }else{
        return true
      }
  }
  
    static func isFareChangeApplicable(rideInvitation :RideInvitation) -> Bool{
        if rideInvitation.rideType == Ride.PASSENGER_RIDE || rideInvitation.rideType == Ride.REGULAR_PASSENGER_RIDE {
            if Int(rideInvitation.riderPoints) <= ClientConfigurtion().minPointsForARide{
                return false
            }
        }else if rideInvitation.rideType == Ride.PASSENGER_RIDE{
            if Int(rideInvitation.points) <= ClientConfigurtion().minPointsForARide{
                return false
            }
        }else {
            return false
        }
        
        if rideInvitation.allowFareChange == false{
            return false
        }else if rideInvitation.rideType == Ride.REGULAR_RIDER_RIDE || rideInvitation.rideType == Ride.REGULAR_PASSENGER_RIDE{
            return false
        }else{
            return true
        }
    }
  
  
  
  
  static func getMinAmountThatCanReqstdForFareChangeForDistance( points : Double, minPercent : Int, distance : Double,minFare : Float,noOfSeats : Int,maxPoints : Double) -> Double
  {
    if points >= maxPoints{
      return points * Double(minPercent)/100
    }
    let minPercentPoints = points * Double(minPercent)/100
    let minFarePoints = Double(minFare)*distance*Double(noOfSeats)
    if minPercentPoints > minFarePoints{
      if  minPercentPoints >= points{
        return points
      }else{
        return minPercentPoints
      }
      
    }else{
      if  minFarePoints >= points{
        return points
      }else{
        return minFarePoints
      }
    }
  }
    static func getMaxAmountThatCanReqstdForFareChangeForDistance( points : Double, distance : Double,maxFare : Double,noOfSeats : Int,rideFarePerKm: Double) -> Double
    {
        let maxFarePoints = round(Double(maxFare)*distance*Double(noOfSeats))
        if points == 0 {
            return maxFarePoints
        }
        if rideFarePerKm >= maxFare {
            return points
        }
        
        return maxFarePoints < points ? points : maxFarePoints
        
    }
  
    static func getFareDetails(newFare : Double ,actualFare : Double, rideType : String, textColor : UIColor) -> NSAttributedString{
        var newFareStr: String
        var actualFareStr : String
        if rideType == Ride.RIDER_RIDE {
            newFareStr = StringUtils.getStringFromDouble(decimalNumber: floor(newFare))
            actualFareStr = StringUtils.getStringFromDouble(decimalNumber: floor(actualFare))
        }else{
            newFareStr = StringUtils.getStringFromDouble(decimalNumber: ceil(newFare))
            actualFareStr = StringUtils.getStringFromDouble(decimalNumber: ceil(actualFare))
        }
    let string = (newFareStr+" "+actualFareStr) as NSString
    
    let attributedString = NSMutableAttributedString(string: string as String)
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: textColor, textSize: 14), range: string.range(of: newFareStr))
    
    attributedString.addAttribute(NSAttributedString.Key.baselineOffset, value: 0, range: string.range(of: actualFareStr))
   attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeWithStrikeOff(textColor: UIColor(netHex: 0x9BA3B1), textSize: 14), range: string.range(of: actualFareStr))

    return attributedString
  }
    static func getFareChangeWithStrikeOffOldFare(newFare : String ,actualFare : String,textColor : UIColor,textSize: Int) -> NSAttributedString{
        let string = (actualFare+" "+newFare) as NSString
        let attributedString = NSMutableAttributedString(string: string as String)
        attributedString.addAttribute(NSAttributedString.Key.baselineOffset, value: 0, range: string.range(of: actualFare))
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeWithStrikeOff(textColor: textColor.withAlphaComponent(0.5), textSize: 14), range: string.range(of: actualFare))
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: textColor, textSize: CGFloat(textSize)), range: string.range(of: newFare))
        return attributedString
    }
  
}
