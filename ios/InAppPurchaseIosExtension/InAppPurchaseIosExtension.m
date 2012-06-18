//
//  InAppPurchaseIosExtension.m
//  InAppPurchaseIosExtension
//
//  Created by Richard Lord on 01/05/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#import "FRETypeConversion.h"
#import <StoreKit/StoreKit.h>
#import "StoreKitDelegate.h"
#import "NativeMessages.h"

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }

StoreKitDelegate* IAP_observer;
NSMutableDictionary* IAP_returnObjects;
NSMutableDictionary* IAP_products;

NSString* IAP_storeReturnObject( id object )
{
    NSString* key;
    do
    {
        key = [NSString stringWithFormat: @"%i", random()];
    } while ( [IAP_returnObjects valueForKey:key] != nil );
    [IAP_returnObjects setValue:object forKey:key];
    return key;
}

id IAP_getReturnObject( NSString* key )
{
    id object = [IAP_returnObjects valueForKey:key];
    [IAP_returnObjects setValue:nil forKey:key];
    return object;
}

DEFINE_ANE_FUNCTION( canMakePayments )
{
    uint32_t retValue = ([SKPaymentQueue canMakePayments]) ? 1 : 0;
    
    FREObject result;
    if ( FRENewObjectFromBool(retValue, &result ) == FRE_OK )
    {
        return result;
    }
    return NULL;
}

DEFINE_ANE_FUNCTION( getProductInformation )
{
    NSMutableSet* ids;
    if( IAP_FREGetObjectAsSetOfStrings( argv[0], &ids ) != FRE_OK ) return NULL;
    
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: ids];
    request.delegate = IAP_observer;
    [request start];
    
    return NULL;
}

DEFINE_ANE_FUNCTION( getStoredProductInformation )
{
    NSString* key;
    if( IAP_FREGetObjectAsString( argv[0], &key ) != FRE_OK ) return NULL;
    
    SKProductsResponse* response = IAP_getReturnObject( key );
    if( response == nil || response.products == nil )
    {
        return NULL;
    }
    FREObject products;
    if ( FRENewObject( "Array", 0, NULL, &products, NULL ) == FRE_OK && FRESetArrayLength( products, response.products.count ) == FRE_OK )
    {
        int nextIndex = 0;
        for( SKProduct* product in response.products )
        {
            FREObject asProduct;
            if( IAP_FRENewObjectFromSKProduct( product, &asProduct ) == FRE_OK )
            {
                FRESetArrayElementAt( products, nextIndex, asProduct );
                ++nextIndex;
            }
        }
        [response release];
        return products;
    }
    [response release];
    return NULL;
}

DEFINE_ANE_FUNCTION( purchaseProduct )
{
    NSString* identifier;
    if( IAP_FREGetObjectAsString( argv[0], &identifier ) != FRE_OK ) return NULL;
    
    int quantity = 0;
    if( FREGetObjectAsInt32( argv[1], &quantity ) != FRE_OK ) return NULL;
    
    if( quantity < 1 )
    {
        return NULL;
    }
    
    SKProduct* product = [IAP_products valueForKey:identifier];
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

DEFINE_ANE_FUNCTION( finishTransaction )
{
    NSString* identifier;
    if( IAP_FREGetObjectAsString( argv[0], &identifier ) != FRE_OK ) return NULL;
    
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

DEFINE_ANE_FUNCTION( restoreTransactions )
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    return NULL;
}

DEFINE_ANE_FUNCTION( getCurrentTransactions )
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
            if( IAP_FRENewObjectFromSKTransaction( transaction, &asTransaction ) == FRE_OK )
            {
                FRESetArrayElementAt( asTransactions, nextIndex, asTransaction );
                ++nextIndex;
            }
        }
        return asTransactions;
    }
    return NULL;
}

DEFINE_ANE_FUNCTION( getStoredTransaction )
{
    NSString* key;
    if( IAP_FREGetObjectAsString( argv[0], &key ) != FRE_OK ) return NULL;
    
    SKPaymentTransaction* transaction = IAP_getReturnObject( key );
    if( transaction == nil )
    {
        return NULL;
    }

    FREObject asTransaction;
    if( IAP_FRENewObjectFromSKTransaction( transaction, &asTransaction ) == FRE_OK )
    {
        [transaction release];
        return asTransaction;
    }
    [transaction release];
    return NULL;
}

void InAppPurchaseContextInitializer( void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet )
{
    static FRENamedFunction functionMap[] = {
        MAP_FUNCTION( canMakePayments, NULL ),
        MAP_FUNCTION( getProductInformation, NULL ),
        MAP_FUNCTION( getStoredProductInformation, NULL ),
        MAP_FUNCTION( purchaseProduct, NULL ),
        MAP_FUNCTION( finishTransaction, NULL ),
        MAP_FUNCTION( restoreTransactions, NULL ),
        MAP_FUNCTION( getCurrentTransactions, NULL ),
        MAP_FUNCTION( getStoredTransaction, NULL )
    };
    
	*numFunctionsToSet = sizeof( functionMap ) / sizeof( FRENamedFunction );
	*functionsToSet = functionMap;
    
    IAP_observer = [[StoreKitDelegate alloc] initWithContext:ctx andReturnObjects:IAP_returnObjects andProducts:IAP_products];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:IAP_observer];
}

void InAppPurchaseContextFinalizer( FREContext ctx )
{
	return;
}

void InAppPurchaseExtensionInitializer( void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) 
{ 
    extDataToSet = NULL;  // This example does not use any extension data. 
    *ctxInitializerToSet = &InAppPurchaseContextInitializer;
    *ctxFinalizerToSet = &InAppPurchaseContextFinalizer;
    
    IAP_products = [[NSMutableDictionary alloc] init];
    IAP_returnObjects = [[NSMutableDictionary alloc] init];
}

void InAppPurchaseExtensionFinalizer()
{
    return;
}