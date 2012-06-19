//
//  InAppPurchaseIosExtension.m
//  InAppPurchaseIosExtension
//
//  Created by Richard Lord on 01/05/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#import <StoreKit/StoreKit.h>
#import "InAppPurchaseHandler.h"
#import "IAP_NativeMessages.h"

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }

InAppPurchaseHandler* IAP_handler;

DEFINE_ANE_FUNCTION( IAP_canMakePayments )
{
    uint32_t retValue = ([SKPaymentQueue canMakePayments]) ? 1 : 0;
    
    FREObject result;
    if ( FRENewObjectFromBool(retValue, &result ) == FRE_OK )
    {
        return result;
    }
    return NULL;
}

DEFINE_ANE_FUNCTION( IAP_getProductInformation )
{
    return [IAP_handler getProductInformationForIds:argv[0]];
}

DEFINE_ANE_FUNCTION( IAP_getStoredProductInformation )
{
    return [IAP_handler getStoredProductInformation:argv[0]];
}

DEFINE_ANE_FUNCTION( IAP_purchaseProduct )
{
    return [IAP_handler purchaseProduct:argv[0] quantity:argv[1]];
}

DEFINE_ANE_FUNCTION( IAP_finishTransaction )
{
    return [IAP_handler finishTransaction:argv[0]];
}

DEFINE_ANE_FUNCTION( IAP_restoreTransactions )
{
    return [IAP_handler restoreTransactions];
}

DEFINE_ANE_FUNCTION( IAP_getCurrentTransactions )
{
    return [IAP_handler getCurrentTransactions];
}

DEFINE_ANE_FUNCTION( IAP_getStoredTransaction )
{
    return [IAP_handler getStoredTransaction:argv[0]];
}

void InAppPurchaseContextInitializer( void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet )
{
    static FRENamedFunction functionMap[] = {
        MAP_FUNCTION( IAP_canMakePayments, NULL ),
        MAP_FUNCTION( IAP_getProductInformation, NULL ),
        MAP_FUNCTION( IAP_getStoredProductInformation, NULL ),
        MAP_FUNCTION( IAP_purchaseProduct, NULL ),
        MAP_FUNCTION( IAP_finishTransaction, NULL ),
        MAP_FUNCTION( IAP_restoreTransactions, NULL ),
        MAP_FUNCTION( IAP_getCurrentTransactions, NULL ),
        MAP_FUNCTION( IAP_getStoredTransaction, NULL )
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