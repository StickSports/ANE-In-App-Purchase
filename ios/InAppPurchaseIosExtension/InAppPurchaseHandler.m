//
//  InAppPurchaseHandler.m
//  InAppPurchaseIosExtension
//
//  Created by Richard Lord on 18/06/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import "InAppPurchaseHandler.h"
#import <StoreKit/StoreKit.h>
#import "IAP_StoreKitDelegate.h"
#import "IAP_TypeConversion.h"

@interface InAppPurchaseHandler () {
}
@property FREContext context;
@property (retain)NSMutableDictionary* returnObjects;
@property (retain)NSMutableDictionary* products;
@property (retain)IAP_StoreKitDelegate* observer;
@property (retain)IAP_TypeConversion* converter;
@end

@implementation InAppPurchaseHandler

@synthesize context, returnObjects, products, observer, converter;

- (id)initWithContext:(FREContext)extensionContext
{
    self = [super init];
    if( self )
    {
        context = extensionContext;
        returnObjects = [[NSMutableDictionary alloc] init];
        products = [[NSMutableDictionary alloc] init];
        observer = [[IAP_StoreKitDelegate alloc] initWithContext:context andReturnObjects:returnObjects andProducts:products];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
        converter = [[IAP_TypeConversion alloc] init];
    }
    return self;
}

- (NSString*) storeReturnObject:(id)object
{
    NSString* key;
    do
    {
        key = [NSString stringWithFormat: @"%i", random()];
    } while ( [self.returnObjects valueForKey:key] != nil );
    [self.returnObjects setValue:object forKey:key];
    return key;
}

- (id) getReturnObject:(NSString*) key
{
    id object = [self.returnObjects valueForKey:key];
    [self.returnObjects setValue:nil forKey:key];
    return object;
}

- (FREObject) canMakePayments
{
    uint32_t retValue = ([SKPaymentQueue canMakePayments]) ? 1 : 0;
    
    FREObject result;
    if ( FRENewObjectFromBool(retValue, &result ) == FRE_OK )
    {
        return result;
    }
    return NULL;
}

- (FREObject) getProductInformationForIds:(FREObject)asId
{
    NSMutableSet* ids;
    if( [self.converter FREGetObject:asId asSetOfStrings:&ids] != FRE_OK ) return NULL;
    
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: ids];
    request.delegate = self.observer;
    [request start];
    
    return NULL;
}

- (FREObject) getStoredProductInformation:(FREObject)asKey
{
    NSString* key;
    if( [self.converter FREGetObject:asKey asString:&key] != FRE_OK ) return NULL;
    SKProductsResponse* response = [self getReturnObject:key];
    if( response == nil || response.products == nil )
    {
        return NULL;
    }
    FREObject productInfo;
    if ( FRENewObject( "Array", 0, NULL, &productInfo, NULL ) == FRE_OK && FRESetArrayLength( productInfo, response.products.count ) == FRE_OK )
    {
        int nextIndex = 0;
        for( SKProduct* product in response.products )
        {
            FREObject asProduct;
            if( [self.converter FREGetSKProduct:product asObject:&asProduct] == FRE_OK )
            {
                FRESetArrayElementAt( productInfo, nextIndex, asProduct );
                ++nextIndex;
            }
        }
        [response release];
        return productInfo;
    }
    [response release];
    return NULL;
}

- (FREObject) purchaseProduct:(FREObject)asId quantity:(FREObject)asQuantity
{
    NSString* identifier;
    if( [converter FREGetObject:asId asString:&identifier] != FRE_OK ) return NULL;
    
    int quantity = 0;
    if( FREGetObjectAsInt32( asQuantity, &quantity ) != FRE_OK ) return NULL;
    
    if( quantity < 1 )
    {
        return NULL;
    }
    
    SKProduct* product = [self.products valueForKey:identifier];
    if( !product )
    {
        // This method is deprecated. Should fetch the product first, but that's more complicated.
        SKMutablePayment* payment = [SKMutablePayment paymentWithProductIdentifier:identifier];
        payment.quantity = quantity;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else
    {
        SKMutablePayment* payment = [SKMutablePayment paymentWithProduct:product];
        payment.quantity = quantity;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    
    return NULL;
}

- (FREObject) finishTransaction:(FREObject)asId
{
    NSString* identifier;
    if( [self.converter FREGetObject:asId asString:&identifier] != FRE_OK ) return NULL;
    
    NSArray* transactions = [[SKPaymentQueue defaultQueue] transactions];
    BOOL transactionFinished = NO;
    
    for( SKPaymentTransaction* transaction in transactions )
    {
        if( [transaction.transactionIdentifier isEqualToString:identifier] )
        {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            transactionFinished = YES;
            break;
        }
        else if( transaction.transactionState == SKPaymentTransactionStateRestored )
        {
            if( [transaction.originalTransaction.transactionIdentifier isEqualToString:identifier] )
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction.originalTransaction];
                transactionFinished = YES;
                break;
            }
        }
    }
    
    FREObject result;
    if ( FRENewObjectFromBool( transactionFinished, &result ) == FRE_OK )
    {
        return result;
    }
    return NULL;
}

- (FREObject) restoreTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    return NULL;
}

- (FREObject) getCurrentTransactions
{
    NSArray* transactions = [[SKPaymentQueue defaultQueue] transactions];
    if( transactions == nil )
    {
        return NULL;
    }
    
    FREObject asTransactions;
    if ( FRENewObject( "Array", 0, NULL, &asTransactions, NULL ) == FRE_OK && FRESetArrayLength( asTransactions, transactions.count ) == FRE_OK )
    {
        int nextIndex = 0;
        for( SKPaymentTransaction* transaction in transactions )
        {
            FREObject asTransaction;
            if( [self.converter FREGetSKTransaction:transaction asObject:&asTransaction] == FRE_OK )
            {
                FRESetArrayElementAt( asTransactions, nextIndex, asTransaction );
                ++nextIndex;
            }
        }
        return asTransactions;
    }
    return NULL;
}

- (FREObject) getStoredTransaction:(FREObject)asKey
{
    NSString* key;
    if( [self.converter FREGetObject:asKey asString:&key] != FRE_OK ) return NULL;
    
    SKPaymentTransaction* transaction = [self getReturnObject:key];
    if( transaction == nil )
    {
        return NULL;
    }
    
    FREObject asTransaction;
    if( [self.converter FREGetSKTransaction:transaction asObject:&asTransaction] == FRE_OK )
    {
        [transaction release];
        return asTransaction;
    }
    [transaction release];
    return NULL;
}

- (void)dealloc
{
    [returnObjects release];
    [products release];
    [observer release];
    [converter release];
    [super dealloc];
}

@end
