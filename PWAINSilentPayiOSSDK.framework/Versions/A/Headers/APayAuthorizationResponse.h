#import <Foundation/Foundation.h>
#import "APayAuthorizationResponseBuilder.h"


@interface APayAuthorizationResponse : NSObject

@property (strong, nonatomic, readonly) NSString *status;
@property (strong, nonatomic, readonly) NSString *authCode;
@property (strong, nonatomic, readonly) NSString *clientId;
@property (strong, nonatomic, readonly) NSString *redirectUri;

// Restricting the usage of init method.
-(instancetype) init __attribute__((unavailable("Unavailable, use builder instead")));

/**
 * This method build the process payment response object with the builder protocol passed to it.
 */
+ (instancetype) build:(void(^)(id<APayAuthorizationResponseBuilder>builder))buildBlock;

@end



