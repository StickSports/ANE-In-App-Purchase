//
//  FRETypeConversion.h
//  GameCenterIosExtension
//
//  Created by Richard Lord on 25/01/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#ifndef GameCenterIosExtension_FRETypeConversion_h
#define GameCenterIosExtension_FRETypeConversion_h

#import "FlashRuntimeExtensions.h"

FREResult FREGetObjectAsString( FREObject object, NSString** value );
FREResult FREGetObjectAsArrayOfStrings( FREObject object, NSMutableArray** value );
FREResult FREGetObjectAsSetOfStrings( FREObject object, NSMutableSet** value );

FREResult FRENewObjectFromString( NSString* string, FREObject* asString );
FREResult FRENewObjectFromDate( NSDate* date, FREObject* asDate );
FREResult FRENewObjectFromError( NSError* error, FREObject* asError );
FREResult FRENewObjectFromData( NSData* data, FREObject* asData );

FREResult FRESetObjectPropertyString( FREObject asObject, const uint8_t* propertyName, NSString* value );
FREResult FRESetObjectPropertyBool( FREObject asObject, const uint8_t* propertyName, uint32_t value );
FREResult FRESetObjectPropertyInt( FREObject asObject, const uint8_t* propertyName, int32_t value );
FREResult FRESetObjectPropertyNum( FREObject asObject, const uint8_t* propertyName, double value );
FREResult FRESetObjectPropertyDate( FREObject asObject, const uint8_t* propertyName, NSDate* value );
FREResult FRESetObjectPropertyError( FREObject asObject, const uint8_t* propertyName, NSError* value );
FREResult FRESetObjectPropertyData( FREObject asObject, const uint8_t* propertyName, NSData* value );

#endif
