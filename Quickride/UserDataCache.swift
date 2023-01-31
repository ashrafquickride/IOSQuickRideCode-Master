//
//  UserDataCache.swift
//  Quickride
//
//  Created by KNM Rao on 04/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import Foundation
import ObjectMapper
import CoreLocation

protocol UserDataCacheReceiver{
  func receiveDataFromCacheSucceed( obj :AnyObject)
  func receiveDataFromCacheFailed(responseObject : NSDictionary?,error:NSError?)
}
protocol contactNoReceiver{
  func contactNoreceived(obj :AnyObject)
}
protocol LinkedWalletTransactionStatusReceiver{
    func linkedWalletTransactionStatusUpdated(linkedWalletTransactionStatus: LinkedWalletTransactionStatus)
}
public typealias contactNoReceiverhandler = (_ contactNo : String)->Void

typealias UserBasicInfoCompletionHandler = (_ userBasicInfo: UserBasicInfo?,_ responseError :ResponseError?,_ error :NSError?) -> Void

typealias NonQuickrideUsersContactsReceiverhandler = (_ userContacts : [Contact]?)->Void


public typealias receiveReverificationStatus = (_ isReVerifyShouldDisplay : Bool?)->Void

typealias OnTimeComplianceReceiverHandler = (_ onTimeCompliance: String?) -> Void

public class UserDataCache{

  var currentUser : User?
  var userProfile : UserProfile?
  var vehicle : Vehicle?
  var uservehicles : [Vehicle] = [Vehicle]()
  var userId : String?
  var userAccount : Account?
  var userFavouriteLocations : [UserFavouriteLocation] = [UserFavouriteLocation]()
  var blockedUsers : [BlockedUser] = [BlockedUser]()
  var preferredRidePartners : [PreferredRidePartner] = [PreferredRidePartner]()
  var recentLocations : [UserRecentLocation] = [UserRecentLocation]()
  var userRecentRideType : String?
  var signUpFlowTimeLineStatus = [String : Bool]()
  var entityDisplayStatus = [String : Bool]()
  var userImage : UIImage?
  var totalRidePartnersContact = [String : Contact]()
  var nonQuirideUsers : [Contact]?
  let RECENT_LOCATIONS_LIMIT : Int = 5
  var accountUpdateListeners = [String :AccountUpdateListener]()
  var userUserNotificationSetting : UserNotificationSetting?
  var userRidePathGroups :[UserRouteGroup] = [UserRouteGroup]()
  var userContactNoInfoMap : [String : String] = [String : String]()
  var joinedGroups : [Group] = [Group]()
  var onTimeCompliance : String?
  var userPreferredRoutes = [UserPreferredRoute]()
  var autoConfirmDisplayStatusInMatchingOptions = [String : Bool]()
  var userPreferredPickupDrops = [UserPreferredPickupDrop]()
  var userSelfAssessmentCovid: UserSelfAssessmentCovid?
  var userCurrentLocation: Location?
  var callCreditDetails: CallCreditDetails?

  var ridePreferences :RidePreferences?
  var securityPreferences :SecurityPreferences?
  var emailPreferences : EmailPreferences?
  var smsPreferences : SMSPreferences?
  var whatsAppPreferences : WhatsAppPreferences?
  var callPreferences : CallPreferences?
  var userVacation : UserVacation?
  var userStatusUpdateReceiver : UserStatusUpdateReceiver?
  var isReVerifyShouldDisplay : Bool?
  var otherUserCompleteProfile = [String: UserFullProfile]()
  var nomineeDetails : NomineeDetails?
  var pendingLinkedWalletTransactions : [LinkedWalletPendingTransaction]?
  var linkedWallets = [LinkedWallet]()
  var linkedWalletTransactionStatusReceiver: LinkedWalletTransactionStatusReceiver?
  var userBasicInfos = [Double: UserBasicInfo]()
  var companyIdVerificationData: CompanyIdVerificationData?
  var displayResumeDialogForSuspendedRecurringRides = false
  private var endorsementVerificationInfo = [String: [EndorsementVerificationInfo]]()
  private var skillsAndInterestsData: SkillsAndInterestsData?
  private var rideEtiquetteCertification = [String : RideEtiquetteCertification]()

  static var sharedInstance : UserDataCache?
  static let OFFER = "OFFER"
  static let UNVERIFIED_ALERT_DIALOGUE = "UNVERIFIED"
  static let FREE_RIDE_OFFER_DAILOGUE = "FREERIDE"
  static let REFER_AND_EARN = "REFER_AND_EARN"
  static let RIDE_ASSURED_INCENTIVE = "RIDE_ASSURED_INCENTIVE"
  static let PENDING_LINKED_WALLET_TRANSACTIONS = "PENDING_LINKED_WALLET_TRANSACTIONS"
  static let VERIFICATION_VIEW = "VERIFICATION_VIEW"
  static var SUBSCRIPTION_STATUS = false
  static var LINK_WALLET_DIALOGUE_DISPLAY_STATUS = false
  static let THANKYOU_GREETING = "THANKYOU_GREETING"
  static let WELCOME_GREETING = "WELCOME_GREETING"
  static let AUTO_CONFIRM_STATUS = "AUTO_CONFIRM_STATUS"
  static var isBannerDisplayed = false
  static let MODERATION_INFO_SHOWN_STATUS = "MODERATION_INFO_SHOWN_STATUS"
  static var contactNo: Double?

  private init(){
    self.userId = QRSessionManager.getInstance()?.getUserId()
  }

  private func removeCacheInstance(){
    AppDelegate.getAppDelegate().log.debug("removeCacheInstance()")
    UserDataCache.sharedInstance = nil
    self.userRecentRideType = nil
    self.userFavouriteLocations = []
    self.currentUser = nil
    self.userProfile = nil
    self.vehicle = nil
    self.uservehicles = []

    self.userAccount = nil
    self.accountUpdateListeners.removeAll()

  }

  public static func getInstance() -> UserDataCache?{

    return self.sharedInstance
  }

  // MARK: Session Methods

  public static func newUserSession(){
    AppDelegate.getAppDelegate().log.debug("newUserSession()")
    if self.sharedInstance != nil {
      self.sharedInstance?.removeCacheInstance()
    }
    self.sharedInstance = UserDataCache()
    self.sharedInstance?.initialiseNewUserDefaultData()
    self.sharedInstance?.updateDefaultVehicleDetailsOfUser()
  }

  public func initialiseNewUserDefaultData(){
    AppDelegate.getAppDelegate().log.debug("initialiseNewUserDefaultData()")
    self.ridePreferences = RidePreferences()
    createUserObjFromExistingDetails()
    getcompleteProfile(userId: (QRSessionManager.sharedInstance?.getUserId())!, targetViewController: nil) { (completeProfileObject, responseError) in

    }
  }

    func createUserObjFromExistingDetails()
    {
        if SharedPreferenceHelper.getLoggedInUserId() == nil || SharedPreferenceHelper.getLoggedInUserContactNo() == nil || SharedPreferenceHelper.getCurrentUserGender() == nil{
            LogOutTask(viewController: ContainerTabBarViewController()).userLogOutTask()
            return
        }
        self.currentUser = User()
        self.currentUser!.userName = SharedPreferenceHelper.getLoggedInUserName()
        self.currentUser!.phoneNumber = Double(SharedPreferenceHelper.getLoggedInUserId()!)!
        self.currentUser!.contactNo = Double(SharedPreferenceHelper.getLoggedInUserContactNo()!)
        self.currentUser!.gender = SharedPreferenceHelper.getCurrentUserGender()!
        userProfile = UserProfile()
        userProfile!.userName = self.currentUser!.userName
        userProfile!.gender = self.currentUser!.gender
        userProfile!.userId = self.currentUser!.phoneNumber
    }

  public func getCurrentUserVehicle()->Vehicle{
    AppDelegate.getAppDelegate().log.debug("getCurrentUserVehicle()")
    for currentVehicle in uservehicles{
        if currentVehicle.defaultVehicle == true{
            self.vehicle = currentVehicle
        }
    }
    if vehicle == nil{
      return Vehicle.getDeFaultVehicle()
    }else{
      return vehicle!
    }

  }

  public func getAllCurrentUserVehicles()->[Vehicle]{
    AppDelegate.getAppDelegate().log.debug("getCurrentUserVehicle()")
    var oldUserVehicles = [Vehicle]()
    var newUserVehicles = [Vehicle]()
    for userVehicle in self.uservehicles
    {
        if userVehicle.defaultVehicle{
            oldUserVehicles.append(userVehicle)
        }
        else {
            newUserVehicles.append(userVehicle)
        }
    }
    oldUserVehicles.append(contentsOf: newUserVehicles)
    return oldUserVehicles
  }

  public func getLoggedInUserProfile() -> UserProfile?
  {
    return userProfile
  }

  func isContactRestrictionToastDisplayable() -> Bool?
  {
    return SharedPreferenceHelper.getContactInviteGuidesStatus()
  }

  func setContactRestrictionToastDisplayable( status : Bool)
  {
    SharedPreferenceHelper.setContactInviteGuidesStatus(status: status)
  }


  /* Existing user relogged in, I need to reload info from server and store in SQLite DB and load to memory aswell*/
    public static func reInitialiseUserSession(completionHandler : @escaping CompletionHandlers.sessionChangeCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("reInitialiseUserSession()")
    if self.sharedInstance != nil {
       self.sharedInstance?.removeCacheInstance()
    }
    self.sharedInstance = UserDataCache()
    self.sharedInstance?.loadUserCompleteProfileAndAccountDetails(userId: (QRSessionManager.sharedInstance?.getUserId())!, sessionChangeCompletionHandler: completionHandler)
    self.sharedInstance?.getCoTravellersFromServer()
    self.sharedInstance?.getPendingBillsFromServer()
  }

  public static func resumeUserSession() throws{

    AppDelegate.getAppDelegate().log.debug("resumeUserSession()")

    self.sharedInstance = UserDataCache()
    do {
      try self.sharedInstance?.loadFromLocalPersistenceToCache()
    }
    catch let error as UserDataCacheOperationFailedException {
      if (error == UserDataCacheOperationFailedException.UserInfoNotFoundInLocalPersistance) {
        throw SessionManagerOperationFailedException.InvalidUserSession
      }
      throw error
    }
   self.sharedInstance?.recentLocations = UserCoreDataHelper.getuserRecentLocationObject()
   self.sharedInstance?.loadUserDataFromServerAndRefreshInPersistence()
   self.sharedInstance?.getPendingBillsFromServer()
  }

  func  getAllBlockedUsers() -> [BlockedUser]
  {
    return blockedUsers
  }

  func addBlockedUser(blockedUser : BlockedUser)
  {
    blockedUsers.append(blockedUser)
    UserCoreDataHelper.saveBlockedUsers(blockedUsers: [blockedUser])
  }

  func isBlockedUser(userId : Double) -> Bool
  {
    if(blockedUsers.isEmpty)
    {
      return false
    }
    for blockedUser in blockedUsers
    {
      if blockedUser.blockedUserId == userId
      {
        return true
      }
    }
    return false
  }

  func isABlockedUserForCurrentUser(userId : Double) -> Bool
  {
    if blockedUsers.isEmpty
    {
      return false
    }
    for blockedUser in blockedUsers
    {
      if blockedUser.blockedUserId! == userId
      {
        return true
      }
    }
    return false
  }

    func isFavouritePartner(userId : Double) -> Bool
    {
        if(preferredRidePartners.isEmpty)
        {
            return false
        }
        for preferredRidePartner in preferredRidePartners
        {
            if preferredRidePartner.favouritePartnerUserId == userId
            {
                return true
            }
        }
        return false
    }


    func getAllPreferredRidePartners()-> [PreferredRidePartner]{

        return preferredRidePartners
    }

    func addPreferredRidePartner(favoriteRidePartners : [PreferredRidePartner])
    {
        for preferredRidePartner in favoriteRidePartners{

            preferredRidePartners.append(preferredRidePartner)
        }

    }

    func getAllJoinedGroups() -> [Group]{

        return joinedGroups
    }

    func deleteGroupFromList(groupId : Double){

        var indexValue = Int()

            if !joinedGroups.isEmpty{

            for index in 0...joinedGroups.count - 1
            {
                if joinedGroups[index].id == groupId
                {
                    indexValue = index
                }
            }
            deleteUserGroupFromPersistence(groupId: groupId)
            self.joinedGroups.remove(at: indexValue)
         }
    }

    func deleteUserGroupFromPersistence(groupId : Double){
        let userGroup = getGroupWithGroupId(groupId: groupId)
        if userGroup != nil{
          UserCoreDataHelper.deleteUserGroup(Group: userGroup!)
        }
    }

    func getGroupWithGroupId(groupId : Double?) -> Group?{
        for group in joinedGroups{
            if group.id == groupId{
              return group
            }
        }
     return nil
    }

    func addMembersToGroup(groupId : Double,groupMembers : [GroupMember]){
        for group in joinedGroups{
            if group.id == groupId{
                for grpMember in groupMembers{
                    group.members.append(grpMember)
                }
            }
        }
    }

    func addMemberToGrp(groupId : Double,groupMember : GroupMember){

        for group in joinedGroups{
            if group.id == groupId{
               group.lastRefreshedTime = NSDate()
               group.members.append(groupMember)
            }
        }
    }
    func deleteMemberFromGroup(groupId : Double,groupMember : GroupMember){

       let groupMembers = getMembersOfAGroup(groupId: groupId)
       var newGroupMembers = [GroupMember]()
        for grpMember in groupMembers{
            if grpMember.userId != groupMember.userId{
                newGroupMembers.append(grpMember)
            }
        }
        for group in joinedGroups{
            if group.id == groupId{
               group.members.removeAll()
               group.members = newGroupMembers
               group.lastRefreshedTime = NSDate()
            }
        }

    }

    func updateUserGroupMember(groupMember : GroupMember){
       var groupMembers : [GroupMember] = [GroupMember]()
        let group = getGroupWithGroupId(groupId: groupMember.groupId)
        if group != nil{
            for oldGrpMember in group!.members{
                if oldGrpMember.userId != groupMember.userId{
                    groupMembers.append(oldGrpMember)
                }
            }
            groupMembers.append(groupMember)
            group!.members.removeAll()
            group!.members = groupMembers
            addOrUpdateGroup(newGroup: group!)
        }
    }

  func getMembersOfAGroup(groupId : Double) -> [GroupMember]{
        var groupMembers : [GroupMember] = [GroupMember]()
        for group in joinedGroups{
            if group.id == groupId{
              groupMembers = group.members
            }
        }
       return groupMembers
    }

    func addOrUpdateGroup(newGroup : Group){
       var newUserGroups = [Group]()

        newUserGroups.append(newGroup)

        for userGroup in joinedGroups{
            if userGroup.id != newGroup.id{
                newUserGroups.append(userGroup)
            }
        }
     joinedGroups = newUserGroups
     UserGroupChatCache.getInstance()?.newGroupAdded(group: newGroup)
     UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.userGroupTable)
     UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.userGroupMembersTable)
     storeUserGroupsInPersistence(groups: joinedGroups)
    }

  func returnDataToClient(objectDta : AnyObject,  clientRef : UserDataCacheReceiver?){
    AppDelegate.getAppDelegate().log.debug("returnDataToClient()")
    if clientRef != nil{
      clientRef!.receiveDataFromCacheSucceed(obj: objectDta)
    }
  }
  // MARK: RecentLocations
  public func getRecentLocations() -> [UserRecentLocation]?{
    AppDelegate.getAppDelegate().log.debug("getRecentLocations()")
    if self.recentLocations.count != 0 {
      return self.recentLocations
    }else{
      self.recentLocations =  UserCoreDataHelper.getuserRecentLocationObject()
      return self.recentLocations
    }
  }

  public func saveRecentLocations(recentLocation : UserRecentLocation?) {

    AppDelegate.getAppDelegate().log.debug("\(String(describing: recentLocation))")
    recentLocation!.time = NSDate().getTimeStamp()
    let redundantRecentLocation =  UserDataCache.getRedundantRecentLocation(selectLocation: recentLocation!, recentLocations: recentLocations)
    if(redundantRecentLocation != nil)
    {
      removeRecentLocation(recentLocation: redundantRecentLocation!.location!,index: redundantRecentLocation!.index)
    }
    var locations :[UserRecentLocation] = [UserRecentLocation]()
    locations.append(recentLocation!)
    for recentLocation in recentLocations{
      locations.append(recentLocation)
    }
    recentLocations = locations
    while recentLocations.count > RECENT_LOCATIONS_LIMIT{
      removeRecentLocation(recentLocation: recentLocations[RECENT_LOCATIONS_LIMIT],index: RECENT_LOCATIONS_LIMIT)
    }
    UserCoreDataHelper.saveRecentLocation(userRecentLocation: recentLocation!)
  }

  func getContactNo(userId : String, handler: @escaping contactNoReceiverhandler )
  {
    if((userContactNoInfoMap[userId]) != nil)
    {
      handler(userContactNoInfoMap[userId]!)
    }
    else
    {
      getUserContactFromSerever(userId: userId,handler: handler)

    }

  }

  func getUserContactFromSerever(userId : String,handler: @escaping contactNoReceiverhandler)
  {
    QuickRideProgressSpinner.startSpinner()
    UserRestClient.getUserContactNo(userId: userId, uiViewController: nil) { (responseObject, error) -> Void in
        QuickRideProgressSpinner.stopSpinner()
      if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
        let contactNo = responseObject!["resultData"] as? String
        UserDataCache.getInstance()!.storeUserContactNo(userId: userId,contactNo: contactNo!)
        handler(contactNo!)

      }
    }
  }



  func removeRecentLocation( recentLocation : UserRecentLocation, index: Int){
    AppDelegate.getAppDelegate().log.debug("removeRecentLocation()")
    AppDelegate.getAppDelegate().log.debug(" \(recentLocation)")
    UserCoreDataHelper.deleteRecentLocation(userRecentLocation: recentLocation)
    self.recentLocations.remove(at: index)
  }

    static func getRedundantRecentLocation(selectLocation : UserRecentLocation, recentLocations: [UserRecentLocation]) -> (location: UserRecentLocation?, index: Int)? {
    AppDelegate.getAppDelegate().log.debug("getRedundantRecentLocation()")
    var recentLocations = recentLocations
    if recentLocations.isEmpty {
        recentLocations = UserCoreDataHelper.getuserRecentLocationObject()
    }
    for index in 0 ..< recentLocations.count {
      let selectedCLLocation = CLLocation(latitude: selectLocation.latitude! , longitude: selectLocation.longitude!)
      let recentCLLocation = CLLocation(latitude: recentLocations[index].latitude! , longitude: recentLocations[index].longitude!)
      if (selectedCLLocation.distance(from: recentCLLocation) <= 1000) {
        return (recentLocations[index],index)
      }
    }
    return nil
  }
  func  getRedundantRecentLocation( latitude : Double?,longitude :Double?) -> (location: UserRecentLocation?, index: Int)? {
    AppDelegate.getAppDelegate().log.debug("getRedundantRecentLocation()")
    for index in 0 ..< recentLocations.count {

      if latitude == recentLocations[index].latitude && longitude == recentLocations[index].longitude{
        return (recentLocations[index],index)
      }
    }
    return nil
  }

  // MARK: FavouriteLocation
  public func getFavoriteLocations() -> [UserFavouriteLocation]{
    AppDelegate.getAppDelegate().log.debug("getFavoriteLocations()")
    return userFavouriteLocations
  }

  func storeBlockedUsersInCache(blockedUsers : [BlockedUser]?)
  {
    AppDelegate.getAppDelegate().log.debug("storeBlockedUsersInCache()")
    if blockedUsers == nil{
      self.blockedUsers = [BlockedUser]()
    }else{
      self.blockedUsers = blockedUsers!
      UserCoreDataHelper.saveBlockedUsers(blockedUsers: self.blockedUsers)
    }

  }
  func deleteBlockedUser(unBlockedUserId : Double)
  {
    var indexValue = Int()
    if !blockedUsers.isEmpty
    {
      for index in 0...blockedUsers.count - 1
      {
        if blockedUsers[index].blockedUserId == unBlockedUserId
        {
            indexValue = index
            break
        }
      }
    self.blockedUsers.remove(at: indexValue)
    UserCoreDataHelper.deleteBlockedUser(blockedUserid: unBlockedUserId)
    UserDataCache.getInstance()?.getUserBasicInfo(userId: unBlockedUserId, handler: { (userBasicInfo,responseError,error) in
           if userBasicInfo != nil{
            let contact = Contact( userId : Double(self.userId!)!, contactId : StringUtils.getStringFromDouble(decimalNumber: userBasicInfo!.userId), contactName : userBasicInfo!.name!, contactGender : userBasicInfo!.gender, contactType : Contact.NEW_USER, imageURI : userBasicInfo!.imageURI, supportCall : userBasicInfo!.callSupport,contactNo: nil,defaultRole: UserProfile.PREFERRED_ROLE_BOTH)
            self.storeRidePartnerContact(contact: contact)
          }
       })
    }
  }

    func storePreferredRidePartnersInCache(preferredRidePartners : [PreferredRidePartner]?)
    {
        AppDelegate.getAppDelegate().log.debug("storePreferredRidePartnersInCache")
        if preferredRidePartners == nil{
            self.preferredRidePartners = [PreferredRidePartner]()
        }else{
            self.preferredRidePartners = preferredRidePartners!
            storePreferredRidePartnersInPersistence(preferredRidePartners: preferredRidePartners!)
        }

    }

    func storePreferredRidePartnersInPersistence(preferredRidePartners : [PreferredRidePartner]){
        for preferredRidePartner in preferredRidePartners{
           UserCoreDataHelper.storePreferredRidePartner(preferredRidePartner: preferredRidePartner)
        }
    }

    func deletePreferredRidePartner(favouritePartnerUserId : Double?){
        var indexValue = Int()
        if !preferredRidePartners.isEmpty{

            for index in 0...preferredRidePartners.count - 1
            {
                if preferredRidePartners[index].favouritePartnerUserId == favouritePartnerUserId
                {
                   indexValue = index
                }
            }
           removeFavouritePartnersFromPersistence(favouritePartnerUserId: favouritePartnerUserId!)
           self.preferredRidePartners.remove(at: indexValue)

        }
    }

    func removeFavouritePartnersFromPersistence(favouritePartnerUserId : Double){
        for preferredRidePartner in preferredRidePartners{
            if preferredRidePartner.favouritePartnerUserId == favouritePartnerUserId{
               UserCoreDataHelper.deletePreferredRidePartner(preferredRidePartner: preferredRidePartner)
            }
        }
    }

  public func saveFavoriteLocations(favoriteLocations : UserFavouriteLocation?) -> Bool{
    AppDelegate.getAppDelegate().log.debug("saveFavoriteLocations()")
    self.userFavouriteLocations.insert(favoriteLocations!, at: (userFavouriteLocations.count))
    UserCoreDataHelper.saveFavouriteLocation(userFavouriteLocation: favoriteLocations!)
    return true
  }
  func deleteUserFavouriteLocation( location : UserFavouriteLocation)
  {
    AppDelegate.getAppDelegate().log.debug("deleteUserFavouriteLocation()")
    if userFavouriteLocations.isEmpty == true{
      return
    }
    for index in 0...userFavouriteLocations.count - 1{
      if location.latitude == userFavouriteLocations[index].latitude && location.longitude == userFavouriteLocations[index].longitude{
        UserCoreDataHelper.deleteUserFavouriteLocationObject(userFavouriteLocation: location)
        userFavouriteLocations.remove(at: index)
        break
      }
    }
  }

    func storeUserFavouriteLocations(userFavouriteLocations : [UserFavouriteLocation]){
        for location in userFavouriteLocations{
            UserCoreDataHelper.saveFavouriteLocation(userFavouriteLocation: location)
        }
    }

    func getUserFavouriteLocationsFromPersistence(){
         let favouriteLocations = UserCoreDataHelper.getUserFavouriteLocationObject()
        if !favouriteLocations.isEmpty{
           self.userFavouriteLocations = favouriteLocations
        }
     }

    func getCoTravellersFromServer(){
        RideServicesClient.getCoTravellers(userid: userId!) { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let userContacts = Mapper<Contact>().mapArray(JSONObject: responseObject!["resultData"])!
                ContactPersistenceHelper.clearAllContacts()
                self.totalRidePartnersContact.removeAll()
                for contact in userContacts
                {
                    contact.refreshedDate = NSDate()
                    ContactPersistenceHelper.storeRidePartnerContact(contact: contact)
                    self.totalRidePartnersContact[contact.contactId!] = contact
                }
            }
        }
    }
    func getCoTravellersFromPersistence(){
        self.totalRidePartnersContact = ContactPersistenceHelper.getAllRidePartnersContacts()
        checkForExpiredContactsAndUpdate()
    }

    func checkForExpiredContactsAndUpdate(){
        var listOfExpiredContacts : String = ""
        for contact in totalRidePartnersContact
        {
            if contact.1.contactId != nil {
                listOfExpiredContacts = listOfExpiredContacts + contact.1.contactId! + ","
            }
        }
        if listOfExpiredContacts.isEmpty == false
        {
            RideServicesClient.getExpiredCoTravellers(userId: userId!, expiredContacts: listOfExpiredContacts, handler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    let ridePartnerContacts = Mapper<Contact>().mapArray(JSONObject: responseObject!["resultData"])!
                    for contact in ridePartnerContacts
                    {
                        self.storeRidePartnerContact(contact: contact)
                    }
                }
            })
        }
    }

  func getUserRouteGroups() -> [UserRouteGroup]
  {
    AppDelegate.getAppDelegate().log.debug("getUserRouteGroups()")
    return userRidePathGroups
  }

  func storeUserRidePathGroups(ridePathGroups : [UserRouteGroup]?)
  {
    AppDelegate.getAppDelegate().log.debug("storeUserRidePathGroups()")
    if ridePathGroups == nil{
      self.userRidePathGroups = [UserRouteGroup]()
    }else{
      self.userRidePathGroups = ridePathGroups!
      storeUserRouteGroupInPersistence(userRouteGroups: ridePathGroups!)
    }
  }

    func storeUserRouteGroupInPersistence(userRouteGroups : [UserRouteGroup]){
        for userRouteGroup in userRouteGroups{
            UserCoreDataHelper.storeUserRouteGroup(userRouteGroup: userRouteGroup)
        }
    }

  func addUserRidePathGroup(ridePathGroup : UserRouteGroup)
  {
    self.userRidePathGroups.insert(ridePathGroup, at: (userRidePathGroups.count))
    UserCoreDataHelper.storeUserRouteGroup(userRouteGroup: ridePathGroup)
  }
  func deleteUserRidePathGroup(ridePathGroup : UserRouteGroup)
  {
    AppDelegate.getAppDelegate().log.debug("deleteUserRidePathGroup()")
    if userRidePathGroups.isEmpty == true{
      return
    }
    for index in 0...userRidePathGroups.count - 1{
      if ridePathGroup.id == userRidePathGroups[index].id
      {
        userRidePathGroups.remove(at: index)
        UserCoreDataHelper.deleteRouteGroup(userRouteGroup: ridePathGroup)
        break
      }
    }
  }


  // MARK: Current User Gender
  public func storeCurrentUserGender(gender : String?){
    AppDelegate.getAppDelegate().log.debug("storeCurrentUserGender() \(String(describing: gender))")
    if self.currentUser != nil && gender != nil{
        SharedPreferenceHelper.storeCurrentUserGender(gender: gender)
        self.currentUser!.gender = gender!
    }
  }
  public func storeLoggedInUserContactNo(contactNo : String)
  {
    if(self.currentUser != nil)
    {
      self.currentUser!.contactNo = Double(contactNo)
    }
  }
  public func storeLoggedInUserCountryCode(countryCode : String?)
  {
    if(self.currentUser != nil && countryCode != nil)
    {
      self.currentUser!.countryCode = countryCode
    }
  }

  func getUserContactNo(userId : String, receiver : contactNoReceiver)
  {
    if((userContactNoInfoMap[userId]) != nil)
    {
      receiver.contactNoreceived(obj: userContactNoInfoMap[userId]! as AnyObject)
    }
    else
    {
      getUserContactNoFromServer(userId: userId, receiver: receiver)
    }
  }

  public func storeUserContactNo(userId : String, contactNo : String)
  {
    if userContactNoInfoMap[userId] != nil{
      userContactNoInfoMap.removeValue(forKey: userId)
    }
    userContactNoInfoMap[userId] = contactNo
  }

  func getUserContactNoFromServer(userId : String, receiver : contactNoReceiver)
  {
    UserRestClient.getUserContactNo(userId: userId, uiViewController: nil) { (responseObject, error) -> Void in
      if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
        let contactNo = responseObject!["resultData"] as? String
        receiver.contactNoreceived(obj: contactNo! as AnyObject)
        UserDataCache.getInstance()!.storeUserContactNo(userId: userId,contactNo: contactNo!)
      }
    }
  }

  public func getCurrentUserGender() -> String?{
    AppDelegate.getAppDelegate().log.debug("getCurrentUserGender()")
    if currentUser?.gender == nil{
      if SharedPreferenceHelper.getCurrentUserGender() != nil
      {
        return SharedPreferenceHelper.getCurrentUserGender()
      }
      return User.USER_GENDER_UNKNOWN
    }
    return currentUser?.gender
  }

  // MARK: Current User Vehicle

  public func getCurrentUserVehicleModel() -> String{
    AppDelegate.getAppDelegate().log.debug("getCurrentUserVehicleModel()")
    return (vehicle?.vehicleModel)!
  }
  public func getLoggedInUserNotificationSettings() -> UserNotificationSetting
  {
    AppDelegate.getAppDelegate().log.debug("getLoggedInUserNotificationSettings()")

    if(userUserNotificationSetting == nil || userUserNotificationSetting?.dontDisturbFromTime == "2200" || userUserNotificationSetting?.dontDisturbToTime == "0600")
    {
      let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
      let dontDisturbFromTime = DateUtils.getDateStringFromString(date: clientConfiguration.dontDisturbFromTime, requiredFormat: DateUtils.DATE_FORMAT_HH_mm_ss, currentFormat: DateUtils.TIME_FORMAT_HHmm)
      let dontDisturbToTime = DateUtils.getDateStringFromString(date: clientConfiguration.dontDisturbToTime, requiredFormat: DateUtils.DATE_FORMAT_HH_mm_ss, currentFormat: DateUtils.TIME_FORMAT_HHmm)

      userUserNotificationSetting = UserNotificationSetting(userId: Double(QRSessionManager.getInstance()!.getUserId())!,rideMatch: true,rideStatus: true,regularRideNotification: true,rideCreated: true,reminderToCreateRide: true, routeGroupSuggestions : true,conversationMessages: true,walletUpdates: true,playVoiceForNotifications: true,dontDisturbFromTime: dontDisturbFromTime!,dontDisturbToTime: dontDisturbToTime!, locationUpdateSuggestions: true, rideRescheduleSuggestions: true)

      storeUserUserNotificationSetting(userId: (QRSessionManager.getInstance()!.getUserId()),notificationSettings: userUserNotificationSetting)
    }
    return userUserNotificationSetting!

  }
  public func getUserVehicle(ownerId : String, targetViewController : UIViewController, vehicleRetrievalCompletionHandler : @escaping CompletionHandlers.vehicleRetrievalCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getUserVehicle() \(ownerId)")
    if QRSessionManager.sharedInstance!.isUserLoggedIn(userId: ownerId){


      if self.vehicle != nil {
        vehicleRetrievalCompletionHandler(self.vehicle, nil)
      }
      else {
        self.getVehicleFromServer(ownerId: ownerId, targetViewController: targetViewController, vehicleRetrievalCompletionHandler: vehicleRetrievalCompletionHandler)
      }
    }
    else {
      self.getVehicleFromServer(ownerId: ownerId, targetViewController: targetViewController, vehicleRetrievalCompletionHandler: vehicleRetrievalCompletionHandler)
    }
  }

  public func getCurrentUserVehicleImageURI() -> String{
    AppDelegate.getAppDelegate().log.debug("getCurrentUserVehicleImageURI()")
    return (vehicle?.imageURI)!
  }

  public func getVehicleFromServer(ownerId: String, targetViewController : UIViewController?, vehicleRetrievalCompletionHandler : @escaping CompletionHandlers.vehicleRetrievalCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getVehicleFromServer() \(ownerId)")

    UserRestClient.getVehicle(ownerId: ownerId, targetViewController: targetViewController) { (responseObject, error) -> Void in
      if responseObject != nil {
        if responseObject!["result"] as! String == "SUCCESS" {
          let retrievedVehicle = Mapper<Vehicle>().map(JSONObject: responseObject!["resultData"])
          if (QRSessionManager.sharedInstance!.isUserLoggedIn(userId: ownerId)) {
            self.vehicle = retrievedVehicle
          }
          vehicleRetrievalCompletionHandler(retrievedVehicle, nil)
        }else if responseObject!["result"] as! String == "FAILURE" {
          let errorResponse = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
          vehicleRetrievalCompletionHandler(nil, errorResponse!)
        }
      }
    }
  }
  public func deleteVehicle(vehicle : Vehicle)
  {
    if !uservehicles.isEmpty
    {
      for index in 0...uservehicles.count - 1
      {
        if uservehicles[index].vehicleId == vehicle.vehicleId
        {
          self.uservehicles.remove(at: index)
          break
        }
      }
    }
    if vehicle.defaultVehicle{
        self.vehicle = nil
    }
  }
  func updateUserDefaultVehicle(vehicle : Vehicle)
  {
    if !uservehicles.isEmpty
    {
      for index in 0...uservehicles.count - 1
      {
        if uservehicles[index].defaultVehicle == true
        {
          uservehicles[index].defaultVehicle = false
        }
        if uservehicles[index].vehicleId == vehicle.vehicleId || uservehicles[index].registrationNumber == vehicle.registrationNumber
        {
          uservehicles[index].defaultVehicle = true
          self.vehicle = uservehicles[index]
        }
      }
    }
  }

  public func storeVehicle(vehicle : Vehicle)
  {
    AppDelegate.getAppDelegate().log.debug("\(vehicle)")
    if vehicle.defaultVehicle {
      self.vehicle = vehicle
    }
    self.uservehicles.append(vehicle)
    UserCoreDataHelper.saveVehicleObject(vehicle: vehicle)
  }
  public func updateVehicle(vehicle : Vehicle){
    AppDelegate.getAppDelegate().log.debug("\(vehicle)")
    if vehicle.defaultVehicle {
      self.vehicle = vehicle
    }
    if  uservehicles.count > 0
    {
      for index in 0...uservehicles.count - 1
      {
        if uservehicles[index].vehicleId == vehicle.vehicleId || uservehicles[index].registrationNumber == vehicle.registrationNumber
        {
          uservehicles[index] = vehicle
        }
      }
    }

    UserCoreDataHelper.updateVehicleObject(vehicle: vehicle)
  }
  public func storetUserVehiclesToPersistence(userVehicles : [Vehicle]?){
    AppDelegate.getAppDelegate().log.debug("")
    if userVehicles == nil{
      return
    }

    for userVehicle in userVehicles!
    {
      if userVehicle.vehicleType == nil || userVehicle.vehicleType!.isEmpty || Vehicle.VEHICLE_TYPE_TAXI == userVehicle.vehicleType!{
        userVehicle.vehicleType = Vehicle.checkVehicleTypeFromModel(vehicleModel: self.vehicle?.vehicleModel)
      }
      if userVehicle.defaultVehicle == true
      {
        self.vehicle = userVehicle
      }
       UserCoreDataHelper.saveVehicleObject(vehicle: userVehicle)
    }
  }

  // MARK: User Account

  public func refreshAccountInformationInCache(){
    AppDelegate.getAppDelegate().log.debug("refreshAccountInformationInCache()")
    self.userAccount = nil
    getAccountInfoFromServer { (accountObject, responseError) in
      self.notifyToAccountUpdateListeners()
    }
  }
  func updateSignUpFlowTimeLineStatus(key : String, status : Bool) {
    signUpFlowTimeLineStatus[key] = status
    SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: key, value: status)
  }
  func getSignUpFlowTimeLineStatus(key : String) -> Bool? {
    var status = signUpFlowTimeLineStatus[key]
    if status == nil{
      status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: key)
    }
    return status
  }
  func updateEntityDisplayStatus(key : String, status : Bool) {
      entityDisplayStatus[key] = status
  }
  func getEntityDisplayStatus(key : String) -> Bool{
    if entityDisplayStatus[key] != nil
    {
        return entityDisplayStatus[key]!
    }
    else
    {
        return false
    }
   }
  public func getAccountInformation(completionHandler : CompletionHandlers.accountRetrievalCompletionHandler?){AppDelegate.getAppDelegate().log.debug("getAccountInformation()")
    if self.userAccount != nil {
      completionHandler?(self.userAccount, nil)
    }else{
      getAccountInfoFromServer(completionHandler: completionHandler)
    }
  }

  public func storeUserUserNotificationSetting(userId : String,notificationSettings : UserNotificationSetting?)
  {
    if(notificationSettings != nil && isUserLoggedInUser(userId: userId))
    {
      self.userUserNotificationSetting = notificationSettings
    }
  }


  public func getAccountInfoFromServer(completionHandler : CompletionHandlers.accountRetrievalCompletionHandler?){
    AppDelegate.getAppDelegate().log.debug("getAccountInfoFromServer()")
    if self.userAccount == nil {
      let userId : String = (QRSessionManager.getInstance()?.getUserId())!
      AccountRestClient.getAccountInfo(userId: userId, targetViewController: nil, completionHandler: { (responseObject, error) -> Void in
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
          self.userAccount = Mapper<Account>().map(JSONObject: responseObject!["resultData"])

          UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.accountTable)
            UserCoreDataHelper.saveAccountObject(account: self.userAccount!)
          completionHandler?(self.userAccount, nil)
        }else{
          ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
        }
      })
    }
  }
  func notifyToAccountUpdateListeners(){
    DispatchQueue.main.async {
      for listener in self.accountUpdateListeners{
        listener.1.refreshAccountInformation()
      }
    }
  }

  // MARK: User Profile

  public func getcompleteProfile(userId : String, targetViewController : UIViewController?, completionHandler : CompletionHandlers.completeProfileRetrievalCompletionHandler?){
    AppDelegate.getAppDelegate().log.debug("getcompleteProfile() \(userId)")
    self.intiatilizeUserDataFromServer(userId: userId, targetViewController: targetViewController, completionHandler: { (completeProfile, responseError) in
        if responseError != nil{
            completionHandler?(nil, responseError)
        }else{
           completionHandler?(completeProfile, nil)
        }
    })
 }

    func getCompleteProfileFromPersistence(userId : String, targetViewController : UIViewController?){
        self.initalizeUserDataFromPersistence(userId: userId, errorResponse: nil)
    }

    func getCompleteProfileFromServer(userId : String){
        self.intiatilizeUserDataFromServer(userId: userId, targetViewController: nil, completionHandler: { (completeProfile, responseError) in
        })
    }

    func intiatilizeUserDataFromServer(userId : String, targetViewController : UIViewController?, completionHandler : CompletionHandlers.completeProfileRetrievalCompletionHandler?){

        UserRestClient.getCompleteProfile(userId: userId, targetViewController: nil) { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let completeProfile : CompleteProfile = Mapper<CompleteProfile>().map(JSONObject: responseObject!["resultData"])!
                self.clearUserDataCache()
                self.clearUserCompleteProfileInPersistence()
                self.saveUserCompleteProfile(userId: userId, completeProfile: completeProfile)
                completionHandler?(completeProfile, nil)
            } else if responseObject != nil && responseObject!["result"] as! String == "FAILURE" {
                let errorResponse = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                AppDelegate.getAppDelegate().log.error("Error while retrieving complete user profile from server : \(String(describing: errorResponse))")
                completionHandler?(nil,errorResponse)
            }else{
                completionHandler?(nil, nil)
            }
        }
    }

    func initalizeUserDataFromPersistence(userId : String,errorResponse : ResponseError?){
        self.currentUser = UserCoreDataHelper.getUserObject()
        self.userProfile = UserCoreDataHelper.getUserProfileObject()
        self.userProfile?.profileVerificationData = UserCoreDataHelper.getProfileVerificationObject()
        if self.userProfile?.gender == nil{
            self.userProfile?.gender = currentUser?.gender
        }
        self.linkedWallets = UserCoreDataHelper.getLinkedWallets()
        self.uservehicles = UserCoreDataHelper.getVehicleObject()
        self.userAccount = UserCoreDataHelper.getAccountObject()
        self.blockedUsers = UserCoreDataHelper.getAllBlockedUsers(userid: Double(QRSessionManager.getInstance()!.getUserId())!)
        self.joinedGroups = UserCoreDataHelper.getUserGroups(usrId:Double(QRSessionManager.getInstance()!.getUserId())!)
        self.userFavouriteLocations = UserCoreDataHelper.getUserFavouriteLocationObject()
        self.preferredRidePartners = UserCoreDataHelper.getPreferredRidePartners(usrId: Double(QRSessionManager.getInstance()!.getUserId())!)
        self.userRidePathGroups = UserCoreDataHelper.getUserRouteGroups(usrId: Double(QRSessionManager.getInstance()!.getUserId())!)
        self.userPreferredRoutes = MyRoutesCachePersistenceHelper.getUserPreferredRoutes()
        let userPreferences = SharedPreferenceHelper.getUserPreferences()
        if userPreferences != nil{
            self.ridePreferences = userPreferences!.ridePreferences
            self.securityPreferences = userPreferences!.securityPreferences
            self.emailPreferences = userPreferences!.communicationPreferences?.emailPreferences
            self.smsPreferences = userPreferences!.communicationPreferences?.smsPreferences
            self.whatsAppPreferences = userPreferences!.communicationPreferences?.whatsAppPreferences
            self.callPreferences = userPreferences!.communicationPreferences?.callPreferences
            self.userVacation = userPreferences!.userVacation
        }
        if let nomineeDetails = UserCoreDataHelper.getNomineeDetails(){
            self.nomineeDetails = nomineeDetails
        }
        self.userPreferredPickupDrops = UserCoreDataHelper.getAllUserPreferredPickupDrop()
        userSelfAssessmentCovid = UserCoreDataHelper.getUserSelfAssessmentCovid()
    }


  func clearUserCompleteProfileInPersistence(){
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.userTable)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.userProfileTable)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.accountTable)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.vehicleTable)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.userGroupTable)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.userGroupMembersTable)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.userRouteGroupTable)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.userFavouritePartnerTable)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.userFavouriteLocationTable)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.blockedUserTable)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.linkedWalletTable)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.profileVerificationData)
    UserCoreDataHelper.clearTableForEntity(entityName: MyRoutesCachePersistenceHelper.userPreferredRoute_entity)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.nomineeDetailsTable)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.userPreferredPickupDropTable)
    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.userSelfAssessmentCovidTable)
    SharedPreferenceHelper.storeUserPreferences(userPreferences: nil)
  }
    func saveUserCompleteProfile(userId : String,completeProfile : CompleteProfile) {
        if (QRSessionManager.sharedInstance!.isUserLoggedIn(userId: userId)) {

            self.userProfile = completeProfile.userProfile
            self.currentUser = completeProfile.user
            self.userProfile!.gender = self.currentUser!.gender

            self.userAccount = completeProfile.account

            self.storeUSer(userId: userId, user: self.currentUser!)
            self.storeUserProfile(userProfile: self.userProfile!)
            self.storeProfileVerificationDataForCurrentUser(profileVerificationData: completeProfile.profileVerificationData!)
            if self.userAccount != nil{
                UserCoreDataHelper.saveAccountObject(account: self.userAccount!)
            }

            if completeProfile.userPreferredRoutes != nil{
                self.userPreferredRoutes = completeProfile.userPreferredRoutes!
                MyRoutesCachePersistenceHelper.storeUserPreferredRoutesInBulk(userPreferredRoutes: completeProfile.userPreferredRoutes!)
            }
            if completeProfile.vehicles != nil{
                self.uservehicles = completeProfile.vehicles!
                self.storetUserVehiclesToPersistence(userVehicles: completeProfile.vehicles)
            }
            if completeProfile.linkedWallets != nil{
                self.linkedWallets = completeProfile.linkedWallets!
                for linkedWallet in self.linkedWallets{
                    UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet)
                }

            }

            if completeProfile.userPreferences != nil{
                SharedPreferenceHelper.storeUserPreferences(userPreferences: completeProfile.userPreferences!)
                storeLoggedInUserPreferences(userPreferences: completeProfile.userPreferences!)
            }
            if completeProfile.groups != nil{
                self.joinedGroups = completeProfile.groups!
                storeUserGroupsInPersistence(groups: completeProfile.groups!)
            }
            if completeProfile.nomineeDetails != nil{
                self.saveOrUpdateNomineeDetails(nomineeDetails: completeProfile.nomineeDetails!)
            }
            self.userPreferredPickupDrops = completeProfile.userPreferredPickupDrops
            for userPreferredPickupDrop in self.userPreferredPickupDrops {
                UserCoreDataHelper.saveOrUpdateUserPreferredPickupDrop(userPreferredPickupDrop: userPreferredPickupDrop)
            }
            self.callCreditDetails = completeProfile.callCreditDetails
        }
        storeUserSelfAssessmentCovid(userSelfAssessmentCovid: completeProfile.userSelfAssessmentCovid)
    }

    func storeUserSelfAssessmentCovid(userSelfAssessmentCovid: UserSelfAssessmentCovid?) {
        self.userSelfAssessmentCovid = userSelfAssessmentCovid
        if userSelfAssessmentCovid != nil {
            UserCoreDataHelper.saveUserSelfAssessmentCovid(userSelfAssessmentCovid: userSelfAssessmentCovid!)
        }
    }
    func storeUserPreferredPickupDrops(userPreferredPickupDrop: UserPreferredPickupDrop) {
        var existingPreferredPickupDropIndex: Int?
        for (index,preferredPickupDrop) in self.userPreferredPickupDrops.enumerated() {
            if preferredPickupDrop.id == userPreferredPickupDrop.id {
                existingPreferredPickupDropIndex = index
                userPreferredPickupDrops.remove(at: index)
                userPreferredPickupDrops.insert(userPreferredPickupDrop, at: index)
                break
            }
        }
        if existingPreferredPickupDropIndex == nil {
            userPreferredPickupDrops.append(userPreferredPickupDrop)
        }
        UserCoreDataHelper.saveOrUpdateUserPreferredPickupDrop(userPreferredPickupDrop: userPreferredPickupDrop)
    }

    func getUserPreferredPickupDrops() -> [UserPreferredPickupDrop]{
        return userPreferredPickupDrops
    }

    func storeUserGroupsInPersistence(groups : [Group]){
        for group in groups{
            UserCoreDataHelper.storeUserGroups(userGroup: group)
        }
    }

  func storeLoggedInUserPreferences( userPreferences : UserPreferences){
    storeLoggedInUserRidePreferences(ridePreferences: userPreferences.ridePreferences!)
    storeSecurityPreferences(securityPreferences: userPreferences.securityPreferences!)
    storeCommunicationPreferencesInCache(communicationPreferences: userPreferences.communicationPreferences!)
    self.userFavouriteLocations = userPreferences.favouriteLocations!
    storeUserFavouriteLocationsInPersistence(UserFavouriteLocs: userPreferences.favouriteLocations!)
    self.preferredRidePartners = userPreferences.favouriteRidePartners
    self.storeUserRidePathGroups(ridePathGroups: userPreferences.userRouteGroups)
    self.userUserNotificationSetting = userPreferences.communicationPreferences?.userNotificationSetting
    self.storeBlockedUsersInCache(blockedUsers: userPreferences.securityPreferences?.blockedUsers)
    storeUserVacation(userVacation: userPreferences.userVacation)
    if let whatsAppPref = userPreferences.communicationPreferences?.whatsAppPreferences{
        self.whatsAppPreferences = whatsAppPref
    }else{
        self.whatsAppPreferences = WhatsAppPreferences(userId: userPreferences.userId!, enableWhatsAppPreferences: false)
    }
    if let callPreferences = userPreferences.communicationPreferences?.callPreferences{
        self.callPreferences = callPreferences
    }else{
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if clientConfiguration.ivrEnabledDefault == false{
            self.callPreferences = CallPreferences(userId: userPreferences.userId!, enableCallPreferences: false)
        }else{
            self.callPreferences = CallPreferences(userId: userPreferences.userId!, enableCallPreferences: true)
        }
    }
  }

  func storeLoggedInUserRidePreferences( ridePreferences : RidePreferences){
    self.ridePreferences = ridePreferences
  }

    func storeUserFavouriteLocationsInPersistence(UserFavouriteLocs : [UserFavouriteLocation]){
        UserCoreDataHelper.saveFaouriteLocationsInBulk(userFavLocations: UserFavouriteLocs)
    }
  func storeSecurityPreferences( securityPreferences : SecurityPreferences)
  {
    if securityPreferences.blockedUsers != nil{
      self.blockedUsers = securityPreferences.blockedUsers!
    }
    self.securityPreferences = securityPreferences
  }

  func storeCommunicationPreferencesInCache( communicationPreferences : CommunicationPreferences)
  {
    self.emailPreferences = communicationPreferences.emailPreferences
    self.smsPreferences = communicationPreferences.smsPreferences
    self.whatsAppPreferences = communicationPreferences.whatsAppPreferences
    self.callPreferences = communicationPreferences.callPreferences
  }

  func storeUserVacation(userVacation : UserVacation?)
  {
    self.userVacation = userVacation
  }


  func getLoggedInUserVacation() -> UserVacation?
  {
    return  userVacation
  }

  func storeUserLinkedWallet(linkedWallet : LinkedWallet){
    if let row = self.linkedWallets.index(where: {$0.type == linkedWallet.type}) {
           linkedWallets[row] = linkedWallet
    }
    else{
        self.linkedWallets.append(linkedWallet)
    }
  }

    func getAllLinkedWallets() -> [LinkedWallet]
    {
        var currentLinkedWalletList = [LinkedWallet]()
        var newLinkedWalletList = [LinkedWallet]()

        for linkedWallet in self.linkedWallets
        {
            if !isValidLinkedWallet(type: linkedWallet.type!){
                continue
            }
            if linkedWallet.defaultWallet{
                currentLinkedWalletList.append(linkedWallet)
            }
            else{
                newLinkedWalletList.append(linkedWallet)
            }
        }
        currentLinkedWalletList.append(contentsOf: newLinkedWalletList)
        return currentLinkedWalletList
    }
    
    func isValidLinkedWallet(type: String) -> Bool{
        let validWallets: [String] = [AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM                                     ,AccountTransaction.TRANSACTION_WALLET_TYPE_TMW
                                      ,AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL
                                      ,AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY
                                      ,AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY
                                      ,AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK
                                      ,AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE
                                      ,AccountTransaction.TRANSACTION_WALLET_TYPE_UPI
                                      ,AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE]
        return validWallets.contains(type)
    }

    func getDefaultLinkedWallet() -> LinkedWallet?{
        for linkedWallet in  self.linkedWallets
        {
            if linkedWallet.defaultWallet && isValidLinkedWallet(type: linkedWallet.type!){
                return linkedWallet
            }
        }
        return nil
    }

    func deleteLinkedWallet(linkedWallet : LinkedWallet)
    {
        if !linkedWallets.isEmpty
        {
            for index in 0...linkedWallets.count - 1
            {
                if linkedWallets[index].type == linkedWallet.type
                {
                    self.linkedWallets.remove(at: index)
                    break
                }
            }
        }
    }

    func updateUserDefaultLinkedWallet(linkedWallet : LinkedWallet)
    {
        if !linkedWallets.isEmpty
        {
            for index in 0...linkedWallets.count - 1 {
                if linkedWallets[index].defaultWallet {
                    linkedWallets[index].defaultWallet = false
                    break
                }
            }
            for index in 0...linkedWallets.count - 1 {
                if linkedWallets[index].type == linkedWallet.type {
                    linkedWallets[index].defaultWallet = true
                    break
                }
            }
        }
    }
  func getLoggedInUserRidePreferences() -> RidePreferences{
    if ridePreferences == nil{
       ridePreferences = RidePreferences()
    }
    return ridePreferences!
  }

  func getLoggedInUsersSecurityPreferences() -> SecurityPreferences{
    if securityPreferences == nil{
        securityPreferences = SecurityPreferences()
    }
    return  securityPreferences!
  }
  func getLoggedInUsersEmailPreferences() -> EmailPreferences{
    if emailPreferences == nil{
        emailPreferences = EmailPreferences()
    }
    return emailPreferences!

  }
  func getLoggedInUsersSMSPreferences() -> SMSPreferences{
    if smsPreferences == nil{
        smsPreferences = SMSPreferences()
    }
    return smsPreferences!
  }
    func getLoggedInUserWhatsAppPreferences() -> WhatsAppPreferences{
        if whatsAppPreferences == nil{
            whatsAppPreferences = WhatsAppPreferences()
        }
        return whatsAppPreferences!
    }
    func getLoggedInUserCallPreferences() -> CallPreferences{
        if callPreferences == nil{
            callPreferences = CallPreferences()
        }
        return callPreferences!
    }

    func storeUserWhatsAppPreferences(userWhatsAppPreference: WhatsAppPreferences){
        self.whatsAppPreferences = userWhatsAppPreference
        if let userPreferences = SharedPreferenceHelper.getUserPreferences(){
            userPreferences.communicationPreferences?.whatsAppPreferences = userWhatsAppPreference
            SharedPreferenceHelper.storeUserPreferences(userPreferences: userPreferences)
        }


    }
    func storeUserCallPreferences(userCallPreferences: CallPreferences){
        self.callPreferences = userCallPreferences
        if let userPreferences = SharedPreferenceHelper.getUserPreferences(){
            userPreferences.communicationPreferences?.callPreferences = userCallPreferences
            SharedPreferenceHelper.storeUserPreferences(userPreferences: userPreferences)
        }
    }
  public func getUserProfileFromServer(userId : String, targetViewController : UIViewController?, completionHandler : CompletionHandlers.profileRetrievalCompletionHandler?){
    AppDelegate.getAppDelegate().log.debug("getUserProfileFromServer() \(userId)")
    UserRestClient.getProfile(userId: userId, targetViewController: nil) { (responseObject, error) -> Void in
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
            let userProfileObj = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"])
            if (QRSessionManager.sharedInstance!.isUserLoggedIn(userId: userId)) {
                self.userProfile = userProfileObj
                self.storeUserProfile(userProfile: userProfileObj!)
            }
            completionHandler?(userProfileObj, nil, nil)

        } else{
           completionHandler?(nil, error, responseObject)
        }
      }
  }

  public func getUserProfile(userId : String) -> UserProfile?{
    AppDelegate.getAppDelegate().log.debug("getUserProfile() \(userId)")
    if QRSessionManager.sharedInstance!.isUserLoggedIn(userId: userId) && self.userProfile != nil{
        return self.userProfile
    }
    return nil
  }

  public func storeProfileDynamicChanges(profile : UserProfile){
    AppDelegate.getAppDelegate().log.debug("storeProfileDynamicChanges()")
    if self.userProfile != nil {
      storeUserProfile(userProfile: profile)
    }
  }

    public func storeUserProfile( userProfile : UserProfile ){
        AppDelegate.getAppDelegate().log.debug("storeUserProfile()")
        if QRSessionManager.sharedInstance!.isUserLoggedIn(userId: String(userProfile.userId)){

            self.userProfile = userProfile
            if userProfile.userName != nil{
                SharedPreferenceHelper.storeLoggedInUserName(userName: userProfile.userName!)
                self.currentUser?.userName = userProfile.userName!
            }
            var gender: String?
            if userProfile.gender != nil{
                gender = userProfile.gender
            }else{
                gender = SharedPreferenceHelper.getCurrentUserGender()
            }
            self.storeCurrentUserGender(gender: gender)
            if self.userProfile != nil{
                UserCoreDataHelper.saveUserProfileObject(userProfile: self.userProfile!)
            }
        }
        if userProfile.verificationStatus == 1 {
            NotificationStore.getInstance().removeOldNotificationOfSameGroupValue(groupValue: UserNotification.NOT_GRP_EMAIL_VERIFY)
        }
    }

    func updateUserProfile(userProfile : UserProfile){
        self.userProfile = userProfile

    }


  func storeProfileVerificationDataForCurrentUser(profileVerificationData: ProfileVerificationData){
        AppDelegate.getAppDelegate().log.debug("storeProfileVerificationDataForCurrentUser()")
        if StringUtils.getStringFromDouble(decimalNumber: profileVerificationData.userId) == QRSessionManager.sharedInstance?.getCurrentSession().userId{
            self.userProfile?.profileVerificationData = profileVerificationData
            UserCoreDataHelper.saveProfileVerificationObject(profileVerification: profileVerificationData)
        }
    }
    public func getCurrentUserProfileVerificationData() -> ProfileVerificationData?{
        return userProfile?.profileVerificationData
    }
  // MARK: User Name

  public func getUserName() -> String{
    AppDelegate.getAppDelegate().log.debug("getUserName()")
    if self.currentUser != nil{
      return self.currentUser!.userName
    }else{
      return ""
    }
  }

  // MARK: User

  public func getUser() -> User?{
    AppDelegate.getAppDelegate().log.debug("getUser()")
    if (self.currentUser != nil){
        return self.currentUser
    }
    return nil
  }
  private func isUserLoggedInUser(userId : String) -> Bool
  {
    return userId == QRSessionManager.getInstance()!.getUserId()
  }
  public func getUserFromServer(userRetrievalCompletionHandler : @escaping CompletionHandlers.userRetrievalCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getUserFromServer()")
    let userId : String? = QRSessionManager.sharedInstance?.getUserId()
    UserRestClient.getUser(userId: userId!, targetViewController: nil) { (responseObject, error) -> Void in
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
            self.currentUser = Mapper<User>().map(JSONObject: responseObject!["resultData"])
            self.storeUSer(userId: userId!, user: self.currentUser!)
            userRetrievalCompletionHandler(self.currentUser, nil, nil)
        }
        else{
            AppDelegate.getAppDelegate().log.error("Error while retrieving user from server : \(String(describing: error))")
            userRetrievalCompletionHandler(nil, error, responseObject)
        }
      }
  }
  public func storeUserDynamicChanges(user: User)
  {
    AppDelegate.getAppDelegate().log.debug("storeUserDynamicChanges()")
    if self.currentUser != nil {
        storeUSer(userId: (QRSessionManager.getInstance()?.getUserId())!, user: user)
    }
  }
  public func storeUSer(userId : String, user : User){
    AppDelegate.getAppDelegate().log.debug("storeUSer() \(userId)")
    if userId == QRSessionManager.sharedInstance?.getCurrentSession().userId{
      SharedPreferenceHelper.storeLoggedInUserName(userName: user.userName)
      SharedPreferenceHelper.storeCurrentUserGender(gender: user.gender)

      self.currentUser = user
      if self.currentUser != nil{
        UserCoreDataHelper.saveUserObject(userObject: self.currentUser!)
      }
    }
  }

  public func getCurrentUserImageURI() -> String?{
    AppDelegate.getAppDelegate().log.debug("getCurrentUserImageURI()")

    return self.userProfile?.imageURI
  }
  public func getCurrentUserSupportCall() -> String{

    return userProfile!.supportCall
  }

  // MARK: Referral Code

  public func getReferralCode() -> String{
    AppDelegate.getAppDelegate().log.debug("getReferralCode()")
    if currentUser != nil{
        return currentUser!.referralCode
    }
    return ""
  }


  // MARK: Ride Methods

  public func getUserRecentRideType() -> String{
    AppDelegate.getAppDelegate().log.debug("getUserRecentRideType()")
    if self.userProfile?.roleAtSignup == UserProfile.PREFERRED_ROLE_RIDER{
      return  Ride.RIDER_RIDE
    }else if self.userProfile?.roleAtSignup == UserProfile.PREFERRED_ROLE_PASSENGER{
      return Ride.PASSENGER_RIDE
    }
    if self.userRecentRideType != nil{
      return self.userRecentRideType!
    }

    self.userRecentRideType = SharedPreferenceHelper.getRecentUserRideType()
    if self.userRecentRideType != nil && self.userRecentRideType?.isEmpty == false{
      return self.userRecentRideType!
    }

    if self.vehicle != nil && self.vehicle?.vehicleId != 0.0{
      self.userRecentRideType =  Ride.RIDER_RIDE
    }else if self.userProfile?.roleAtSignup == UserProfile.PREFERRED_ROLE_RIDER{
      self.userRecentRideType =  Ride.RIDER_RIDE
    }else{
      self.userRecentRideType = Ride.PASSENGER_RIDE
    }
    SharedPreferenceHelper.storeRecentUserRideType(rideType: self.userRecentRideType!)
    return self.userRecentRideType!
  }

  public func setUserRecentRideType(rideType : String){
    AppDelegate.getAppDelegate().log.debug("setUserRecentRideType() \(rideType)")
    self.userRecentRideType = rideType
    SharedPreferenceHelper.storeRecentUserRideType(rideType: rideType)
  }

  // MARK: DataCache Helper methods

  public static func removeUserDataCache(){
    AppDelegate.getAppDelegate().log.debug("removeUserDataCache()")

    SharedPreferenceHelper.clearSharedPreferences()
    self.sharedInstance?.clearUserDataFromPersistence()
    self.sharedInstance?.removeCacheInstance()

  }
  public static func removeUserDataCachePersistence(){
    AppDelegate.getAppDelegate().log.debug("removeUserDataCachePersistence()")

    self.sharedInstance?.removeCacheInstance()


  }

  public func loadUserCompleteProfileAndAccountDetails(userId : String, sessionChangeCompletionHandler : @escaping CompletionHandlers.sessionChangeCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("loadUserCompleteProfileAndAccountDetails() \(userId)")

    self.getcompleteProfile(userId: userId, targetViewController: nil, completionHandler: { (responseObject, error) -> Void in
      if responseObject != nil {
        sessionChangeCompletionHandler(true, nil)
      }
      else {
        sessionChangeCompletionHandler(false, error)
      }
    })
  }

  public func loadFromLocalPersistenceToCache() throws{
    AppDelegate.getAppDelegate().log.debug("loadFromLocalPersistenceToCache()")
    self.getCompleteProfileFromPersistence(userId: (QRSessionManager.sharedInstance?.getUserId())!,targetViewController: nil)
    self.recentLocations = getRecentLocations()!
    self.getCoTravellersFromPersistence()
  }

    func loadUserDataFromServerAndRefreshInPersistence(){
      self.getCompleteProfileFromServer(userId: (QRSessionManager.sharedInstance?.getUserId())!)
      var version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        if version == nil{
            version = AppConfiguration.APP_CURRENT_VERSION_NO
        }
        if  SharedPreferenceHelper.getAppVersion() == nil {
            SharedPreferenceHelper.setAppVersion(version: version!)
        }
        if SharedPreferenceHelper.getAppVersion() != nil && SharedPreferenceHelper.getAppVersion() != version{
            self.getCoTravellersFromServer()
            UserCoreDataHelper.clearRecentLocations()
            SharedPreferenceHelper.setAppVersion(version: version!)
        }
    }

    func clearUserDataFromPersistence(){
      self.clearUserCompleteProfileInPersistence()
      UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.userRecentLocationTable)
      ContactPersistenceHelper.clearAllContacts()
    }
  public func clearLocalMemoryOnSessionInitializationFailure(){
    AppDelegate.getAppDelegate().log.debug("clearLocalMemoryOnSessionInitializationFailure()")
    self.removeCacheInstance()
  }

  public func clearUserDataCache(){
    AppDelegate.getAppDelegate().log.debug("clearUserDataCache()")
    self.currentUser = nil
    self.userProfile = nil
    self.vehicle = nil
    self.uservehicles = []
    self.userAccount = nil
    self.uservehicles.removeAll()
    self.userAccount = nil
    self.userFavouriteLocations.removeAll()
    self.blockedUsers.removeAll()
    self.preferredRidePartners.removeAll()
    self.userRidePathGroups.removeAll()
    self.joinedGroups.removeAll()
    self.ridePreferences = nil
    self.securityPreferences = nil
    self.emailPreferences = nil
    self.smsPreferences = nil
    self.whatsAppPreferences = nil
    self.userVacation = nil
    self.linkedWallets.removeAll()
    self.nomineeDetails = nil
 }

  private func updateDefaultVehicleDetailsOfUser() {
    AppDelegate.getAppDelegate().log.debug("updateDefaultVehicleDetailsOfUser()")
    let defaultClientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
    if (defaultClientConfiguration != nil) {
      let currentUserId = SharedPreferenceHelper.getLoggedInUserId();
      let defaultVehicle : Vehicle = Vehicle(ownerId : currentUserId, vehicleModel : Vehicle.VEHICLE_MODEL_HATCHBACK, registrationNumber : nil, capacity : defaultClientConfiguration?.carDefaultCapacity, fare : defaultClientConfiguration?.carDefaultFare, imageURI : nil)
      self.vehicle = defaultVehicle
    }
  }
  func updateUserProfileWithTheEmergencyContact( emergencyContact : String,viewController : UIViewController){
    AppDelegate.getAppDelegate().log.debug("updateUserProfileWithTheEmergencyContact() \(emergencyContact)")
    if userProfile == nil {
      return
    }
    securityPreferences?.emergencyContact = emergencyContact
    userProfile!.emergencyContactNumber = emergencyContact
    SecurityPreferencesUpdateTask(viewController: viewController, securityPreferences: securityPreferences!, securityPreferencesUpdateReceiver: nil).updateSecurityPreferences()
  }
  func getHomeLocation() -> UserFavouriteLocation?{
    AppDelegate.getAppDelegate().log.debug("getHomeLocation()")
    if userFavouriteLocations.isEmpty == true{
      return nil
    }
    for location in userFavouriteLocations{
      if UserFavouriteLocation.HOME_FAVOURITE.caseInsensitiveCompare(location.name!) == ComparisonResult.orderedSame{
        return location
      }
    }
    return nil
  }
    func getUserBasicInfo(userId : Double ,handler:@escaping UserBasicInfoCompletionHandler){
        AppDelegate.getAppDelegate().log.debug(userId)
        if let userBasicInfo = userBasicInfos[userId]{
            handler(userBasicInfo, nil, nil)
            return
        }

        UserRestClient.getUserBasicInfo(userId: userId, viewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let userBasicInfo = Mapper<UserBasicInfo>().map(JSONObject: responseObject!["resultData"])
                if UserBasicInfo.validateUserBasicInfo(userBasicInfo: userBasicInfo)
                {
                    self.userBasicInfos[userId] = userBasicInfo
                    handler(userBasicInfo,nil,nil)
                }
                else
                {
                    handler(nil,nil,nil)
                }
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                handler(nil,responseError,error)
            }else{
                handler(nil,nil,error)
            }
        }
    }
    func getUserBasicInfo(userId : Double) -> UserBasicInfo?{
        AppDelegate.getAppDelegate().log.debug("")
        return userBasicInfos[userId]
    }
    func saveUserBasicInfo(userBasicInfo : UserBasicInfo) {
        userBasicInfos[userBasicInfo.userId!] = userBasicInfo
    }

  func getOfficeLocation() -> UserFavouriteLocation?{
    AppDelegate.getAppDelegate().log.debug("getOfficeLocation()")
    if userFavouriteLocations.isEmpty == true{
      return nil
    }
    for location in userFavouriteLocations{
      if UserFavouriteLocation.OFFICE_FAVOURITE.caseInsensitiveCompare(location.name!) == ComparisonResult.orderedSame{
        return location
      }
    }
    return nil
  }
  static func storeTotalBonusPoints( totalBonusPoints: Int)
  {
    SharedPreferenceHelper.storeTotalBonusPoints(bonusPoints: totalBonusPoints)
  }

  static func getTotalBonusPoints() -> Int?
  {
    return SharedPreferenceHelper.getTotalBonusPoints()
  }
  func addAccountUpdateListener(key : String,accountUpdateListener :AccountUpdateListener){
    AppDelegate.getAppDelegate().log.debug("addAccountUpdateListener \(key)")
    accountUpdateListeners[key] = accountUpdateListener
  }
  func removeAccountUpdateListener(key : String){
    AppDelegate.getAppDelegate().log.debug("removeAccountUpdateListener \(key)")
    accountUpdateListeners.removeValue(forKey: key)
  }
  func notifyUserLockedStatus()
  {
    if userStatusUpdateReceiver != nil
    {
      userStatusUpdateReceiver!.userStatusLocked()
    }
  }
  func addUserStatusUpdateReceiver(userStatusUpdateReceiver : UserStatusUpdateReceiver)
  {
    self.userStatusUpdateReceiver = userStatusUpdateReceiver;
  }
    func getRidePartnerContacts() -> [Contact]?
    {
        var contacts = [Contact]()
        for contact in totalRidePartnersContact
        {
            contacts.append(contact.1)
        }
        return contacts
    }
  func storeRidePartnerContact(contact : Contact)
  {
    contact.refreshedDate = NSDate()
    ContactPersistenceHelper.storeRidePartnerContact(contact: contact)
    totalRidePartnersContact[contact.contactId!] = contact
  }
  func getRidePartnerContact(contactId : String) -> Contact?
  {
    return totalRidePartnersContact[contactId]
  }

  func removeRidePartners(contactId : String)
  {
    ContactPersistenceHelper.deleteContact(contactId: contactId)
    totalRidePartnersContact.removeValue(forKey: contactId)

  }
    func checkReVerificationStatus(handler: @escaping receiveReverificationStatus){
        if isReVerifyShouldDisplay == nil{
            reVerficationStatusGetingFromServer(handler: handler)
        }
        else
        {
            handler(isReVerifyShouldDisplay)
        }
    }
    func reVerficationStatusGetingFromServer(handler: @escaping receiveReverificationStatus){

        if userProfile!.email == nil{
            return
        }
        UserRestClient.isReVerificationMailSent(userId: QRSessionManager.getInstance()!.getUserId(), email: userProfile!.email!, targetViewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.isReVerifyShouldDisplay = responseObject!["resultData"]! as? Bool
                handler(self.isReVerifyShouldDisplay)
            }
        }
    }
    func setReverficationStatus(isReVerifyDisplay : Bool){
        isReVerifyShouldDisplay = isReVerifyDisplay
    }
    func getNonQuickRIdeUsersContacts(mobileContacts : String, handler : @escaping NonQuickrideUsersContactsReceiverhandler){
        if nonQuirideUsers != nil{
            handler(nonQuirideUsers!)
            return
        }
        QuickRideProgressSpinner.startSpinner()
        RideServicesClient.getvalidContacts(userId: userId!, mobileContacts: mobileContacts) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let validContacts = Mapper<Contact>().map(JSONObject: responseObject!["resultData"])
                if self.nonQuirideUsers == nil{
                    self.nonQuirideUsers = [Contact]()
                }
                self.nonQuirideUsers?.append(validContacts!)
                handler(self.nonQuirideUsers)
            }
        }
    }
    func getOnTimeCompliance(viewController: UIViewController, handler: @escaping OnTimeComplianceReceiverHandler){
        if self.onTimeCompliance != nil{
            handler(self.onTimeCompliance)
            return
        }
        UserRestClient.getUserOnTimeComplianceRating(userId: userId!, viewController: viewController){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.onTimeCompliance = responseObject!["resultData"] as? String
                handler(self.onTimeCompliance)
            }
        }
    }
    func checkIsRidePartner(userId: Double)-> Bool{
        let contact = self.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber : userId))
        var isRidePartner = false
        if contact != nil && contact!.contactType == Contact.RIDE_PARTNER{
            isRidePartner = true
        }
        return isRidePartner
    }
    func getCurrentUserEmail() -> String{
        if userProfile != nil{
            if let emailForCm = userProfile?.emailForCommunication{
                return emailForCm
            }
            else{
                if let emailForOff = userProfile?.email{
                    return emailForOff
                }
                else{
                    return ""
                }
            }
        }else{
            return ""
        }
    }
    public func getOtherUserCompleteProfile(userId : String, completeProfileRetrievalCompletionHandler : @escaping CompletionHandlers.otherUserCompleteProfileRetrievalCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getOtherUserCompleteProfile() \(userId)")
        if let completeUserProfile = otherUserCompleteProfile[userId] {
            completeProfileRetrievalCompletionHandler(completeUserProfile, nil, nil)

        }else{
            self.getOtherUserCompleteProfileFromServer(userId: userId, targetViewController: nil, completionHandler: completeProfileRetrievalCompletionHandler)
        }
    }

    public func getOtherUserCompleteProfileFromServer(userId : String, targetViewController : UIViewController?, completionHandler : CompletionHandlers.otherUserCompleteProfileRetrievalCompletionHandler?){
        AppDelegate.getAppDelegate().log.debug("getOtherUserCompleteProfileFromServer() \(userId)")
        UserRestClient.getUserInformation(userId: userId, targetViewController: targetViewController, completionHandler: { (responseObject, error) -> Void in
            if responseObject != nil  && responseObject!["result"] as! String == "SUCCESS" {
                let completeUserObj = Mapper<UserFullProfile>().map(JSONObject: responseObject!["resultData"])
                self.otherUserCompleteProfile[userId] = completeUserObj
                completionHandler?(self.otherUserCompleteProfile[userId]!, nil, nil)
            }else{
                completionHandler?(nil, error, responseObject)
            }
        })

    }


    func getUserPreferredRoute(startLatitude : Double,startLongitude : Double,endLatitude : Double,endLongitude : Double) -> UserPreferredRoute?{
        let userPreferredRoutes = getUserPreferredRoutes()
        var newUserPreferredRoute : UserPreferredRoute?
        if startLatitude != 0 && startLongitude != 0 && endLatitude != 0 && endLongitude != 0{
            if !userPreferredRoutes.isEmpty{
                for preferredRoute in userPreferredRoutes{
                    if preferredRoute.fromLatitude!.getDecimalValueWithOutRounding(places: 4) == startLatitude.getDecimalValueWithOutRounding(places: 4) && preferredRoute.fromLongitude!.getDecimalValueWithOutRounding(places: 4) == startLongitude.getDecimalValueWithOutRounding(places: 4) && preferredRoute.toLatitude!.getDecimalValueWithOutRounding(places: 4) == endLatitude.getDecimalValueWithOutRounding(places: 4) && preferredRoute.toLongitude!.getDecimalValueWithOutRounding(places: 4) == endLongitude.getDecimalValueWithOutRounding(places: 4){

                        newUserPreferredRoute = preferredRoute
                        break
                    }
                }
            }
        }
        return newUserPreferredRoute
    }


    func getUserPreferredRoutes() -> [UserPreferredRoute]{
       return userPreferredRoutes
    }

    func saveUserPreferredRoute(userPreferredRoute : UserPreferredRoute){
        userPreferredRoutes.append(userPreferredRoute)
        MyRoutesCachePersistenceHelper.saveUserPreferredRoute(userPreferredRoute: userPreferredRoute)
    }

    func updateUserPreferredRoute(userPreferredRoute : UserPreferredRoute){

        var newPreferredRoutes = [UserPreferredRoute]()
        newPreferredRoutes.append(userPreferredRoute)
        var index = -1
        for (i, prefRoute) in userPreferredRoutes.enumerated() {
            if prefRoute.id == userPreferredRoute.id{
                index = i
                break
            }
        }
        if index != -1{
            userPreferredRoutes[index] = userPreferredRoute
        }
        MyRoutesCachePersistenceHelper.updateUserPreferredRoute(userPreferredRoute: userPreferredRoute)
   }
    func deleteUserPreferredRoute(userPreferredRoute : UserPreferredRoute){
        var indexToRemove : Int?
        for (index,preferredRoute) in userPreferredRoutes.enumerated(){
            if preferredRoute.id == userPreferredRoute.id{
                indexToRemove = index
                break
            }
        }
        if indexToRemove != nil{
            userPreferredRoutes.remove(at: indexToRemove!)
        }
        MyRoutesCachePersistenceHelper.deleteUserPreferredRoute(userPreferredRoute: userPreferredRoute)

    }

    func saveOrUpdateNomineeDetails(nomineeDetails : NomineeDetails){

        if self.nomineeDetails != nil{
            UserCoreDataHelper.updateNomineeDetails(nomineeDetails: nomineeDetails)
        }else{
            UserCoreDataHelper.saveNomineeDetails(nomineeDetails: nomineeDetails)
        }
        self.nomineeDetails = nomineeDetails
    }

    func getNomineeDetails() -> NomineeDetails?
    {
        return nomineeDetails
    }
     func getPendingBillsFromServer(){
        AccountRestClient.getPendingLinkedWalletTransactions(userId: (QRSessionManager.getInstance()?.getUserId())!, viewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                self.pendingLinkedWalletTransactions = Mapper<LinkedWalletPendingTransaction>().mapArray(JSONObject: responseObject!["resultData"])
            }
        }
    }

    func updateUserObject(user : User){
        self.currentUser = user
        UserCoreDataHelper.updateUserObject(userObject: user)
    }
    func addLinkedWalletTransactionStatusListener(linkedWalletTransactionStatusListener : LinkedWalletTransactionStatusReceiver) {
        self.linkedWalletTransactionStatusReceiver = linkedWalletTransactionStatusListener
    }

    func removeLinkedWalletTransactionStatusListener() {
        linkedWalletTransactionStatusReceiver = nil
    }

    func notifyLinkedWalletTrasactionUpdatedStatus(linkedWalletTransactionStatus: LinkedWalletTransactionStatus) {
        self.linkedWalletTransactionStatusReceiver?.linkedWalletTransactionStatusUpdated(linkedWalletTransactionStatus: linkedWalletTransactionStatus)
    }


    func updateAutoConfirmDisplayStatusInMatchingOptions(key : String, status : Bool) {
        autoConfirmDisplayStatusInMatchingOptions[key] = status
    }
    func getAutoConfirmDisplayStatusInMatchingOptions(key : String) -> Bool{
      if autoConfirmDisplayStatusInMatchingOptions[key] != nil
      {
          return autoConfirmDisplayStatusInMatchingOptions[key]!
      }
      else
      {
          return false
      }
     }

    static func getCurrentUserId() -> Double{
        if let userId = UserDataCache.sharedInstance?.currentUser?.phoneNumber{
            return userId
        }
        return 0
    }
    
    //MARK: get companyIdVerificationData
    func getCompanyIdVerificationData(handler: @escaping CompletionHandlers.companyIdVerificationDataCompletionHandler) {
        if companyIdVerificationData != nil {
            handler(companyIdVerificationData)
        } else {
            getCompanyIdVerificationDataFromServer(handler: handler)
        }
    }
    
    func getCompanyIdVerificationDataFromServer(handler: @escaping CompletionHandlers.companyIdVerificationDataCompletionHandler) {
        ProfileVerificationRestClient.getInitiateCompanyIdVerification(userId: QRSessionManager.getInstance()?.getUserId() ?? "") { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                self.companyIdVerificationData = Mapper<CompanyIdVerificationData>().map(JSONObject: responseObject!["resultData"])
                handler(self.companyIdVerificationData)
            } else {
                handler(nil)
            }
        }
    }
    
    //MARK: get Endorsement verification info
    func getEndorsementVerificationInfo(userId: String, handler: @escaping CompletionHandlers.endorsementVerificationInfoCompletionHandler) {
        if endorsementVerificationInfo[userId] != nil && !endorsementVerificationInfo[userId]!.isEmpty {
            handler(endorsementVerificationInfo[userId]!)
            getEndorsementVerificationInfoFromServer(userId: userId, handler: handler)
        } else {
            getEndorsementVerificationInfoFromServer(userId: userId, handler: handler)
        }
    }
    
    func getEndorsementVerificationInfoFromServer(userId: String, handler: CompletionHandlers.endorsementVerificationInfoCompletionHandler?) {
        ProfileVerificationRestClient.getEndorsementData(userId: userId) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                let endorsementVerificationInfos = Mapper<EndorsementVerificationInfo>().mapArray(JSONObject: responseObject!["resultData"]) ?? [EndorsementVerificationInfo]()
                self.filterEndorsementInfoForCurrentUserId(userId: userId, endorsementVerificationInfo: endorsementVerificationInfos)
                handler?(self.endorsementVerificationInfo[userId] ?? [EndorsementVerificationInfo]())
            } else {
                handler?([EndorsementVerificationInfo]())
            }
        }
    }
    
    private func filterEndorsementInfoForCurrentUserId(userId: String, endorsementVerificationInfo: [EndorsementVerificationInfo]) {
        self.endorsementVerificationInfo[userId]?.removeAll()
        for endorsementVerification in endorsementVerificationInfo {
            if endorsementVerification.userId == Double(userId) {
                if self.endorsementVerificationInfo[userId] == nil {
                    self.endorsementVerificationInfo[userId] = [EndorsementVerificationInfo]()
                }
                self.endorsementVerificationInfo[userId]!.append(endorsementVerification)
            } else {
                continue
            }
        }
    }
    
    func getSkillsAndInterests(userId: String, handler: @escaping CompletionHandlers.skillsAndInterestsDataCompletionHandler) {
        if skillsAndInterestsData != nil {
            handler(skillsAndInterestsData)
        } else {
            getSkillsAndInterestsFromServer(userId: userId, handler: handler)
        }
    }
    
    private func getSkillsAndInterestsFromServer(userId: String, handler: @escaping CompletionHandlers.skillsAndInterestsDataCompletionHandler) {
        ProfileRestClient.getUserAttributList(userId: userId) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                self.skillsAndInterestsData = Mapper<SkillsAndInterestsData>().map(JSONObject: responseObject!["resultData"])
                handler(self.skillsAndInterestsData)
            } else {
                handler(nil)
            }
        }
    }
    
    func getRideEtiquetteCertificate(userId: String, handler: @escaping CompletionHandlers.rideEtiquetteCertificateCompletionHandler) {
        if rideEtiquetteCertification[userId] != nil {
            handler(rideEtiquetteCertification[userId])
        } else {
            getRideEtiquetteCertificateFromServer(userId: userId, handler: handler)
        }
    }
    
    private func getRideEtiquetteCertificateFromServer(userId: String, handler: @escaping CompletionHandlers.rideEtiquetteCertificateCompletionHandler) {
        ProfileRestClient.getRideEtiquetteCertificate(userId: userId) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                self.rideEtiquetteCertification[userId] = Mapper<RideEtiquetteCertification>().map(JSONObject: responseObject!["resultData"])
                handler(self.rideEtiquetteCertification[userId])
            } else {
                handler(self.rideEtiquetteCertification[userId])
            }
        }
    }
    func getTotalCompletedRides() -> Int{
        if let numberOfRidesAsRider = userProfile?.numberOfRidesAsRider, let numberOfRidesAsPassenger =  userProfile?.numberOfRidesAsPassenger{
            return Int(numberOfRidesAsRider + numberOfRidesAsPassenger)
        }else{
            return 0
        }
    }
}
