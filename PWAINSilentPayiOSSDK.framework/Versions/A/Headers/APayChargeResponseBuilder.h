@protocol APayChargeResponseBuilder <NSObject>

- (void) withTransactionId: (NSString *)transactionId;
- (void) withSignature: (NSString *)signature;
- (void) withOrderTotalAmount: (NSString *)orderTotalAmount;
- (void) withOrderTotalCurrencyCode: (NSString *)orderTotalCurrencyCode;
- (void) withStatus: (NSString *)status;
- (void) withReasonCode: (NSString *)reasonCode;
- (void) withDescription: (NSString *)description;
- (void) withTransactionDate: (NSString *)transactionDate;
- (void) withSellerOrderId: (NSString *)sellerOrderId;
- (void) withCustomInformation: (NSString *)customInformation;

@end




