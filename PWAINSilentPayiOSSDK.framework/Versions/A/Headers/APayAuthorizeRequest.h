#import "APayAuthorizeRequestBuilder.h"

@interface APayAuthorizeRequest : NSObject

// Properties

@property (strong, nonatomic, readonly) NSString *codeChallenge;

// Restricting the usage of init method.
-(instancetype) init __attribute__((unavailable("Unavailable, use builder instead")));

/**
 * This method build the get balance request object with the builder protocol passed to it.
 * @param buildBlock a delegate for the builder protocol, to be implemented by the caller method.
 *
 * @return it returns an instance of GetBalanceRequest object.
 */
+ (instancetype) build:(void(^)(id<APayAuthorizeRequestBuilder>builder))buildBlock;

@end

