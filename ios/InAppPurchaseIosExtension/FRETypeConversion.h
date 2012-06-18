//
//  FRETypeConversion.h
//  GameCenterIosExtension
//
//  Created by Richard Lord on 25/01/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#ifndef InAppPurchaseIosExtension_FRETypeConversion_h
#define InAppPurchaseIosExtension_FRETypeConversion_h

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FlashRuntimeExtensions.h"

FREResult IAP_FREGetObjectAsString( FREObject object, NSString** value );
FREResult IAP_FREGetObjectAsSetOfStrings( FREObject object, NSMutableSet** value );

FREResult IAP_FRENewObjectFromString( NSString* string, FREObject* asString );
FREResult IAP_FRENewObjectFromDate( NSDate* date, FREObject* asDate );
FREResult IAP_FRENewObjectFromError( NSError* error, FREObject* asError );
FREResult IAP_FRENewObjectFromData( NSData* data, FREObject* asData );

FREResult IAP_FRESetObjectPropertyString( FREObject asObject, const uint8_t* propertyName, NSString* value );
FREResult IAP_FRESetObjectPropertyInt( FREObject asObject, const uint8_t* propertyName, int32_t value );
FREResult IAP_FRESetObjectPropertyNum( FREObject asObject, const uint8_t* propertyName, double value );
FREResult IAP_FRESetObjectPropertyDate( FREObject asObject, const uint8_t* propertyName, NSDate* value );
FREResult IAP_FRESetObjectPropertyError( FREObject asObject, const uint8_t* propertyName, NSError* value );
FREResult IAP_FRESetObjectPropertyData( FREObject asObject, const uint8_t* propertyName, NSData* value );

FREResult IAP_FRENewObjectFromSKProduct( SKProduct* product, FREObject* asProduct );
FREResult IAP_FRENewObjectFromSKTransaction( SKPaymentTransaction* transaction, FREObject* asTransaction );

#endif
