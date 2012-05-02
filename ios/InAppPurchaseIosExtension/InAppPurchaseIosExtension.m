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

#define DISPATCH_STATUS_EVENT(extensionContext, code, status) FREDispatchStatusEventAsync((extensionContext), (uint8_t*)code, (uint8_t*)status)

#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }

NSMutableDictionary* returnObjects;
StoreKitDelegate* observer;

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
    
    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    
    result = FRESetObjectPropertyString( *asProduct, "price", formattedString );
    if( result != FRE_OK ) return result;
    
    result = FRESetObjectPropertyString( *asProduct, "priceLocale", [product.priceLocale localeIdentifier] );
    if( result != FRE_OK ) return result;
    
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
    if( response.products == nil )
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
    return NULL;
}

DEFINE_ANE_FUNCTION( purchaseProduct )
{
    NSString* identifier;
    if( FREGetObjectAsString( argv[0], &identifier ) != FRE_OK ) return NULL;
    
    int quantity = 0;
    if( FREGetObjectAsInt32( argv[1], &quantity ) != FRE_OK ) return NULL;
    
    
    
    return NULL;
}

void InAppPurchaseContextInitializer( void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet )
{
    static FRENamedFunction functionMap[] = {
        MAP_FUNCTION( initNativeCode, NULL ),
        MAP_FUNCTION( isSupported, NULL ),
        MAP_FUNCTION( getProductInformation, NULL ),
        MAP_FUNCTION( getStoredProductInformation, NULL )
    };
    
	*numFunctionsToSet = sizeof( functionMap ) / sizeof( FRENamedFunction );
	*functionsToSet = functionMap;
    
    observer = [[StoreKitDelegate alloc] init];
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
    returnObjects = [[NSMutableDictionary alloc] init];
}

void InAppPurchaseExtensionFinalizer()
{
    return;
}