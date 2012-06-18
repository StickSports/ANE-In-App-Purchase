//
//  TypeConversion.h
//  InAppPurchaseIosExtension
//
//  Created by Richard Lord on 18/06/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FlashRuntimeExtensions.h"

@interface TypeConversion : NSObject
{
}

- (FREResult) FREGetObject:(FREObject)object asString:(NSString**)value;
- (FREResult) FREGetObject:(FREObject)object asSetOfStrings:(NSMutableSet**)value;

- (FREResult) FREGetString:(NSString*)string asObject:(FREObject*)asString;
- (FREResult) FREGetDate:(NSDate*)date asObject:(FREObject*)asDate;
- (FREResult) FREGetError:(NSError*)error asObject:(FREObject*)asError;
- (FREResult) FREGetData:(NSData*)data asObject:(FREObject*)asData;

- (FREResult) FRESetObject:(FREObject)asObject property:(const uint8_t*)propertyName toString:(NSString*)value;
- (FREResult) FRESetObject:(FREObject)asObject property:(const uint8_t*)propertyName toInt:(int32_t)value;
- (FREResult) FRESetObject:(FREObject)asObject property:(const uint8_t*)propertyName toDouble:(double)value;
- (FREResult) FRESetObject:(FREObject)asObject property:(const uint8_t*)propertyName toDate:(NSDate*)value;
- (FREResult) FRESetObject:(FREObject)asObject property:(const uint8_t*)propertyName toError:(NSError*)value;
- (FREResult) FRESetObject:(FREObject)asObject property:(const uint8_t*)propertyName toData:(NSData*)value;

- (FREResult) FREGetSKProduct:(SKProduct*)product asObject:(FREObject*)asProduct;
- (FREResult) FREGetSKTransaction:(SKPaymentTransaction*)transaction asObject:(FREObject*)asTransaction;

@end
