#import "APayAuthorizationResponse.h"

@protocol APayAuthorizeCallbackDelegate

-(void) onSuccess:(APayAuthorizationResponse *)response;

-(void) onFailure:(NSError *)error;

- (void) onMobileSDKError:(NSError *) error;

- (void) onCancel:(NSError *)error;

@end

