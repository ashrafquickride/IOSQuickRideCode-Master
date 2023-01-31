//
//  UserCoreDataHelper.swift
//  Quickride
//
//  Created by KNM Rao on 22/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import Foundation
import CoreData

class UserCoreDataHelper : CoreDataHelper{
    
    static let locationId : String = "locationId"
    static let name : String = "name"
    static let address : String = "address"
    static let latitude : String = "latitude"
    static let longitude : String = "longitude"
    static let leavingTime : String = "leavingTime"
    static let country = "country"
    static let state = "state"
    static let city = "city"
    static let areaName = "areaName"
    static let streetName = "streetName"
    
    static let recentLocationId : String = "recentLocationId"
    static let recentAddress : String = "recentAddress"
    static let recentAddressName : String = "recentAddressName"
    static let userRecentLocationTable : String = "UserRecentLocation"
    static let userFavouriteLocationTable : String = "UserFavouriteLocation"
    static let userRecentSearchedLocation : String = "RecentSearchedLocation"
    static let time : String = "time"
    
    //MARK: Table Name
    static let userProfileTable : String = "UserProfile"
    static let vehicleTable : String = "Vehicle"
    static let userTable : String = "User"
    static let accountTable : String = "Account"
    static let userFavouritePartnerTable = "UserFavouritePartner"
    static let userRouteGroupTable = "UserRouteGroup"
    static let userGroupTable = "UserGroup"
    static let userGroupMembersTable = "UserGroupMember"
    static let blockedUserTable = "BlockedUser"
    static let linkedWalletTable = "LinkedWallet"
    static let profileVerificationData = "ProfileVerificationData"
    static let nomineeDetailsTable = "NomineeDetails"
    static let greetingDetailsTable = "GreetingDetails"
    static let userPreferredPickupDropTable = "UserPreferredPickupDrop"
    static let userSelfAssessmentCovidTable = "UserSelfAssessmentCovid"
    
    static let confirmType : String = "confirmType"
    static let verificationStatus : String = "verificationStatus"
    static let rating : String = "rating"
    static let numberOfRidesAsPassenger : String = "numberOfRidesAsPassenger"
    static let numberOfRidesAsRider : String = "numberOfRidesAsRider"
    static let matchCompanyConstraint : String = "matchCompanyConstraint"
    static let matchGenderConstraint : String = "matchGenderConstraint"
    static let companyName : String = "companyName"
    static let profession : String = "profession"
    static let aboutMe : String = "aboutMe"
    static let email : String = "email"
    static let emailForCommunication : String = "emailforcommunication"
    static let facebook : String = "facebook"
    static let linkedin : String = "linkedin"
    static let twitter : String = "twitter"
    static let vehicleType : String = "vehicleType"
    static let vehicleNumber : String = "vehicleNumber"
    static let rideMatchPercentageAsPassenger_key = "rideMatchPercentageAsPassenger"
    static let rideMatchPercentageAsRider_key = "rideMatchPercentageAsRider"
    static let supportCall_key = "supportCall"
    static let id = "id"
    // MARK: User
    static let userName : String = "userName"
    static let phoneNumber : String = "phoneNumber"
    static let password : String = "password"
    static let gender : String = "gender"
    static let creationDate : String = "creationDate"
    static let referralCode : String = "referralCode"
    static let status : String = "status"
    static let clientUniqueDeviceId : String = "clientUniqueDeviceId"
    static let appliedPromoCode = "appliedPromoCode"
    static let clientIosKey = "clientIosKey"
    static let contactNo = "contactNo"
    static let iosAppVersionName = "iosAppVersionName"
    static let primaryArea = "primaryArea"
    static let primaryAreaLat = "primaryAreaLat"
    static let primaryAreaLng = "primaryAreaLng"
    static let primaryRegion = "primaryRegion"
    static let phoneModel = "phoneModel"
    static let countryCode = "countryCode"
    static let uniqueDeviceId = "uniqueDeviceId"
    static let asksCashTransactions = "asksCashTransactions"
    static let subscriptionStatus = "subscriptionStatus"
    static let freeRideId = "freeRideId"
    static let roleAtSignup = "roleAtSignup"
    static let alternateContactNo = "alternateContactNo"
    static let dateOfBirth = "dateOfBirth"
    static let pickupOTP = "pickupOTP"
    static let skills = "skills"
    static let interests = "interests"
    
    // MARK: Vehicle
    static let userId : String = "userId"
    static let ownerId : String = "ownerId"
    static let vehicleModel : String = "vehicleModel"
    static let registrationNumber : String = "registrationNumber"
    static let capacity : String = "capacity"
    static let fare : String = "fare"
    static let imageURI : String = "imageURI"
    static let vehicleId : String = "vehicleId"
    static let makeAndCategory = "makeAndCategory"
    static let additionalFacilities = "additionalFacilities"
    static let defaultVehicle = "defaultVehicle"
    static let riderHasHelmet = "riderHasHelmet"
    
    static let NAME = "name"
    static let PLACE_ID = "placeId"
    static let LATITUDE = "latitude"
    static let LONGITUDE = "longitude"
    static let COUNTRY = "country"
    static let STATE = "state"
    static let CITY = "city"
    static let AREA_NAME = "areaName"
    static let STREET_NAME = "streetName"
    static let LOCATION_NAME = "locationName"
    static let FORMATTED_ADDRESS = "formattedAddress"
    static let CREATION_DATE = "creationDate"
    static let RECENT_USED_TIME = "recentUsedTime"
    static let recent_searches_table_size = 100
    
    
    
    // MARK: Account
    static let balance : String = "balance"
    static let reserved : String = "reserved"
    static let rewardsPoints : String = "rewardsPoints"
    static let purchasedPoints : String = "purchasedPoints"
    static let earnedPoints : String = "earnedPoints"
   
    
    // MARK: PreferredRidePartner
    static let favouritePartnerUserId = "favouritePartnerUserId"
    
    //MARK: UserRouteGroup
    static let groupName = "groupName"
    static let creatorId = "creatorId"
    static let fromLocationAddress = "fromLocationAddress"
    static let toLocationAddress = "toLocationAddress"
    static let fromLocationLatitude = "fromLocationLatitude"
    static let fromLocationLongitude = "fromLocationLongitude"
    static let toLocationLatitude = "toLocationLatitude"
    static let toLocationLongitude = "toLocationLongitude"
    static let memberCount = "memberCount"
    static let appName = "appName"
    
    //MARK: UserGroup
    
    static let description = "discription"
    static let type = "type"
    static let category = "category"
    static let url = "url"
    static let creationTime = "creationTime"
    static let currentUserStatus = "currentUserStatus"
    static let requestedUserId = "requestedUserId"
    static let lastRefreshedTime = "lastRefreshedTime"
    static let companyCode = "companyCode"
    
    //MARK: UserGroupMember
    
    static let groupId = "groupId"
    
    //MARK: BlockedUser
    
    static let blockedUserId = "blockedUserId"
    
    static let matchGroupCompaniesConstraint = "matchGroupCompaniesConstraint"
    static let emergencyContactNumber = "emergencyContactNumber"
    static let noOfReviews = "noOfReviews"
    static let preferredRole = "preferredRole"
    static let preferredVehicle = "preferredVehicle"
    
    //MARK: LinkedWallet
    
    static let mobileNo = "mobileNo"
    static let token = "token"
    static let key = "key"
    static let custId = "custId"
    static let defaultWallet = "defaultWallet"
    static let linkedWalletStatus = "status"
    

    //MARK: ProfileVerificationData
    static let emailVerified = "emailVerified"
    static let imageVerified = "imageVerified"
    static let profileVerified = "profileVerified"
    static let persIDVerified = "persIDVerified"
    static let profVerifSource = "profVerifSource"
    static let persVerifSource = "persVerifSource"
    static let emailVerifiedAtleastOnce = "emailVerifiedAtleastOnce"
    static let noOfEndorsers = "noOfEndorsers"
    static let emailVerificationStatus = "emailVerificationStatus"
    
    // MARK: NomineeDetails
    static let nomineeName = "nomineeName"
    static let nomineeAge : String = "nomineeAge"
    static let nomineeRelation : String = "nomineeRelation"
    static let nomineeMobile : String = "nomineeMobile"
    
    // MARK: GreetingDetails
    static let message = "message"
    static let gifImageUrl = "gifImageUrl"
    static let displayedCount = "displayedCount"
    static let greetingType = "type"
    
    //MARK: UserPreferredPickupDrop
    static let userPreferredPickupDropId = "id"
    static let passengerUserId = "userId"
    static let userPreferredPickupDropLatitude = "latitude"
    static let userPreferredPickupDropLongitude = "longitude"
    static let userPreferredPickupDropType = "type"
    static let note = "note"
    
    //MARK: UserSelfAssessmentCovid
    static let selfAssessmentUserId = "userId"
    static let assessmentResult = "assessmentResult"
    static let createdDate = "createdDate"
    static let expiryDate = "expiryDate"
    
    static func saveRecentLocation(userRecentLocation : UserRecentLocation){
        
        AppDelegate.getAppDelegate().log.debug("saveRecentLocation()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let entity = NSEntityDescription.entity(forEntityName: userRecentLocationTable, in: managedContext)
        let userRecentLocationObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        userRecentLocationObject.setValue(userRecentLocation.recentLocationId, forKey: recentLocationId)
        userRecentLocationObject.setValue(userRecentLocation.recentAddress , forKey: recentAddress)
        userRecentLocationObject.setValue(userRecentLocation.recentAddressName, forKey: recentAddressName)
        userRecentLocationObject.setValue(userRecentLocation.latitude, forKey: latitude)
        userRecentLocationObject.setValue(userRecentLocation.longitude, forKey: longitude)
        userRecentLocationObject.setValue(userRecentLocation.time, forKey: time)
        userRecentLocationObject.setValue(userRecentLocation.city, forKey: city)
        userRecentLocationObject.setValue(userRecentLocation.country, forKey: country)
        userRecentLocationObject.setValue(userRecentLocation.state, forKey: state)
        userRecentLocationObject.setValue(userRecentLocation.areaName, forKey: areaName)
        userRecentLocationObject.setValue(userRecentLocation.streetName, forKey: streetName)
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }
    
    
    static func deleteRecentLocation(userRecentLocation : UserRecentLocation){
        
        AppDelegate.getAppDelegate().log.debug("deleteRecentLocation()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        // make the call async
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserRecentLocation")
        let predicate = NSPredicate(format: "\(latitude) == %@ AND \(longitude) == %@", argumentArray: [userRecentLocation.latitude!,userRecentLocation.longitude!])
        fetchRequest.predicate = predicate
        do {
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do{
                try managedContext.execute(deleteRequest)
            }catch{
                AppDelegate.getAppDelegate().log.error("failed batch delete : \(error)")
                clearRecordByRecord(fetchRequest: fetchRequest)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }catch let error as NSError{
            AppDelegate.getAppDelegate().log.debug("Fetch Failed : \(error.localizedDescription)")
        }
    }
    
    static func saveFavouriteLocation(userFavouriteLocation : UserFavouriteLocation){
        AppDelegate.getAppDelegate().log.debug("saveFavouriteLocation()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        prepareFavouriteLocationObjAndStore(userFavouriteLocation: userFavouriteLocation, managedContext: managedContext)
    }
    
    static func saveFaouriteLocationsInBulk(userFavLocations : [UserFavouriteLocation]){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        for userFavLocation in userFavLocations{
            prepareFavouriteLocationObjAndStore(userFavouriteLocation: userFavLocation, managedContext: managedContext)
        }
    }
    
    static func prepareFavouriteLocationObjAndStore(userFavouriteLocation : UserFavouriteLocation,managedContext : NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: userFavouriteLocationTable, in: managedContext)
        let userFavouriteLocationObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        userFavouriteLocationObject.setValue(userFavouriteLocation.locationId, forKey: locationId)
        userFavouriteLocationObject.setValue(userFavouriteLocation.address , forKey: address)
        userFavouriteLocationObject.setValue(userFavouriteLocation.name, forKey: name)
        userFavouriteLocationObject.setValue(userFavouriteLocation.latitude, forKey: latitude)
        userFavouriteLocationObject.setValue(userFavouriteLocation.longitude, forKey: longitude)
        userFavouriteLocationObject.setValue(userFavouriteLocation.phoneNumber, forKey: phoneNumber)
        userFavouriteLocationObject.setValue(userFavouriteLocation.leavingTime, forKey: leavingTime)
        userFavouriteLocationObject.setValue(userFavouriteLocation.city, forKey: city)
        userFavouriteLocationObject.setValue(userFavouriteLocation.country, forKey: country)
        userFavouriteLocationObject.setValue(userFavouriteLocation.state, forKey: state)
        userFavouriteLocationObject.setValue(userFavouriteLocation.areaName, forKey: areaName)
        userFavouriteLocationObject.setValue(userFavouriteLocation.streetName, forKey: streetName)
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }
    
    static func getUserFavouriteLocationObject() -> [UserFavouriteLocation]{
        AppDelegate.getAppDelegate().log.debug("getUserFavouriteLocationObject()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userFavouriteLocationTable)
        var returnUserFavouriteLocations  = [UserFavouriteLocation]()
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects! {
                let returnuserFavouriteLocationObject : UserFavouriteLocation? = UserFavouriteLocation()
                returnuserFavouriteLocationObject?.locationId = userManagedObject.value(forKey: locationId) as? Double
                returnuserFavouriteLocationObject?.address = userManagedObject.value(forKey: address) as? String
                returnuserFavouriteLocationObject?.name = userManagedObject.value(forKey: name) as? String
                returnuserFavouriteLocationObject?.latitude = userManagedObject.value(forKey: latitude) as? Double
                returnuserFavouriteLocationObject?.longitude = userManagedObject.value(forKey: longitude) as? Double
                returnuserFavouriteLocationObject?.phoneNumber = userManagedObject.value(forKey: phoneNumber) as? Double
                returnuserFavouriteLocationObject?.leavingTime = userManagedObject.value(forKey: leavingTime) as? Double
                returnuserFavouriteLocationObject?.city = userManagedObject.value(forKey: city) as? String
                returnuserFavouriteLocationObject?.country = userManagedObject.value(forKey: country) as? String
                returnuserFavouriteLocationObject?.state = userManagedObject.value(forKey: state) as? String
                returnuserFavouriteLocationObject?.areaName = userManagedObject.value(forKey: areaName) as? String
                returnuserFavouriteLocationObject?.streetName = userManagedObject.value(forKey: streetName) as? String
                
                returnUserFavouriteLocations.append(returnuserFavouriteLocationObject!)
            }
        }
        return returnUserFavouriteLocations
    }
    
    static func deleteUserFavouriteLocationObject(userFavouriteLocation : UserFavouriteLocation){
        AppDelegate.getAppDelegate().log.debug("deleteUserFavouriteLocationObject()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        // make the call async
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFavouriteLocation")
        let predicate = NSPredicate(format: "\(locationId) == %@", argumentArray: [userFavouriteLocation.locationId!])
        fetchRequest.predicate = predicate
        do {
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do{
                try managedContext.execute(deleteRequest)
            }catch{
                AppDelegate.getAppDelegate().log.error("failed batch delete : \(error)")
                clearRecordByRecord(fetchRequest: fetchRequest)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }catch let error as NSError{
            AppDelegate.getAppDelegate().log.debug("Fetch Failed : \(error.localizedDescription)")
        }
        
    }
    
    static func getuserRecentLocationObject() -> [UserRecentLocation]{
        AppDelegate.getAppDelegate().log.debug("getuserRecentLocationObject()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userRecentLocationTable)
        var returnUserRecentLocations  = [UserRecentLocation]()
        
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects! {
                let returnUserRecentLocationObject : UserRecentLocation? = UserRecentLocation()
                returnUserRecentLocationObject?.recentLocationId = userManagedObject.value(forKey: recentLocationId) as? String
                returnUserRecentLocationObject?.recentAddress = userManagedObject.value(forKey: recentAddress) as? String
                returnUserRecentLocationObject?.recentAddressName = userManagedObject.value(forKey: recentAddressName) as? String
                returnUserRecentLocationObject?.latitude = userManagedObject.value(forKey: latitude) as? Double
                returnUserRecentLocationObject?.longitude = userManagedObject.value(forKey: longitude) as? Double
                returnUserRecentLocationObject?.time = userManagedObject.value(forKey: time) as? Double ?? 0
                returnUserRecentLocationObject?.city = userManagedObject.value(forKey: city) as? String
                returnUserRecentLocationObject?.country = userManagedObject.value(forKey: country) as? String
                returnUserRecentLocationObject?.state = userManagedObject.value(forKey: state) as? String
                returnUserRecentLocationObject?.areaName = userManagedObject.value(forKey: areaName) as? String
                returnUserRecentLocationObject?.streetName = userManagedObject.value(forKey: streetName) as? String

                returnUserRecentLocations.append(returnUserRecentLocationObject!)
            }
        }
        return returnUserRecentLocations
    }
    static func executeFetchResultAll(managedContext : NSManagedObjectContext, fetchRequest : NSFetchRequest<NSFetchRequestResult>) -> [NSManagedObject]?{
        AppDelegate.getAppDelegate().log.debug("executeFetchResultAll()")
        var fetchResults = [NSManagedObject]()
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            fetchResults = results as! [NSManagedObject]
            
        } catch let error as NSError {
            AppDelegate.getAppDelegate().log.error("Could not fetch \(error), \(error.userInfo)")
        }
        
        if fetchResults.count != 0{
            return fetchResults
        }else{
            return nil
        }
    }
    
    static func clearRecentLocations(){
        AppDelegate.getAppDelegate().log.debug("clearRecentLocations()")
        self.clearTableForEntity(entityName: userRecentLocationTable)
    }
    
    static func clearTableForEntity(entityName : String){
        AppDelegate.getAppDelegate().log.debug("clearTableForEntity() \(entityName)")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do{
            let deleteFetchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try managedContext.execute(deleteFetchRequest)
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }catch{
            AppDelegate.getAppDelegate().log.debug("deleteFetchRequest Failed : \(error)")
        }
        
    }
    static func clearRecordByRecord(fetchRequest : NSFetchRequest<NSFetchRequestResult>){
        do{
            let managedObjectContext = CoreDataHelper.getNSMangedObjectContext()
            let results = try managedObjectContext.fetch(fetchRequest)
            for i in 0..<results.count {
                managedObjectContext.delete(results[i] as! NSManagedObject)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedObjectContext)
        } catch let error as NSError{
            AppDelegate.getAppDelegate().log.debug("clearRecordByRecord Failed : \(error.localizedDescription)")
        }
    }
    static func saveUserProfileObject(userProfile : UserProfile){
        AppDelegate.getAppDelegate().log.debug("saveUserProfileObject()")
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform() {
            let entity = NSEntityDescription.entity(forEntityName: userProfileTable, in: managedContext)
            let userProfileObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            userProfileObject.setValue(userProfile.userId, forKey: userId)
            userProfileObject.setValue(userProfile.userName, forKey: userName)
            userProfileObject.setValue(userProfile.confirmType, forKey: confirmType)
            userProfileObject.setValue(userProfile.verificationStatus, forKey: verificationStatus)
            userProfileObject.setValue(userProfile.rating, forKey: rating)
            userProfileObject.setValue(userProfile.numberOfRidesAsPassenger, forKey: numberOfRidesAsPassenger)
            userProfileObject.setValue(userProfile.numberOfRidesAsRider, forKey: numberOfRidesAsRider)
            userProfileObject.setValue(userProfile.matchCompanyConstraint, forKey: matchCompanyConstraint)
            userProfileObject.setValue(userProfile.matchGenderConstraint, forKey: matchGenderConstraint)
            userProfileObject.setValue(userProfile.companyName, forKey: companyName)
            userProfileObject.setValue(userProfile.profession, forKey: profession)
            userProfileObject.setValue(userProfile.aboutMe, forKey: aboutMe)
            userProfileObject.setValue(userProfile.email, forKey: email)
            userProfileObject.setValue(userProfile.emailForCommunication, forKey: emailForCommunication)
            userProfileObject.setValue(userProfile.imageURI, forKey: imageURI)
            userProfileObject.setValue(userProfile.facebook, forKey: facebook)
            userProfileObject.setValue(userProfile.linkedin, forKey: linkedin)
            userProfileObject.setValue(userProfile.twitter, forKey: twitter)
            userProfileObject.setValue(userProfile.rideMatchPercentageAsRider, forKey: rideMatchPercentageAsRider_key)
            userProfileObject.setValue(userProfile.rideMatchPercentageAsPassenger, forKey: rideMatchPercentageAsPassenger_key)
            userProfileObject.setValue(userProfile.supportCall, forKey: supportCall_key)
            userProfileObject.setValue(userProfile.companyCode, forKey: companyCode)
            userProfileObject.setValue(userProfile.gender, forKey: gender)
            userProfileObject.setValue(userProfile.matchGroupCompaniesConstraint, forKey: matchGroupCompaniesConstraint)
            userProfileObject.setValue(userProfile.emergencyContactNumber, forKey: emergencyContactNumber)
            userProfileObject.setValue(userProfile.noOfReviews, forKey: noOfReviews)
            userProfileObject.setValue(userProfile.preferredRole, forKey: preferredRole)
            userProfileObject.setValue(userProfile.preferredVehicle, forKey: preferredVehicle)
            userProfileObject.setValue(userProfile.roleAtSignup, forKey: roleAtSignup)
            userProfileObject.setValue(userProfile.dateOfBirth, forKey: dateOfBirth)
            userProfileObject.setValue(userProfile.interests, forKey: interests)
            userProfileObject.setValue(userProfile.skills, forKey: skills)
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
        
    }
    
    static func getUserProfileObject() -> UserProfile?{
        AppDelegate.getAppDelegate().log.debug("getUserProfileObject()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userProfileTable)
        
        
        let userProfileObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        
        if userProfileObject != nil{
            let returnUserProfileObject = UserProfile()
            returnUserProfileObject.userId = userProfileObject!.value(forKey: userId) as! Double
            returnUserProfileObject.userName = userProfileObject!.value(forKey: userName) as? String
            if let confirmType = userProfileObject!.value(forKey: confirmType) as? Bool{
               returnUserProfileObject.confirmType = confirmType
            }
            if let verificationStatus = userProfileObject!.value(forKey: verificationStatus) as? Int{
                returnUserProfileObject.verificationStatus = verificationStatus
            }
            if let rating = userProfileObject!.value(forKey: rating) as? Double{
                returnUserProfileObject.rating = rating
            }
            if let numberOfRidesAsPassenger = userProfileObject!.value(forKey: numberOfRidesAsPassenger) as? Double{
                returnUserProfileObject.numberOfRidesAsPassenger = numberOfRidesAsPassenger
            }
            if let numberOfRidesAsRider = userProfileObject!.value(forKey: numberOfRidesAsRider) as? Double{
                returnUserProfileObject.numberOfRidesAsRider = numberOfRidesAsRider
            }
            if let matchCompanyConstraint = userProfileObject!.value(forKey: matchCompanyConstraint) as? Bool{
                returnUserProfileObject.matchCompanyConstraint = matchCompanyConstraint
            }
            if let matchGenderConstraint = userProfileObject!.value(forKey: matchGenderConstraint) as? Bool{
                returnUserProfileObject.matchGenderConstraint = matchGenderConstraint
            }
            
            if let companyName = userProfileObject!.value(forKey: companyName) as? String{
                returnUserProfileObject.companyName = companyName
            }
            if let profession = userProfileObject!.value(forKey: profession) as? String{
                returnUserProfileObject.profession = profession
            }
            if let email = userProfileObject!.value(forKey: email) as? String{
                returnUserProfileObject.email = email
            }
            if let emailForCommunication = userProfileObject!.value(forKey: emailForCommunication) as? String{
                returnUserProfileObject.emailForCommunication = emailForCommunication
            }
            
            if let imageURIObj = userProfileObject!.value(forKey: imageURI) as? String {
                returnUserProfileObject.imageURI = imageURIObj
            }
            if let facebook = userProfileObject!.value(forKey: facebook) as? String{
                returnUserProfileObject.facebook = facebook
            }
            if let linkedIn = userProfileObject!.value(forKey: linkedin) as? String{
                returnUserProfileObject.linkedin = linkedIn
            }
            if let twitter = userProfileObject!.value(forKey: twitter) as? String{
                returnUserProfileObject.twitter = twitter
            }
            if let rideMatchPercentageAsPassenger = userProfileObject!.value(forKey: rideMatchPercentageAsPassenger_key) as? Int{
                returnUserProfileObject.rideMatchPercentageAsPassenger = rideMatchPercentageAsPassenger
            }
            
            if let rideMatchPercentageAsRider = userProfileObject!.value(forKey: rideMatchPercentageAsRider_key) as? Int{
                returnUserProfileObject.rideMatchPercentageAsRider = rideMatchPercentageAsRider
            }
           
            if let supportCall = userProfileObject!.value(forKey: supportCall_key) as? String{
                returnUserProfileObject.supportCall = supportCall
            }
            returnUserProfileObject.companyCode = userProfileObject!.value(forKey: companyCode) as? String
            returnUserProfileObject.gender = userProfileObject!.value(forKey: gender) as? String
            
            if let matchGroupCompaniesConstraint = userProfileObject!.value(forKey: matchGroupCompaniesConstraint) as? Bool{
                returnUserProfileObject.matchGroupCompaniesConstraint = matchGroupCompaniesConstraint
            }
            
            returnUserProfileObject.emergencyContactNumber = userProfileObject!.value(forKey: emergencyContactNumber) as? String
            
            if let noOfReviews = userProfileObject!.value(forKey: noOfReviews) as? Int{
              returnUserProfileObject.noOfReviews = noOfReviews
            }
            returnUserProfileObject.preferredRole = userProfileObject!.value(forKey: preferredRole) as? String
            returnUserProfileObject.preferredVehicle = userProfileObject!.value(forKey: preferredVehicle) as? String
            if let roleAtSignup = userProfileObject!.value(forKey: roleAtSignup) as? String{
                returnUserProfileObject.roleAtSignup = roleAtSignup
            }
            returnUserProfileObject.dateOfBirth = userProfileObject!.value(forKey: dateOfBirth) as? Double
            returnUserProfileObject.interests = userProfileObject!.value(forKey: interests) as? String
            returnUserProfileObject.skills = userProfileObject!.value(forKey: skills) as? String
            return returnUserProfileObject
        }
        return nil
    }
    
    static func saveVehicleObject(vehicle : Vehicle){
        AppDelegate.getAppDelegate().log.debug("saveVehicleObject()")
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            let entity = NSEntityDescription.entity(forEntityName: vehicleTable, in: managedContext)
            let vehicleManagedObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            vehicleManagedObject.setValue(vehicle.vehicleId, forKey: vehicleId)
            vehicleManagedObject.setValue(NSNumber(value:vehicle.ownerId), forKey: ownerId)
            vehicleManagedObject.setValue(vehicle.registrationNumber, forKey: registrationNumber)
            vehicleManagedObject.setValue(vehicle.capacity, forKey: capacity)
            vehicleManagedObject.setValue(vehicle.fare, forKey: fare)
            vehicleManagedObject.setValue(vehicle.imageURI, forKey: imageURI)
            vehicleManagedObject.setValue(vehicle.vehicleModel, forKey: vehicleModel)
            vehicleManagedObject.setValue(vehicle.vehicleType, forKey: vehicleType)
            vehicleManagedObject.setValue(vehicle.status, forKey: status)
            vehicleManagedObject.setValue(vehicle.makeAndCategory, forKey: makeAndCategory)
            vehicleManagedObject.setValue(vehicle.additionalFacilities, forKey: additionalFacilities)
            vehicleManagedObject.setValue(vehicle.defaultVehicle, forKey: defaultVehicle)
            vehicleManagedObject.setValue(vehicle.riderHasHelmet, forKey: riderHasHelmet)
            vehicleManagedObject.setValue(vehicle.status, forKey: status)
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
        
    }
    
    static func updateVehicleObject(vehicle : Vehicle){
        
        AppDelegate.getAppDelegate().log.debug("updateVehicleObject()")
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:vehicleTable)
            fetchRequest.predicate = NSPredicate(format: "\(vehicleId) = %@", argumentArray: [vehicle.vehicleId])
            
            if let vehicleManagedObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest){
                vehicleManagedObject.setValue(vehicle.vehicleId, forKey: vehicleId)
                vehicleManagedObject.setValue(NSNumber(value:vehicle.ownerId), forKey: ownerId)
                vehicleManagedObject.setValue(vehicle.capacity, forKey: capacity)
                vehicleManagedObject.setValue(vehicle.fare, forKey: fare)
                vehicleManagedObject.setValue(vehicle.imageURI, forKey: imageURI)
                vehicleManagedObject.setValue(vehicle.vehicleModel, forKey: vehicleModel)
                vehicleManagedObject.setValue(vehicle.vehicleType, forKey: vehicleType)
                vehicleManagedObject.setValue(vehicle.registrationNumber, forKey: registrationNumber)
                vehicleManagedObject.setValue(vehicle.makeAndCategory, forKey: makeAndCategory)
                vehicleManagedObject.setValue(vehicle.additionalFacilities, forKey: additionalFacilities)
                vehicleManagedObject.setValue(vehicle.defaultVehicle, forKey: defaultVehicle)
                vehicleManagedObject.setValue(vehicle.riderHasHelmet, forKey: riderHasHelmet)
                vehicleManagedObject.setValue(vehicle.status, forKey: status)
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }
        }
    }
    
    static func getVehicleObject() -> [Vehicle]{
        AppDelegate.getAppDelegate().log.debug("getVehicleObject()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: vehicleTable)
        
        var userVehicles = [Vehicle]()
        let vehicleManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        
        if vehicleManagedObjects != nil && !vehicleManagedObjects!.isEmpty{
            for vehicleManagedObject in vehicleManagedObjects!{
                let returnVehicleObject = Vehicle()
                if let registrationNumber = vehicleManagedObject.value(forKey: registrationNumber) as? String {
                  returnVehicleObject.registrationNumber = registrationNumber
                }
                if let capacity = vehicleManagedObject.value(forKey: capacity) as? Int {
                    returnVehicleObject.capacity = capacity
                }
                if let fare = vehicleManagedObject.value(forKey: fare) as? Double {
                    returnVehicleObject.fare = fare
                }
                if let vehicleId = vehicleManagedObject.value(forKey: vehicleId) as? Double {
                    returnVehicleObject.vehicleId = vehicleId
                }
                if let ownerId = vehicleManagedObject.value(forKey: ownerId) as? Double {
                    returnVehicleObject.ownerId = ownerId
                }
                returnVehicleObject.imageURI = vehicleManagedObject.value(forKey: imageURI) as? String
                if let vehicleModel = vehicleManagedObject.value(forKey: vehicleModel) as? String {
                    returnVehicleObject.vehicleModel = vehicleModel
                }
                returnVehicleObject.vehicleType = vehicleManagedObject.value(forKey: vehicleType) as? String
                 returnVehicleObject.makeAndCategory = vehicleManagedObject.value(forKey: makeAndCategory) as? String
                 returnVehicleObject.additionalFacilities = vehicleManagedObject.value(forKey: additionalFacilities) as? String
                if let defaultVehicle = vehicleManagedObject.value(forKey: defaultVehicle) as? Bool {
                    returnVehicleObject.defaultVehicle = defaultVehicle
                }
                if let riderHasHelmet = vehicleManagedObject.value(forKey: riderHasHelmet) as? Bool {
                    returnVehicleObject.riderHasHelmet = riderHasHelmet
                }
                if let status = vehicleManagedObject.value(forKey: status) as? String {
                    returnVehicleObject.status = status
                }
                userVehicles.append(returnVehicleObject)
            }
        }
        return userVehicles
    }
    
    static func saveUserObject(userObject : User){
        AppDelegate.getAppDelegate().log.debug("saveUserObject()")
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform  {
            let entity = NSEntityDescription.entity(forEntityName: userTable, in: managedContext)
            let user = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            user.setValue(userObject.creationDate, forKey: creationDate)
            user.setValue(userObject.referralCode, forKey: referralCode)
            user.setValue(userObject.status, forKey: status)
            user.setValue(userObject.gender, forKey: gender)
            user.setValue(userObject.password, forKey: password)
            user.setValue(userObject.userName, forKey: userName)
            user.setValue(userObject.phoneNumber, forKey: phoneNumber)
            user.setValue(userObject.clientIosKey, forKey: clientIosKey)
            user.setValue(userObject.appliedPromoCode, forKey: appliedPromoCode)
            user.setValue(userObject.clientUniqueDeviceId, forKey: clientUniqueDeviceId)
            user.setValue(userObject.appName, forKey: appName)
            user.setValue(userObject.contactNo, forKey: contactNo)
            user.setValue(userObject.iosAppVersionName, forKey: iosAppVersionName)
            user.setValue(userObject.email, forKey: email)
            user.setValue(userObject.primaryArea, forKey: primaryArea)
            user.setValue(userObject.primaryAreaLat, forKey: primaryAreaLat)
            user.setValue(userObject.primaryAreaLng, forKey: primaryAreaLng)
            user.setValue(userObject.primaryRegion, forKey: primaryRegion)
            user.setValue(userObject.phoneModel, forKey: phoneModel)
            user.setValue(userObject.countryCode, forKey: countryCode)
            user.setValue(userObject.uniqueDeviceId, forKey: uniqueDeviceId)
            user.setValue(userObject.asksCashTransactions, forKey: asksCashTransactions)
            user.setValue(userObject.subscriptionStatus , forKey: subscriptionStatus)
            user.setValue(userObject.freeRideId, forKey: freeRideId)
            user.setValue(userObject.alternateContactNo, forKey: alternateContactNo)
            user.setValue(userObject.pickupOTP, forKey: pickupOTP)
            
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
    
    static func updateUserObject(userObject : User){
        
        AppDelegate.getAppDelegate().log.debug("updateVehicleObject()")
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:userTable)
            fetchRequest.predicate = NSPredicate(format: "\(phoneNumber) = %@", argumentArray: [userObject.phoneNumber])
            
            if let user = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest){
                user.setValue(userObject.creationDate, forKey: creationDate)
                user.setValue(userObject.referralCode, forKey: referralCode)
                user.setValue(userObject.status, forKey: status)
                user.setValue(userObject.gender, forKey: gender)
                user.setValue(userObject.password, forKey: password)
                user.setValue(userObject.userName, forKey: userName)
                user.setValue(userObject.phoneNumber, forKey: phoneNumber)
                user.setValue(userObject.clientIosKey, forKey: clientIosKey)
                user.setValue(userObject.appliedPromoCode, forKey: appliedPromoCode)
                user.setValue(userObject.clientUniqueDeviceId, forKey: clientUniqueDeviceId)
                user.setValue(userObject.appName, forKey: appName)
                user.setValue(userObject.contactNo, forKey: contactNo)
                user.setValue(userObject.iosAppVersionName, forKey: iosAppVersionName)
                user.setValue(userObject.email, forKey: email)
                user.setValue(userObject.primaryArea, forKey: primaryArea)
                user.setValue(userObject.primaryAreaLat, forKey: primaryAreaLat)
                user.setValue(userObject.primaryAreaLng, forKey: primaryAreaLng)
                user.setValue(userObject.primaryRegion, forKey: primaryRegion)
                user.setValue(userObject.phoneModel, forKey: phoneModel)
                user.setValue(userObject.countryCode, forKey: countryCode)
                user.setValue(userObject.uniqueDeviceId, forKey: uniqueDeviceId)
                user.setValue(userObject.asksCashTransactions, forKey: asksCashTransactions)
                user.setValue(userObject.subscriptionStatus , forKey: subscriptionStatus)
                user.setValue(userObject.freeRideId, forKey: freeRideId)
                user.setValue(userObject.alternateContactNo, forKey: alternateContactNo)
                user.setValue(userObject.pickupOTP, forKey: pickupOTP)
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }
        }
    }
    
    static func saveProfileVerificationObject(profileVerification : ProfileVerificationData){
        
        AppDelegate.getAppDelegate().log.debug("saveProfileVerificationObject()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform{
            let entity = NSEntityDescription.entity(forEntityName: profileVerificationData, in: managedContext)
            let profileVerificationManagedObject = NSManagedObject(entity: entity!, insertInto: managedContext)

            profileVerificationManagedObject.setValue(profileVerification.userId , forKey: userId)
            profileVerificationManagedObject.setValue(profileVerification.emailVerified, forKey: emailVerified)
            profileVerificationManagedObject.setValue(profileVerification.imageVerified, forKey: imageVerified)
            profileVerificationManagedObject.setValue(profileVerification.profileVerified, forKey: profileVerified)
            
            profileVerificationManagedObject.setValue(profileVerification.persIDVerified , forKey: persIDVerified)
            profileVerificationManagedObject.setValue(profileVerification.profVerifSource, forKey: profVerifSource)
            profileVerificationManagedObject.setValue(profileVerification.persVerifSource, forKey: persVerifSource)
            profileVerificationManagedObject.setValue(profileVerification.emailVerifiedAtleastOnce, forKey: emailVerifiedAtleastOnce)
            profileVerificationManagedObject.setValue(profileVerification.noOfEndorsers, forKey: noOfEndorsers)
            profileVerificationManagedObject.setValue(profileVerification.emailVerificationStatus, forKey: emailVerificationStatus)
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
        
    }
    static func getProfileVerificationObject() -> ProfileVerificationData?{
        AppDelegate.getAppDelegate().log.debug("getProfileVerificationObject()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: profileVerificationData)
        
        
        let profileVerificationManagedObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        if profileVerificationManagedObject != nil{
            let returnProfileVerificationDataObject = ProfileVerificationData()
            returnProfileVerificationDataObject.userId = profileVerificationManagedObject!.value(forKey: userId) as? Double
            if let emailVerified = profileVerificationManagedObject!.value(forKey: emailVerified) as? Bool{
               returnProfileVerificationDataObject.emailVerified = emailVerified
            }
            if let imageVerified = profileVerificationManagedObject!.value(forKey: imageVerified) as? Bool{
                returnProfileVerificationDataObject.imageVerified = imageVerified
            }
            if let profileVerified = profileVerificationManagedObject!.value(forKey: profileVerified) as? Bool{
                returnProfileVerificationDataObject.profileVerified = profileVerified
            }
            if let persIDVerified = profileVerificationManagedObject!.value(forKey: persIDVerified) as? Bool{
                returnProfileVerificationDataObject.persIDVerified = persIDVerified
            }
            if let profVerifSource = profileVerificationManagedObject!.value(forKey: profVerifSource) as? Int{
                returnProfileVerificationDataObject.profVerifSource = profVerifSource
            }
            if let persVerifSource = profileVerificationManagedObject!.value(forKey: persVerifSource) as? String{
                returnProfileVerificationDataObject.persVerifSource = persVerifSource
            }
            if let emailVerifiedAtleastOnce = profileVerificationManagedObject!.value(forKey: persVerifSource) as? Bool{
                returnProfileVerificationDataObject.emailVerifiedAtleastOnce = emailVerifiedAtleastOnce
            }
            if let noOfEndorsers = profileVerificationManagedObject!.value(forKey: noOfEndorsers) as? Int{
                returnProfileVerificationDataObject.noOfEndorsers = noOfEndorsers
            }
            if let emailVerificationStatus = profileVerificationManagedObject!.value(forKey: emailVerificationStatus) as? String{
                returnProfileVerificationDataObject.emailVerificationStatus = emailVerificationStatus
            }
            return returnProfileVerificationDataObject
        }
        return nil
    }
    static func getUserObject() -> User?{
        AppDelegate.getAppDelegate().log.debug("getUserObject()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userTable)
        
        
        let userManagedObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObject != nil {
            let returnUserObject = User()
            if let clientUniqueDeviceId = userManagedObject!.value(forKey: clientUniqueDeviceId) as? String {
              returnUserObject.clientUniqueDeviceId = clientUniqueDeviceId
            }
            if let creationDate = userManagedObject!.value(forKey: creationDate) as? Double {
                returnUserObject.creationDate = creationDate
            }
            if let gender = userManagedObject!.value(forKey: gender) as? String {
                returnUserObject.gender = gender
            }
            if let password = userManagedObject!.value(forKey: password) as? String {
                returnUserObject.password = password
            }
            if let phoneNumber = userManagedObject!.value(forKey: phoneNumber) as? Double {
                returnUserObject.phoneNumber = phoneNumber
            }
            if let referralCode = userManagedObject!.value(forKey: referralCode) as? String {
                returnUserObject.referralCode = referralCode
            }
            if let status = userManagedObject!.value(forKey: status) as? String {
                returnUserObject.status = status
            }
            if let userName = userManagedObject!.value(forKey: userName) as? String {
                returnUserObject.userName = userName
            }
            if let clientIosKey = userManagedObject!.value(forKey: clientIosKey) as? String {
                returnUserObject.clientIosKey = clientIosKey
            }
            
           
            
            returnUserObject.appliedPromoCode = userManagedObject!.value(forKey: appliedPromoCode) as? String
            returnUserObject.appName = userManagedObject!.value(forKey: appName) as? String
            returnUserObject.contactNo = userManagedObject!.value(forKey: contactNo) as? Double
            returnUserObject.iosAppVersionName = userManagedObject!.value(forKey: iosAppVersionName) as? String
            returnUserObject.email = userManagedObject!.value(forKey: email) as? String
            returnUserObject.primaryArea = userManagedObject!.value(forKey: primaryArea) as? String
            if let primaryAreaLat = userManagedObject!.value(forKey: primaryAreaLat) as? Double{
                returnUserObject.primaryAreaLat = primaryAreaLat
            }
            if let primaryAreaLng = userManagedObject!.value(forKey: primaryAreaLng) as? Double{
                returnUserObject.primaryAreaLng = primaryAreaLng
            }
            returnUserObject.primaryRegion = userManagedObject!.value(forKey: primaryRegion) as? String
            returnUserObject.phoneModel = userManagedObject!.value(forKey: phoneModel) as? String
            returnUserObject.countryCode = userManagedObject!.value(forKey: clientIosKey) as? String
            returnUserObject.uniqueDeviceId = userManagedObject!.value(forKey: uniqueDeviceId) as? String
            
            if let asksCashTransactions = userManagedObject!.value(forKey: asksCashTransactions) as? Bool{
              returnUserObject.asksCashTransactions = asksCashTransactions
            }
            
            if let subscriptionStatus = userManagedObject!.value(forKey: subscriptionStatus) as? String{
                returnUserObject.subscriptionStatus = subscriptionStatus
            }
            
            if let asksCashTransactions = userManagedObject!.value(forKey: asksCashTransactions) as? Bool{
                returnUserObject.asksCashTransactions = asksCashTransactions
            }
      
            if let freeRideId = userManagedObject!.value(forKey: freeRideId) as? Double {
                returnUserObject.freeRideId = freeRideId
            }
            
            returnUserObject.alternateContactNo = userManagedObject!.value(forKey: alternateContactNo) as? Double
            if let pickupOTP = userManagedObject!.value(forKey: pickupOTP) as? String {
                returnUserObject.pickupOTP = pickupOTP
            }
            return returnUserObject
        }
        return nil
    }
    
    static func saveAccountObject(account : Account){
        
        AppDelegate.getAppDelegate().log.debug("saveAccountObject()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform{
            let entity = NSEntityDescription.entity(forEntityName: accountTable, in: managedContext)
            let accountManagedObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            accountManagedObject.setValue(account.userId , forKey: userId)
            accountManagedObject.setValue(account.status, forKey: status)
            accountManagedObject.setValue(account.reserved, forKey: reserved)
            accountManagedObject.setValue(account.balance, forKey: balance)
            accountManagedObject.setValue(account.earnedPoints, forKey: earnedPoints)
            accountManagedObject.setValue(account.rewardsPoints, forKey: rewardsPoints)
            accountManagedObject.setValue(account.purchasedPoints, forKey: purchasedPoints)
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
        
    }
    
    static func getAccountObject() -> Account?{
        AppDelegate.getAppDelegate().log.debug("getAccountObject()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: accountTable)
        
        
        let userManagedObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObject != nil{
            let returnAccountObject = Account()
            returnAccountObject.balance = userManagedObject!.value(forKey: balance) as? Double
            returnAccountObject.reserved = userManagedObject!.value(forKey: reserved) as? Double
            returnAccountObject.status = userManagedObject!.value(forKey: status) as? String
            returnAccountObject.userId = userManagedObject!.value(forKey: userId) as? Double
            if let earnedPoints = userManagedObject!.value(forKey: earnedPoints) as? Double{
               returnAccountObject.earnedPoints = earnedPoints
            }
            if let rewardPoints = userManagedObject!.value(forKey: rewardsPoints) as? Double{
                returnAccountObject.rewardsPoints = rewardPoints
            }
            if let purchasedPoints = userManagedObject!.value(forKey: purchasedPoints) as? Double{
                returnAccountObject.purchasedPoints = purchasedPoints
            }
            return returnAccountObject
        }
        return nil
    }
    
    static func storePreferredRidePartner(preferredRidePartner : PreferredRidePartner){
        AppDelegate.getAppDelegate().log.debug("storePreferredRidePartner()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform{
            let entity = NSEntityDescription.entity(forEntityName: userFavouritePartnerTable, in: managedContext)
            let preferredRidePartnerObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            preferredRidePartnerObject.setValue(preferredRidePartner.id , forKey: id)
            preferredRidePartnerObject.setValue(preferredRidePartner.userId, forKey: userId)
            preferredRidePartnerObject.setValue(preferredRidePartner.favouritePartnerUserId, forKey: favouritePartnerUserId)
            preferredRidePartnerObject.setValue(preferredRidePartner.imageUri, forKey: imageURI)
            preferredRidePartnerObject.setValue(preferredRidePartner.gender, forKey: gender)
            preferredRidePartnerObject.setValue(preferredRidePartner.name, forKey: name)
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
    
    static func getPreferredRidePartners(usrId : Double) -> [PreferredRidePartner]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userFavouritePartnerTable)
        
        let predicate = NSPredicate(format: "\(userId) == %@", argumentArray: [usrId])
        fetchRequest.predicate = predicate
        
        var preferredRidePartners  = [PreferredRidePartner]()
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                let preferredRidePartnerObject = PreferredRidePartner()
                preferredRidePartnerObject.id = userManagedObject.value(forKey: id) as? Double
                preferredRidePartnerObject.userId = userManagedObject.value(forKey: userId) as? Double
                preferredRidePartnerObject.favouritePartnerUserId = userManagedObject.value(forKey: favouritePartnerUserId) as? Double
                preferredRidePartnerObject.imageUri = userManagedObject.value(forKey: imageURI) as? String
                preferredRidePartnerObject.gender = userManagedObject.value(forKey: gender) as? String
                preferredRidePartnerObject.name = userManagedObject.value(forKey: name) as? String
                preferredRidePartners.append(preferredRidePartnerObject)
            }
        }
        
        return preferredRidePartners
    }
    
    static func storeUserRouteGroup(userRouteGroup : UserRouteGroup){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform{
            let entity = NSEntityDescription.entity(forEntityName: userRouteGroupTable, in: managedContext)
            let userRouteGroupObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            userRouteGroupObject.setValue(userRouteGroup.id, forKey: id)
            userRouteGroupObject.setValue(userRouteGroup.groupName, forKey: groupName)
            userRouteGroupObject.setValue(userRouteGroup.creatorId, forKey: creatorId)
            userRouteGroupObject.setValue(userRouteGroup.fromLocationAddress, forKey: fromLocationAddress)
            userRouteGroupObject.setValue(userRouteGroup.toLocationAddress, forKey: toLocationAddress)
            userRouteGroupObject.setValue(userRouteGroup.fromLocationLatitude, forKey: fromLocationLatitude)
            userRouteGroupObject.setValue(userRouteGroup.fromLocationLongitude, forKey: fromLocationLongitude)
            userRouteGroupObject.setValue(userRouteGroup.toLocationLatitude, forKey: toLocationLatitude)
            userRouteGroupObject.setValue(userRouteGroup.toLocationLongitude, forKey: toLocationLongitude)
            userRouteGroupObject.setValue(userRouteGroup.imageURI, forKey: imageURI)
            userRouteGroupObject.setValue(userRouteGroup.memberCount, forKey: memberCount)
            userRouteGroupObject.setValue(userRouteGroup.appName, forKey: appName)
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
    
    static func getUserRouteGroups(usrId : Double) -> [UserRouteGroup]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userRouteGroupTable)
        
        let predicate = NSPredicate(format: "\(creatorId) == %@", argumentArray: [usrId])
        fetchRequest.predicate = predicate
        
        var userRouteGroups = [UserRouteGroup]()
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                let userRouteGroupObject = UserRouteGroup()
                userRouteGroupObject.id = userManagedObject.value(forKey: id) as? Double
                userRouteGroupObject.groupName = userManagedObject.value(forKey: groupName) as? String
                userRouteGroupObject.creatorId = userManagedObject.value(forKey: creatorId) as? Double
                userRouteGroupObject.fromLocationAddress = userManagedObject.value(forKey: fromLocationAddress) as? String
                userRouteGroupObject.toLocationAddress = userManagedObject.value(forKey: toLocationAddress) as? String
                userRouteGroupObject.fromLocationLatitude = userManagedObject.value(forKey: fromLocationLatitude) as? Double
                userRouteGroupObject.fromLocationLongitude = userManagedObject.value(forKey: fromLocationLongitude) as? Double
                userRouteGroupObject.toLocationLatitude = userManagedObject.value(forKey: toLocationLatitude) as? Double
                userRouteGroupObject.toLocationLongitude = userManagedObject.value(forKey: toLocationLongitude) as? Double
                userRouteGroupObject.imageURI = userManagedObject.value(forKey: imageURI) as? String
                userRouteGroupObject.memberCount = userManagedObject.value(forKey: memberCount) as? Int
                userRouteGroupObject.appName = userManagedObject.value(forKey: appName) as? String
                userRouteGroupObject.groupName = userManagedObject.value(forKey: groupName) as? String
                userRouteGroups.append(userRouteGroupObject)
            }
        }
        
        return userRouteGroups
    }
    
    static func storeUserGroups(userGroup : Group){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform{
            let entity = NSEntityDescription.entity(forEntityName: userGroupTable, in: managedContext)
            let userGroupObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            userGroupObject.setValue(userGroup.id, forKey: id)
            userGroupObject.setValue(userGroup.name, forKey: name)
            userGroupObject.setValue(userGroup.description, forKey: description)
            userGroupObject.setValue(userGroup.type, forKey: type)
            userGroupObject.setValue(userGroup.creatorId, forKey: creatorId)
            userGroupObject.setValue(userGroup.category, forKey: category)
            userGroupObject.setValue(userGroup.imageURI, forKey: imageURI)
            userGroupObject.setValue(userGroup.url, forKey: url)
            userGroupObject.setValue(userGroup.creationTime, forKey: creationTime)
            userGroupObject.setValue(userGroup.currentUserStatus, forKey: currentUserStatus)
            userGroupObject.setValue(userGroup.requestedUserId, forKey: requestedUserId)
            userGroupObject.setValue(userGroup.latitude, forKey: latitude)
            userGroupObject.setValue(userGroup.longitude, forKey: longitude)
            userGroupObject.setValue(userGroup.address, forKey: address)
            userGroupObject.setValue(userGroup.lastRefreshedTime, forKey: lastRefreshedTime)
            userGroupObject.setValue(userGroup.companyCode, forKey: companyCode)
            for member in userGroup.members{
                storeUserGroupMember(groupMember: member)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
    
    static func storeUserGroupMember(groupMember : GroupMember){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform{
            let entity = NSEntityDescription.entity(forEntityName: userGroupMembersTable, in: managedContext)
            let userGroupMemberObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            userGroupMemberObject.setValue(groupMember.id, forKey: id)
            userGroupMemberObject.setValue(groupMember.userId, forKey: userId)
            userGroupMemberObject.setValue(groupMember.groupId, forKey: groupId)
            userGroupMemberObject.setValue(groupMember.groupName, forKey: groupName)
            userGroupMemberObject.setValue(groupMember.type, forKey: type)
            userGroupMemberObject.setValue(groupMember.status, forKey: status)
            userGroupMemberObject.setValue(groupMember.requestedUserId, forKey: requestedUserId)
            userGroupMemberObject.setValue(groupMember.gender, forKey: gender)
            userGroupMemberObject.setValue(groupMember.imageURI, forKey: imageURI)
            userGroupMemberObject.setValue(groupMember.userName, forKey: userName)
            userGroupMemberObject.setValue(groupMember.supportCall, forKey: supportCall_key)
            userGroupMemberObject.setValue(groupMember.verificationStatus, forKey: verificationStatus)
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
    
    static func getUserGroups(usrId : Double)->[Group]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userGroupTable)
        
        let predicate = NSPredicate(format: "\(creatorId) == %@", argumentArray: [usrId])
        fetchRequest.predicate = predicate
        
        var userGroups = [Group]()
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                let userGroupObject = Group()
                if let id = userManagedObject.value(forKey: id) as? Double{
                  userGroupObject.id = id
                }
                userGroupObject.name = userManagedObject.value(forKey: name) as? String
                userGroupObject.description = userManagedObject.value(forKey: description) as? String
                if let type = userManagedObject.value(forKey: type) as? String{
                    userGroupObject.type = type
                }
                if let creatorId = userManagedObject.value(forKey: creatorId) as? Double{
                    userGroupObject.creatorId = creatorId
                }
                if let category = userManagedObject.value(forKey: category) as? String{
                    userGroupObject.category = category
                }
                userGroupObject.imageURI = userManagedObject.value(forKey: imageURI) as? String
                userGroupObject.url = userManagedObject.value(forKey: url) as? String
                if let creationTime = userManagedObject.value(forKey: creationTime) as? Double{
                    userGroupObject.creationTime = creationTime
                }
                userGroupObject.currentUserStatus = userManagedObject.value(forKey: currentUserStatus) as? String
                if let requestedUserId = userManagedObject.value(forKey: requestedUserId) as? Double{
                    userGroupObject.requestedUserId = requestedUserId
                }
                
                if let latitude = userManagedObject.value(forKey: latitude) as? Double{
                    userGroupObject.latitude = latitude
                }
                
                if let longitude = userManagedObject.value(forKey: longitude) as? Double{
                    userGroupObject.longitude = longitude
                }
                userGroupObject.address = userManagedObject.value(forKey: address) as? String
                if let lastRefreshedTime = userManagedObject.value(forKey: lastRefreshedTime) as? NSDate{
                    userGroupObject.lastRefreshedTime = lastRefreshedTime
                }
                userGroupObject.companyCode = userManagedObject.value(forKey: companyCode) as? String
                userGroupObject.members = getUserGroupMembers(grpId: userGroupObject.id)
                userGroups.append(userGroupObject)
            }
        }
        
        return userGroups
    }
    
    static func getUserGroupMembers(grpId : Double) -> [GroupMember]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userGroupMembersTable)
        
        let predicate = NSPredicate(format: "\(groupId) == %@", argumentArray: [grpId])
        fetchRequest.predicate = predicate
        
        var groupMembers = [GroupMember]()
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                let groupMemberObject = GroupMember()
                
                if let id = userManagedObject.value(forKey: id) as? Double{
                   groupMemberObject.id = id
                }
                
                if let userId = userManagedObject.value(forKey: userId) as? Double{
                    groupMemberObject.userId = userId
                }
                
                if let groupId = userManagedObject.value(forKey: groupId) as? Double{
                    groupMemberObject.groupId = groupId
                }
                groupMemberObject.groupName = userManagedObject.value(forKey: groupName) as? String
                groupMemberObject.type = userManagedObject.value(forKey: type) as? String
                groupMemberObject.status = userManagedObject.value(forKey: status) as? String
                groupMemberObject.requestedUserId = userManagedObject.value(forKey: requestedUserId) as? Double
                groupMemberObject.gender = userManagedObject.value(forKey: gender) as? String
                groupMemberObject.imageURI = userManagedObject.value(forKey: imageURI) as? String
                groupMemberObject.userName = userManagedObject.value(forKey: userName) as? String
                if let verificationStatus = userManagedObject.value(forKey: verificationStatus) as? Bool{
                    groupMemberObject.verificationStatus = verificationStatus
                }
                groupMembers.append(groupMemberObject)
            }
        }
        
        return groupMembers
    }
    
    static func saveBlockedUsers(blockedUsers : [BlockedUser]){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform{
            for blockedUser in blockedUsers{
                let entity = NSEntityDescription.entity(forEntityName: blockedUserTable, in: managedContext)
                let blockedUserObject = NSManagedObject(entity: entity!, insertInto: managedContext)
                blockedUserObject.setValue(blockedUser.id, forKey: id)
                blockedUserObject.setValue(blockedUser.userId, forKey: userId)
                blockedUserObject.setValue(blockedUser.blockedUserId, forKey: blockedUserId)
                blockedUserObject.setValue(blockedUser.imageUri, forKey: imageURI)
                blockedUserObject.setValue(blockedUser.gender, forKey: gender)
                blockedUserObject.setValue(blockedUser.name, forKey: name)
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }
        }
    }
    
    static func getAllBlockedUsers(userid : Double) -> [BlockedUser]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: blockedUserTable)
        fetchRequest.predicate = NSPredicate(format: "\(userId) == %@", argumentArray: [userid])
        
        var blockedUsers = [BlockedUser]()
        
        let blockedUserObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if blockedUserObjects != nil{
            for blockedUserObject in blockedUserObjects!{
                let blockedUserObj = BlockedUser()
                blockedUserObj.id = blockedUserObject.value(forKey: id) as? Double
                blockedUserObj.userId = blockedUserObject.value(forKey: userId) as? Double
                blockedUserObj.gender = blockedUserObject.value(forKey: gender) as? String
                blockedUserObj.imageUri = blockedUserObject.value(forKey: imageURI) as? String
                blockedUserObj.blockedUserId = blockedUserObject.value(forKey: blockedUserId) as? Double
                blockedUserObj.name = blockedUserObject.value(forKey: name) as? String
                blockedUsers.append(blockedUserObj)
            }
        }
        
        return blockedUsers
        
    }
    
    static func deleteBlockedUser(blockedUserid : Double){
        AppDelegate.getAppDelegate().log.debug("deletePreferredRidePartner()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        // make the call async
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: blockedUserTable)
        let predicate = NSPredicate(format: "\(blockedUserId) == %@", argumentArray: [blockedUserid])
        fetchRequest.predicate = predicate
        do {
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do{
                try managedContext.execute(deleteRequest)
            }catch{
                AppDelegate.getAppDelegate().log.error("failed batch delete : \(error)")
                clearRecordByRecord(fetchRequest: fetchRequest)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }catch let error as NSError{
            AppDelegate.getAppDelegate().log.debug("Fetch Failed : \(error.localizedDescription)")
        }
        
    }
    
    static func deletePreferredRidePartner(preferredRidePartner : PreferredRidePartner){
        AppDelegate.getAppDelegate().log.debug("deletePreferredRidePartner()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        // make the call async
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userFavouritePartnerTable)
        let predicate = NSPredicate(format: "\(favouritePartnerUserId) == %@", argumentArray: [preferredRidePartner.favouritePartnerUserId!])
        fetchRequest.predicate = predicate
        do {
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do{
                try managedContext.execute(deleteRequest)
            }catch{
                AppDelegate.getAppDelegate().log.error("failed batch delete : \(error)")
                clearRecordByRecord(fetchRequest: fetchRequest)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }catch let error as NSError{
            AppDelegate.getAppDelegate().log.debug("Fetch Failed : \(error.localizedDescription)")
        }
        
    }
    
    static func deleteRouteGroup(userRouteGroup : UserRouteGroup){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        // make the call async
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userRouteGroupTable)
        let predicate = NSPredicate(format: "\(id) == %@", argumentArray: [userRouteGroup.id!])
        fetchRequest.predicate = predicate
        do {
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do{
                try managedContext.execute(deleteRequest)
            }catch{
                AppDelegate.getAppDelegate().log.error("failed batch delete : \(error)")
                clearRecordByRecord(fetchRequest: fetchRequest)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }catch let error as NSError{
            AppDelegate.getAppDelegate().log.debug("Fetch Failed : \(error.localizedDescription)")
        }
        
    }
    
    static func deleteUserGroup(Group : Group){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        // make the call async
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userGroupTable)
        let predicate = NSPredicate(format: "\(id) == %@", argumentArray: [Group.id])
        fetchRequest.predicate = predicate
        do {
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do{
                try managedContext.execute(deleteRequest)
            }catch{
                AppDelegate.getAppDelegate().log.error("failed batch delete : \(error)")
                clearRecordByRecord(fetchRequest: fetchRequest)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }catch let error as NSError{
            AppDelegate.getAppDelegate().log.debug("Fetch Failed : \(error.localizedDescription)")
        }
        deleteGroupMembers(groupid: Group.id)
    }
    
    static func deleteGroupMembers(groupid : Double){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        // make the call async
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userGroupMembersTable)
        let predicate = NSPredicate(format: "\(groupId) == %@", argumentArray: [groupid])
        fetchRequest.predicate = predicate
        do {
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do{
                try managedContext.execute(deleteRequest)
            }catch{
                AppDelegate.getAppDelegate().log.error("failed batch delete : \(error)")
                clearRecordByRecord(fetchRequest: fetchRequest)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }catch let error as NSError{
            AppDelegate.getAppDelegate().log.debug("Fetch Failed : \(error.localizedDescription)")
        }
    }
    
    static func storeLinkedWallet(linkedWallet : LinkedWallet){
        AppDelegate.getAppDelegate().log.debug("saveAccountObject()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform{
            let entity = NSEntityDescription.entity(forEntityName: linkedWalletTable, in: managedContext)
            let linkedWalletObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            linkedWalletObject.setValue(linkedWallet.userId , forKey: userId)
            linkedWalletObject.setValue(linkedWallet.type, forKey: type)
            linkedWalletObject.setValue(linkedWallet.email, forKey: email)
            linkedWalletObject.setValue(linkedWallet.key, forKey: key)
            linkedWalletObject.setValue(linkedWallet.custId, forKey: custId)
            linkedWalletObject.setValue(linkedWallet.mobileNo, forKey: mobileNo)
            linkedWalletObject.setValue(linkedWallet.token, forKey: token)
            linkedWalletObject.setValue(linkedWallet.defaultWallet, forKey: defaultWallet)
            linkedWalletObject.setValue(linkedWallet.status, forKey: linkedWalletStatus)
            
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
    
    static func getLinkedWallets() -> [LinkedWallet]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: linkedWalletTable)
        
        var linkedWallets = [LinkedWallet]()
        
        let linkedWalletObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if linkedWalletObjects != nil{
            for linkedWalletObject in linkedWalletObjects!{
                let linkedWallet = LinkedWallet()
                linkedWallet.userId = linkedWalletObject.value(forKey: userId) as? Double
                linkedWallet.type = linkedWalletObject.value(forKey: type) as? String
                linkedWallet.email = linkedWalletObject.value(forKey: email) as? String
                linkedWallet.key = linkedWalletObject.value(forKey: key) as? String
                linkedWallet.custId = linkedWalletObject.value(forKey: custId) as? String
                linkedWallet.mobileNo = linkedWalletObject.value(forKey: mobileNo) as? String
                linkedWallet.token = linkedWalletObject.value(forKey: token) as? String
                linkedWallet.defaultWallet = linkedWalletObject.value(forKey: defaultWallet) as? Bool ?? false
                linkedWallet.status = linkedWalletObject.value(forKey: linkedWalletStatus) as? String
                linkedWallets.append(linkedWallet)
            }
        }
        
        return linkedWallets
    }
  
    static func deleteLinkedWallet(linkedWallet : LinkedWallet){
        AppDelegate.getAppDelegate().log.debug("deleteLinkedWallet()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        // make the call async
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: linkedWalletTable)
        let predicate = NSPredicate(format: "\(type) == %@", argumentArray: [linkedWallet.type!])
        fetchRequest.predicate = predicate
        do {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do{
                try managedContext.execute(deleteRequest)
            }catch{
                AppDelegate.getAppDelegate().log.error("failed batch delete : \(error)")
                clearRecordByRecord(fetchRequest: fetchRequest)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }catch let error as NSError{
            AppDelegate.getAppDelegate().log.debug("Fetch Failed : \(error.localizedDescription)")
        }
        
    }
    
    static func executeFetchResult(managedContext : NSManagedObjectContext, fetchRequest : NSFetchRequest<NSFetchRequestResult>) -> NSManagedObject?{
        AppDelegate.getAppDelegate().log.debug("executeFetchResult()")
        var fetchResults : [NSManagedObject] = [NSManagedObject]()
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            fetchResults = results as! [NSManagedObject]
            
        } catch let error as NSError {
            AppDelegate.getAppDelegate().log.error("Could not fetch \(error), \(error.userInfo)")
        }
        
        if fetchResults.count != 0{
            return fetchResults[(fetchResults.count - 1)]
        }else{
            return nil
        }
    }
    
    
    static func saveOrUpdateRecentSearchedLocation(location : Location){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            if let placeId = location.placeId, let recentSearchLocation = getRecentSearchedLocationForPlaceId(placeId: placeId){
               UserCoreDataHelper.updateRecentSearchedLocation(managedContext: managedContext, managedObject: recentSearchLocation, location: location)
            }else{
               UserCoreDataHelper.saveRecentSearchedLocation(managedContext: managedContext, location: location)
            }
        }
    }
    
    static func saveRecentSearchedLocation(managedContext : NSManagedObjectContext,location : Location){
        
        let managedEntity = NSEntityDescription.entity(forEntityName: userRecentSearchedLocation, in: managedContext)
        let managedObject = NSManagedObject(entity: managedEntity!, insertInto: managedContext)
        
        managedObject.setValue(location.name, forKey: NAME)
        managedObject.setValue(location.placeId, forKey: PLACE_ID)
        managedObject.setValue(location.latitude, forKey: LATITUDE)
        managedObject.setValue(location.longitude, forKey: LONGITUDE)
        managedObject.setValue(location.country, forKey: COUNTRY)
        managedObject.setValue(location.state, forKey: STATE)
        managedObject.setValue(location.city, forKey: CITY)
        managedObject.setValue(location.areaName, forKey: AREA_NAME)
        managedObject.setValue(location.streetName, forKey: STREET_NAME)
        managedObject.setValue(location.shortAddress, forKey: LOCATION_NAME)
        managedObject.setValue(location.completeAddress, forKey: FORMATTED_ADDRESS)
        managedObject.setValue(NSDate().getTimeStamp(), forKey: CREATION_DATE)
        managedObject.setValue(NSDate().getTimeStamp(), forKey: RECENT_USED_TIME)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userRecentSearchedLocation)
        let results = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if results != nil && results!.count > recent_searches_table_size{
            managedContext.delete(results![0])
        }
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }
    
    static func getRecentSearchedLocationForPlaceId(placeId : String) -> NSManagedObject?{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userRecentSearchedLocation)
        let predicate = NSPredicate(format: "\(PLACE_ID) == %@", argumentArray: [placeId])
        fetchRequest.predicate = predicate
        let userManagedObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        return userManagedObject
    }
    
    static func getRecentSearchedLocations(searchText : String) -> [Location]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userRecentSearchedLocation)
        let predicate = NSPredicate(format: "\(FORMATTED_ADDRESS) BEGINSWITH[c] %@ OR \(LOCATION_NAME) BEGINSWITH[c] %@", argumentArray: [searchText,searchText])
        let sortDescriptor = NSSortDescriptor(key: UserCoreDataHelper.RECENT_USED_TIME, ascending: false)
        var sortDescriptors = [NSSortDescriptor]()
        sortDescriptors.append(sortDescriptor)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        var returnRecentSearchedLocations  = [Location]()
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects! {
                let returnRecentSearchedLocationObject = Location()
                returnRecentSearchedLocationObject.name = userManagedObject.value(forKey: NAME) as? String
                returnRecentSearchedLocationObject.placeId = userManagedObject.value(forKey: PLACE_ID) as? String
                if let latitude = userManagedObject.value(forKey: LATITUDE) as? Double{
                    returnRecentSearchedLocationObject.latitude = latitude
                }
                if let longitude = userManagedObject.value(forKey: LONGITUDE) as? Double{
                    returnRecentSearchedLocationObject.longitude = longitude
                }

                returnRecentSearchedLocationObject.country = userManagedObject.value(forKey: COUNTRY) as? String
                returnRecentSearchedLocationObject.state = userManagedObject.value(forKey: STATE) as? String
                returnRecentSearchedLocationObject.city = userManagedObject.value(forKey: CITY) as? String
                returnRecentSearchedLocationObject.areaName = userManagedObject.value(forKey: AREA_NAME) as? String
                returnRecentSearchedLocationObject.streetName = userManagedObject.value(forKey: STREET_NAME) as? String
                returnRecentSearchedLocationObject.shortAddress = userManagedObject.value(forKey: LOCATION_NAME) as? String
                returnRecentSearchedLocationObject.completeAddress = userManagedObject.value(forKey: FORMATTED_ADDRESS) as? String
                if returnRecentSearchedLocations.count == 5{
                    break
                }
                returnRecentSearchedLocations.append(returnRecentSearchedLocationObject)
            }
        }
        return returnRecentSearchedLocations
    }
    
    
    
    static func updateRecentSearchedLocation(managedContext : NSManagedObjectContext, managedObject : NSManagedObject,location : Location){
        managedObject.setValue(location.name, forKey: NAME)
        managedObject.setValue(location.placeId, forKey: PLACE_ID)
        managedObject.setValue(location.latitude, forKey: LATITUDE)
        managedObject.setValue(location.longitude, forKey: LONGITUDE)
        managedObject.setValue(location.country, forKey: COUNTRY)
        managedObject.setValue(location.state, forKey: STATE)
        managedObject.setValue(location.city, forKey: CITY)
        managedObject.setValue(location.areaName, forKey: AREA_NAME)
        managedObject.setValue(location.streetName, forKey: STREET_NAME)
        managedObject.setValue(location.shortAddress, forKey: LOCATION_NAME)
        managedObject.setValue(location.completeAddress, forKey: FORMATTED_ADDRESS)
        managedObject.setValue(NSDate().getTimeStamp(), forKey: RECENT_USED_TIME)
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }
    static func saveNomineeDetails(nomineeDetails : NomineeDetails){
        
        AppDelegate.getAppDelegate().log.debug("saveRecentLocation()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform{
            let entity = NSEntityDescription.entity(forEntityName: nomineeDetailsTable, in: managedContext)
            let nomineeDetailsObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            nomineeDetailsObject.setValue(nomineeDetails.userId, forKey: userId)
            nomineeDetailsObject.setValue(nomineeDetails.nomineeName, forKey: nomineeName)
            nomineeDetailsObject.setValue(nomineeDetails.nomineeAge, forKey: nomineeAge)
            nomineeDetailsObject.setValue(nomineeDetails.nomineeRelation, forKey: nomineeRelation)
            nomineeDetailsObject.setValue(nomineeDetails.nomineeMobile, forKey: nomineeMobile)
            nomineeDetailsObject.setValue(nomineeDetails.creationDate, forKey: creationDate)
            
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
    
    static func getNomineeDetails() -> NomineeDetails?{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: nomineeDetailsTable)
        
        
        let nomineeDetailsObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        if nomineeDetailsObject != nil{
            let returnNomineeDetailsObject = NomineeDetails()
            returnNomineeDetailsObject.userId = nomineeDetailsObject!.value(forKey: userId) as? Double
            returnNomineeDetailsObject.nomineeName = nomineeDetailsObject!.value(forKey: nomineeName) as? String
            returnNomineeDetailsObject.nomineeAge = nomineeDetailsObject!.value(forKey: nomineeAge) as? Int
            returnNomineeDetailsObject.nomineeMobile = nomineeDetailsObject!.value(forKey: nomineeMobile) as? String
            returnNomineeDetailsObject.nomineeRelation = nomineeDetailsObject!.value(forKey: nomineeRelation) as? String
            returnNomineeDetailsObject.creationDate = nomineeDetailsObject!.value(forKey: creationDate) as? NSDate
            return returnNomineeDetailsObject
        }
        return nil
    }
    
    static func updateNomineeDetails(nomineeDetails : NomineeDetails){
        
        AppDelegate.getAppDelegate().log.debug("updateVehicleObject()")
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:nomineeDetailsTable)
            fetchRequest.predicate = NSPredicate(format: "\(userId) = %@", argumentArray: [nomineeDetails.userId!])
            
            
            if let nomineeDetailsObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest){
                nomineeDetailsObject.setValue(nomineeDetails.userId, forKey: userId)
                nomineeDetailsObject.setValue(nomineeDetails.nomineeName, forKey: nomineeName)
                nomineeDetailsObject.setValue(nomineeDetails.nomineeAge, forKey: nomineeAge)
                nomineeDetailsObject.setValue(nomineeDetails.nomineeRelation, forKey: nomineeRelation)
                nomineeDetailsObject.setValue(nomineeDetails.nomineeMobile, forKey: nomineeMobile)
                nomineeDetailsObject.setValue(nomineeDetails.creationDate, forKey: creationDate)
                
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }
        }
    }

    static func saveGreetingDetails(greetingDetails : [GreetingDetails]){
        
        AppDelegate.getAppDelegate().log.debug("saveGreetingDetails()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform{
            for greetingDetail in greetingDetails{
                let entity = NSEntityDescription.entity(forEntityName: greetingDetailsTable, in: managedContext)
                let greetingDetailsObject = NSManagedObject(entity: entity!, insertInto: managedContext)
                
                greetingDetailsObject.setValue(greetingDetail.type, forKey: greetingType)
                greetingDetailsObject.setValue(greetingDetail.message, forKey: message)
                greetingDetailsObject.setValue(greetingDetail.gifImageUrl, forKey: gifImageUrl)
                greetingDetailsObject.setValue(greetingDetail.displayedCount, forKey: displayedCount)
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }
        }
    }
    
    static func getGreetingDetails(type: String) -> GreetingDetails? {
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: greetingDetailsTable)
        let predicate = NSPredicate(format: "\(greetingType) == %@", argumentArray: [type])
        fetchRequest.predicate = predicate
        let greetingDetailsObjects = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        if greetingDetailsObjects != nil{
            let returnGreetingDetailsObject = GreetingDetails()
            returnGreetingDetailsObject.type = greetingDetailsObjects!.value(forKey: greetingType) as? String
            returnGreetingDetailsObject.message = greetingDetailsObjects!.value(forKey: message) as? String
            returnGreetingDetailsObject.gifImageUrl = greetingDetailsObjects!.value(forKey: gifImageUrl) as? String
            returnGreetingDetailsObject.displayedCount = greetingDetailsObjects!.value(forKey: displayedCount) as! Int
            return returnGreetingDetailsObject
        }
        return nil
    }
    
    static func saveOrUpdateUserPreferredPickupDrop(userPreferredPickupDrop : UserPreferredPickupDrop){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            let preferredPickupDrop = getUserPreferredPickupDropForId(id: String(userPreferredPickupDrop.id))
            if preferredPickupDrop == nil{
                UserCoreDataHelper.saveUserPreferredPickupDrop(managedContext: managedContext, userPreferredPickupDrop: userPreferredPickupDrop)
            }else{
                UserCoreDataHelper.updateUserPreferredPickupDrop(managedContext: managedContext, userPreferredPickupDropManagedObject: preferredPickupDrop!, userPreferredPickupDrop: userPreferredPickupDrop)
            }
        }
    }
    
    static func saveUserPreferredPickupDrop(managedContext: NSManagedObjectContext, userPreferredPickupDrop: UserPreferredPickupDrop){
        AppDelegate.getAppDelegate().log.debug("saveUserPreferredPickupDrop()")
        let entity = NSEntityDescription.entity(forEntityName: userPreferredPickupDropTable, in: managedContext)
        let userPreferredPickupDropManagedObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        userPreferredPickupDropManagedObject.setValue(userPreferredPickupDrop.id, forKey: userPreferredPickupDropId)
        userPreferredPickupDropManagedObject.setValue(userPreferredPickupDrop.userId, forKey: passengerUserId)
        userPreferredPickupDropManagedObject.setValue(userPreferredPickupDrop.latitude, forKey: userPreferredPickupDropLatitude)
        userPreferredPickupDropManagedObject.setValue(userPreferredPickupDrop.longitude, forKey: userPreferredPickupDropLongitude)
        userPreferredPickupDropManagedObject.setValue(userPreferredPickupDrop.type, forKey: userPreferredPickupDropType)
        userPreferredPickupDropManagedObject.setValue(userPreferredPickupDrop.note, forKey: note)
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }
    
    static func updateUserPreferredPickupDrop(managedContext : NSManagedObjectContext, userPreferredPickupDropManagedObject : NSManagedObject, userPreferredPickupDrop: UserPreferredPickupDrop) {
        AppDelegate.getAppDelegate().log.debug("updateUserPreferredPickupDrop()")
        userPreferredPickupDropManagedObject.setValue(userPreferredPickupDrop.id, forKey: userPreferredPickupDropId)
        userPreferredPickupDropManagedObject.setValue(userPreferredPickupDrop.userId, forKey: passengerUserId)
        userPreferredPickupDropManagedObject.setValue(userPreferredPickupDrop.latitude, forKey: userPreferredPickupDropLatitude)
        userPreferredPickupDropManagedObject.setValue(userPreferredPickupDrop.longitude, forKey: userPreferredPickupDropLongitude)
        userPreferredPickupDropManagedObject.setValue(userPreferredPickupDrop.type, forKey: userPreferredPickupDropType)
        userPreferredPickupDropManagedObject.setValue(userPreferredPickupDrop.note, forKey: note)
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }
    
    static func getAllUserPreferredPickupDrop() -> [UserPreferredPickupDrop] {
        AppDelegate.getAppDelegate().log.debug("getAllUserPreferredPickupDrop()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userPreferredPickupDropTable)
        
        var userPreferredPickupDrops = [UserPreferredPickupDrop]()
        let userPreferredPickupDropManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        
        if userPreferredPickupDropManagedObjects != nil && !userPreferredPickupDropManagedObjects!.isEmpty{
            for userPreferredPickupDropManagedObject in userPreferredPickupDropManagedObjects!{
                let returnUserPreferredPickupDropObject = UserPreferredPickupDrop()
                returnUserPreferredPickupDropObject.id = userPreferredPickupDropManagedObject.value(forKey: userPreferredPickupDropId) as! Double
                returnUserPreferredPickupDropObject.userId = userPreferredPickupDropManagedObject.value(forKey: passengerUserId) as? Double
                returnUserPreferredPickupDropObject.latitude = userPreferredPickupDropManagedObject.value(forKey: userPreferredPickupDropLatitude) as? Double
                returnUserPreferredPickupDropObject.longitude = userPreferredPickupDropManagedObject.value(forKey: userPreferredPickupDropLongitude) as? Double
                returnUserPreferredPickupDropObject.type = userPreferredPickupDropManagedObject.value(forKey: userPreferredPickupDropType) as? String
                returnUserPreferredPickupDropObject.note = userPreferredPickupDropManagedObject.value(forKey: note) as? String
                userPreferredPickupDrops.append(returnUserPreferredPickupDropObject)
            }
        }
        return userPreferredPickupDrops
    }
    
    static func getUserPreferredPickupDropForId(id: String) -> NSManagedObject?{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userPreferredPickupDropTable)
        let predicate = NSPredicate(format: "\(userPreferredPickupDropId) == %@", argumentArray: [userPreferredPickupDropId])
        fetchRequest.predicate = predicate
        let userPreferredPickupDropManagedObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        return userPreferredPickupDropManagedObject
    }
    
    static func saveUserSelfAssessmentCovid(userSelfAssessmentCovid: UserSelfAssessmentCovid) {
        AppDelegate.getAppDelegate().log.debug("saveUserSelfAssessmentCovid()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform{
            let entity = NSEntityDescription.entity(forEntityName: userSelfAssessmentCovidTable, in: managedContext)
            let userSelfAssessmentCovidManagedObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            userSelfAssessmentCovidManagedObject.setValue(userSelfAssessmentCovid.userId, forKey: selfAssessmentUserId)
            userSelfAssessmentCovidManagedObject.setValue(userSelfAssessmentCovid.assessmentResult, forKey: assessmentResult)
            userSelfAssessmentCovidManagedObject.setValue(userSelfAssessmentCovid.createdDate, forKey: createdDate)
            userSelfAssessmentCovidManagedObject.setValue(userSelfAssessmentCovid.expiryDate, forKey: expiryDate)
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
    
    static func getUserSelfAssessmentCovid() -> UserSelfAssessmentCovid?{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userSelfAssessmentCovidTable)
        let userSelfAssessmentCovidManagedObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        if userSelfAssessmentCovidManagedObject != nil {
            let returnuserSelfAssessmentCovidObject = UserSelfAssessmentCovid()
            returnuserSelfAssessmentCovidObject.userId = userSelfAssessmentCovidManagedObject!.value(forKey: selfAssessmentUserId) as? Double
            returnuserSelfAssessmentCovidObject.assessmentResult = userSelfAssessmentCovidManagedObject!.value(forKey: assessmentResult) as? String
            returnuserSelfAssessmentCovidObject.createdDate = userSelfAssessmentCovidManagedObject!.value(forKey: createdDate) as? Double
            returnuserSelfAssessmentCovidObject.expiryDate = userSelfAssessmentCovidManagedObject!.value(forKey: expiryDate) as! Double
            return returnuserSelfAssessmentCovidObject
        }
        return nil
    }
    
    
}
