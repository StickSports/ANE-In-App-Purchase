//
//  StoreKitDelegate.h
//  InAppPurchaseIosExtension
//
//  Created by Richard Lord on 01/05/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FlashRuntimeExtensions.h"

@interface StoreKitDelegate : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    
}
- (id)initWithContext:(FREContext)extensionContext andReturnObjects:(NSMutableDictionary*)objects andProducts:(NSMutableDictionary*)prods;
// SKProductREquestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error;
// SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions;
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error;
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue;

@end
