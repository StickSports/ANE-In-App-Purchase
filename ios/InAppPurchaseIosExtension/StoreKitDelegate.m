//
//  StoreKitDelegate.m
//  InAppPurchaseIosExtension
//
//  Created by Richard Lord on 01/05/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import "StoreKitDelegate.h"
#import "NativeMessages.h"

@interface StoreKitDelegate () {
}
@property FREContext context;
@property (retain)NSMutableDictionary* returnObjects;

@end

@implementation StoreKitDelegate

@synthesize context, returnObjects;

- (NSString*)storeReturnObject:(id)object
{
    NSString* key;
    do
    {
        key = [NSString stringWithFormat: @"%i", random()];
    } while ( [returnObjects valueForKey:key] != nil );
    [returnObjects setValue:object forKey:key];
    return key;
}

- (id)initWithContext:(FREContext)extensionContext andDictionary:(NSMutableDictionary*)objects
{
    self = [super init];
    if( self )
    {
        context = extensionContext;
        returnObjects = objects;
    }
    return self;
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSString* code = [self storeReturnObject:response];
    FREDispatchStatusEventAsync( context, code.UTF8String, fetchProductsSuccess );
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [request release];
    FREDispatchStatusEventAsync( context, "", fetchProductsFailed );
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    FREDispatchStatusEventAsync( context, error.localizedDescription.UTF8String, restoreTransactionsFailed );
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    FREDispatchStatusEventAsync( context, "", restoreTransactionsComplete );
}


@end
