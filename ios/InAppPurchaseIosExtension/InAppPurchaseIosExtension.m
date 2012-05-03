//
//  InAppPurchaseIosExtension.m
//  InAppPurchaseIosExtension
//
//  Created by Richard Lord on 01/05/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import "FlashRuntimeExtensions.h"
#import "FRETypeConversion.h"
#import <StoreKit/StoreKit.h>
#import "StoreKitDelegate.h"
#import "NativeMessages.h"

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }

StoreKitDelegate* observer;
NSMutableDictionary* returnObjects;
NSMutableDictionary* products;

NSString* storeReturnObject( id object )
{
    NSString* key;
    do
    {
        key = [NSString stringWithFormat: @"%i", random()];
    } while ( [returnObjects valueForKey:key] != nil );
    [returnObjects setValue:object forKey:key];
    return key;
}

id getReturnObject( NSString* key )
{
    id object = [returnObjects valueForKey:key];
    [returnObjects setValue:nil forKey:key];
    return object;
}

FREResult FRENewObjectFromSKProduct( SKProduct* product, FREObject* asProduct )
{
    FREResult result;
    
    result = FRENewObject( ASProduct, 0, NULL, asProduct, NULL);
    if( result != FRE_OK ) return result;
    
    result = FRESetObjectPropertyString( *asProduct, "id", product.productIdentifier );
    if( result != FRE_OK ) return result;
    
    result = FRESetObjectPropertyString( *asProduct, "title", product.localizedTitle );
    if( result != FRE_OK ) return result;
    
    result = FRESetObjectPropertyString( *asProduct, "desc", product.localizedDescription );
    if( result != FRE_OK ) return result;
    
    result = FRESetObjectPropertyNum( *asProduct, "price", product.price.doubleValue );
    if( result != FRE_OK ) return result;

    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    
    result = FRESetObjectPropertyString( *asProduct, "formattedPrice", formattedPrice );
    if( result != FRE_OK ) return result;
    
    result = FRESetObjectPropertyString( *asProduct, "priceLocale", [product.priceLocale localeIdentifier] );
    if( result != FRE_OK ) return result;
    
    return FRE_OK;
}

FREResult FRENewObjectFromSKTransaction( SKPaymentTransaction* transaction, FREObject* asTransaction )
{
    FREResult result;
    
    result = FRENewObject( ASTransaction, 0, NULL, asTransaction, NULL);
    if( result != FRE_OK ) return result;
    
    result = FRESetObjectPropertyString( *asTransaction, "productId", transaction.payment.productIdentifier );
    if( result != FRE_OK ) return result;
    
    result = FRESetObjectPropertyInt( *asTransaction, "productQuantity", transaction.payment.quantity );
    if( result != FRE_OK ) return result;
    
    result = FRESetObjectPropertyString( *asTransaction, "id", transaction.transactionIdentifier );
    if( result != FRE_OK ) return result;
    
    result = FRESetObjectPropertyDate( *asTransaction, "date", transaction.transactionDate );
    if( result != FRE_OK ) return result;
    
    result = FRESetObjectPropertyInt( *asTransaction, "state", transaction.transactionState );
    if( result != FRE_OK ) return result;
    
    if( transaction.transactionState == SKPaymentTransactionStateFailed )
    {
        result = FRESetObjectPropertyError( *asTransaction, "error", transaction.error );
        if( result != FRE_OK ) return result;
    }
    
    if( transaction.transactionState == SKPaymentTransactionStatePurchased )
    {
        result = FRESetObjectPropertyData( *asTransaction, "receipt", transaction.transactionReceipt );
        if( result != FRE_OK ) return result;
    }
    
    if( transaction.transactionState == SKPaymentTransactionStateRestored )
    {
        FREObject original;
        result = FRENewObjectFromSKTransaction( transaction.originalTransaction, &original );
        if( result != FRE_OK ) return result;
        result = FRESetObjectProperty( *asTransaction, "originalTransaction", original, NULL );
        if( result != FRE_OK ) return result;
    }
    
    return FRE_OK;
}

DEFINE_ANE_FUNCTION( initNativeCode )
{
    return NULL;
}

DEFINE_ANE_FUNCTION( isSupported )
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
    if( FREGetObjectAsSetOfStrings( argv[0], &ids ) != FRE_OK ) return NULL;
    
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: ids];
    request.delegate = observer;
    [request start];
    
    return NULL;
}

DEFINE_ANE_FUNCTION( getStoredProductInformation )
{
    NSString* key;
    if( FREGetObjectAsString( argv[0], &key ) != FRE_OK ) return NULL;
    
    SKProductsResponse* response = getReturnObject( key );
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
            if( FRENewObjectFromSKProduct( product, &asProduct ) == FRE_OK )
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
    if( FREGetObjectAsString( argv[0], &identifier ) != FRE_OK ) return NULL;
    
    int quantity = 0;
    if( FREGetObjectAsInt32( argv[1], &quantity ) != FRE_OK ) return NULL;
    
    if( quantity < 1 )
    {
        return NULL;
    }
    
    SKProduct* product = [products valueForKey:identifier];
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
    if( FREGetObjectAsString( argv[0], &identifier ) != FRE_OK ) return NULL;
    
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
            if( FRENewObjectFromSKTransaction( transaction, &asTransaction ) == FRE_OK )
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
    if( FREGetObjectAsString( argv[0], &key ) != FRE_OK ) return NULL;
    
    SKPaymentTransaction* transaction = getReturnObject( key );
    if( transaction == nil )
    {
        return NULL;
    }

    FREObject asTransaction;
    if( FRENewObjectFromSKTransaction( transaction, &asTransaction ) == FRE_OK )
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
        MAP_FUNCTION( initNativeCode, NULL ),
        MAP_FUNCTION( isSupported, NULL ),
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
    
    observer = [[StoreKitDelegate alloc] initWithContext:ctx andReturnObjects:returnObjects andProducts:products];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
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
    
    products = [[NSMutableDictionary alloc] init];
    returnObjects = [[NSMutableDictionary alloc] init];
}

void InAppPurchaseExtensionFinalizer()
{
    return;
}