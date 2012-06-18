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
#import "InAppPurchaseHandler.h"
#import "NativeMessages.h"

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }

InAppPurchaseHandler* IAP_handler;

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
    return [IAP_handler getProductInformationForIds:argv[0]];
}

DEFINE_ANE_FUNCTION( getStoredProductInformation )
{
    return [IAP_handler getStoredProductInformation:argv[0]];
}

DEFINE_ANE_FUNCTION( purchaseProduct )
{
    return [IAP_handler purchaseProduct:argv[0] quantity:argv[1]];
}

DEFINE_ANE_FUNCTION( finishTransaction )
{
    return [IAP_handler finishTransaction:argv[0]];
}

DEFINE_ANE_FUNCTION( restoreTransactions )
{
    return [IAP_handler restoreTransactions];
}

DEFINE_ANE_FUNCTION( getCurrentTransactions )
{
    return [IAP_handler getCurrentTransactions];
}

DEFINE_ANE_FUNCTION( getStoredTransaction )
{
    return [IAP_handler getStoredTransaction:argv[0]];
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
    
    IAP_handler = [[InAppPurchaseHandler alloc] initWithContext:ctx];
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
}

void InAppPurchaseExtensionFinalizer()
{
    return;
}