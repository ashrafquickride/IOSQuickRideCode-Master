#import <Foundation/Foundation.h>
#import "APayChargeResponseBuilder.h"

typedef NS_ENUM(NSInteger, Status){
    SUCCESS,
    FAILURE
};


@interface APayChargeResponse : NSObject

@property (strong, nonatomic, readonly) NSString* transactionId;
@property (strong, nonatomic, readonly) NSString* signature;
@property (strong, nonatomic, readonly) NSString* orderTotalAmount;
@property (strong, nonatomic, readonly) NSString* orderTotalCurrencyCode;
@property (strong, nonatomic, readonly) NSString* status;
@property (strong, nonatomic, readonly) NSString* reasonCode;
@property (strong, nonatomic, readonly) NSString* transactionDate;
@property (strong, nonatomic, readonly) NSString* sellerOrderId;
@property (strong, nonatomic, readonly) NSString* customInformation;
@property (strong, nonatomic, readonly) NSString* chargeDescription;

// Restricting the usage of init method.
-(instancetype) init __attribute__((unavailable("Unavailable, use build instead")));

/**
 * This method build the process payment response object with the builder protocol passed to it.
 */
+ (instancetype) build:(void(^)(id<APayChargeResponseBuilder>builder))buildBlock;

@end

