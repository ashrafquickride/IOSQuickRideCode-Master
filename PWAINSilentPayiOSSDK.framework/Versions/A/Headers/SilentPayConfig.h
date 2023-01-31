#import <Foundation/Foundation.h>

@interface SilentPayConfig : NSObject

@property (strong, nonatomic, readonly) NSString *configurationURL;
@property (assign, nonatomic, readonly) int updateConfigInMilliSeconds;
@property (assign, nonatomic, readonly) int minimumLogLevel;
@property (assign, nonatomic, readonly) BOOL isPublishLogsEnabled;
@property (assign, nonatomic, readonly) long publishMetricsInMilliSeconds;
@property (assign, nonatomic, readonly) long maxMetricSize;
@property (strong, nonatomic, readonly) NSArray *authScopes;

/**
 * This makes the init method of SilentPayConfig class inaccessible for the outer world.
 */
-(instancetype) init __attribute__((unavailable("init not available, use getInstance")));

/**
 * Only method to get the instance of SilentPayConfig.
 *
 * @return the SilentPayConfig instance
 */
+ (id)  getInstance;

/**
 * Method to get the URL query from the request object.
 *
 * @params logLevel the process payment request object
 *
 * @return the URL with the request parameters
 */
- (BOOL) shouldPublishLogsForLevel:(int)logLevel;


/**
 * Method to get the amazon backend Host for internal communication.
 *
 * @return the backend endpoint.
 */
+ (NSString *) getAmazonBackendHost;

@end
