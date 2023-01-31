#import "APayChargeResponse.h"

@protocol APayChargeCallbackDelegate

-(void) onSuccess:(APayChargeResponse *)response;

-(void) onFailure:(NSError *)error;

- (void) onMobileSDKError:(NSError *) error;

- (void) onCancel;

@end



