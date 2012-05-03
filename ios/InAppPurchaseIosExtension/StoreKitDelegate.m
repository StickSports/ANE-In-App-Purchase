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
@property (retain)NSMutableDictionary* products;
@end

@implementation StoreKitDelegate

@synthesize context, returnObjects, products;

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

- (id)initWithContext:(FREContext)extensionContext andReturnObjects:(NSMutableDictionary*)objects andProducts:(NSMutableDictionary*)prods;
{
    self = [super init];
    if( self )
    {
        context = extensionContext;
        returnObjects = objects;
        products = prods;
    }
    return self;
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [request release];
    [response retain];
    NSString* code = [self storeReturnObject:response];
    for( SKProduct* product in response.products )
    {
        [products setValue:product forKey:product.productIdentifier];
    }
    FREDispatchStatusEventAsync( context, code.UTF8String, fetchProductsSuccess );
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [request release];
    FREDispatchStatusEventAsync( context, error.localizedDescription.UTF8String, fetchProductsFailed );
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSString* code;
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [transaction retain];
                code = [self storeReturnObject:transaction];
                FREDispatchStatusEventAsync( context, code.UTF8String, transactionPurchased );
                break;
            case SKPaymentTransactionStateFailed:
                [transaction retain];
                code = [self storeReturnObject:transaction];
                FREDispatchStatusEventAsync( context, code.UTF8String, transactionFailed );
                break;
            case SKPaymentTransactionStateRestored:
                [transaction retain];
                code = [self storeReturnObject:transaction];
                FREDispatchStatusEventAsync( context, code.UTF8String, transactionRestored );
            default:
                break;
        }
    }
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
