#import <Foundation/Foundation.h>
#import <PWAINSilentPayiOSSDK/SilentPayOperation.h>
#import "SilentPayConfig.h"
#import "APayAuthorizeRequest.h"
#import "APayAuthorizeCallbackDelegate.h"
#import "APayChargeRequest.h"
#import "APayChargeCallbackDelegate.h"
/**
 Hardened SDK
 version 1.3
 **/
@interface AmazonPay : NSObject

@property (nonatomic, assign) enum SilentPayOperation operation;
@property (nonatomic, strong) NSDate *startTime;

/**
 * This makes the init method of AmazonPay class inaccessible for the outer world.
 */
-(instancetype) init __attribute__((unavailable("Unavailable, use sharedInstance instead.")));

/**
 * Method to get the static instance of the class
 */
+ (AmazonPay *) sharedInstance;

/**
 * Method to get the static silentPayConfig field.
 */
- (SilentPayConfig *) getConfig;

/**
 * Method to authorize the account with AmazonPay
 **/
-(void) authorize: (APayAuthorizeRequest *)authorizeRequest
apayAuthorizeCallback:(id<APayAuthorizeCallbackDelegate>) apayAuthorizeCallback;


- (void) charge:(APayChargeRequest *)apayChargeRequest
apayChargeCallback:(id<APayChargeCallbackDelegate>) apayChargeCallback;

/**
 * Handles the response when transaction cancelled by user
 */
- (void) handleCancelledResponse;


/**
 * Handles the redirection back to the app from the PWA UI
 *
 * @param url the redirect URL
 * @param sourceApplication the sourceApplication where it comes from
 *
 * @return whether the response with the URl was handled successfully or not.
 */
- (BOOL) handleRedirectURL:(NSURL *)url
         sourceApplication:(NSString *)sourceApplication;


@end
