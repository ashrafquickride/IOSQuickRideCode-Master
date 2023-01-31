@protocol APayAuthorizationResponseBuilder <NSObject>

- (void) withStatus:(NSString *) status;

- (void) withAuthCode:(NSString *) authCode;

- (void) withClientId:(NSString *) clientId;

- (void) withRedirectURI:(NSString *) redirectURI;

@end
