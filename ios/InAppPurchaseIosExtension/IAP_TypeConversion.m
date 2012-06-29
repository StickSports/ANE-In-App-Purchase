//
//  TypeConversion.m
//  InAppPurchaseIosExtension
//
//  Created by Richard Lord on 18/06/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import "IAP_TypeConversion.h"

#define ASProduct "com.sticksports.nativeExtensions.inAppPurchase.IAPProduct"
#define ASTransaction "com.sticksports.nativeExtensions.inAppPurchase.IAPTransaction"

@implementation IAP_TypeConversion

- (FREResult) FREGetObject:(FREObject)object asString:(NSString**)value;
{
    FREResult result;
    uint32_t length = 0;
    const uint8_t* tempValue = NULL;
    
    result = FREGetObjectAsUTF8( object, &length, &tempValue );
    if( result != FRE_OK ) return result;
    
    *value = [NSString stringWithUTF8String: (char*) tempValue];
    return FRE_OK;
}

- (FREResult) FREGetObject:(FREObject)object asSetOfStrings:(NSMutableSet**)value;
{
    FREResult result;
    uint32_t length;
    
    result = FREGetArrayLength( object, &length );
    if( result != FRE_OK ) return result;
    
    NSMutableSet * set = [NSMutableSet setWithCapacity:length];
    
    FREObject item;
    NSString* string;
    
    for( int i = 0; i < length; ++i )
    {
        result = FREGetArrayElementAt( object, i, &item );
        if( result != FRE_OK ) return result;
        
        result = [self FREGetObject:item asString:&string];
        if( result != FRE_OK ) return result;
        
        [set addObject:string];
    }
    
    *value = set;
    return FRE_OK;
}

- (FREResult) FREGetString:(NSString*)string asObject:(FREObject*)asString;
{
    if( string == nil )
    {
        return FRE_INVALID_ARGUMENT;
    }
    const char* utf8String = string.UTF8String;
    unsigned long length = strlen( utf8String );
    return FRENewObjectFromUTF8( length + 1, (uint8_t*) utf8String, asString );
}

- (FREResult) FREGetDate:(NSDate*)date asObject:(FREObject*)asDate;
{
    if( date == nil )
    {
        return FRE_INVALID_ARGUMENT;
    }
    NSTimeInterval timestamp = date.timeIntervalSince1970 * 1000;
    FREResult result;
    FREObject time;
    result = FRENewObjectFromDouble( timestamp, &time );
    if( result != FRE_OK ) return result;
    result = FRENewObject( "Date", 0, NULL, asDate, NULL );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( *asDate, "time", time, NULL);
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

- (FREResult) FREGetError:(NSError*)error asObject:(FREObject*)asError;
{
    if( error == nil )
    {
        return FRE_INVALID_ARGUMENT;
    }
    FREResult result;
    
    FREObject code;
    result = FRENewObjectFromInt32( error.code, &code );
    if( result != FRE_OK ) return result;
    FREObject message;
    result = [self FREGetString:error.localizedDescription asObject:&message];
    if( result != FRE_OK ) return result;
    
    FREObject params;
    result = FRENewObject( "Array", 0, NULL, &params, NULL );
    if( result != FRE_OK ) return result;
    result = FRESetArrayLength( params, 2 );
    if( result != FRE_OK ) return result;
    FRESetArrayElementAt( params, 0, message );
    FRESetArrayElementAt( params, 1, code );
    
    result = FRENewObject( "Error", 0, NULL, asError, NULL );
    if( result != FRE_OK ) return result;
    
    return FRE_OK;
}

- (FREResult) FREGetData:(NSData*)data asObject:(FREObject*)asData;
{
    if( data == nil )
    {
        return FRE_INVALID_ARGUMENT;
    }
    FREResult result;
    result = FRENewObject( "flash.utils.ByteArray", 0, NULL, asData, NULL );
    if( result != FRE_OK ) return result;
    result = [self FRESetObject:*asData property:"length" toInt:data.length];
    if( result != FRE_OK ) return result;
    
    FREByteArray actualBytes;
    result = FREAcquireByteArray( *asData, &actualBytes );
    if( result != FRE_OK ) return result;
    memcpy( actualBytes.bytes, data.bytes, data.length );
    result = FREReleaseByteArray( *asData );
    if( result != FRE_OK ) return result;
    
    return FRE_OK;
}

- (FREResult) FRESetObject:(FREObject)asObject property:(const uint8_t*)propertyName toString:(NSString*)value;
{
    if( value == nil )
    {
        return FRE_INVALID_ARGUMENT;
    }
    FREResult result;
    FREObject asValue;
    result = [self FREGetString:value asObject:&asValue];
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

- (FREResult) FRESetObject:(FREObject)asObject property:(const uint8_t*)propertyName toInt:(int32_t)value;
{
    FREResult result;
    FREObject asValue;
    result = FRENewObjectFromInt32( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

- (FREResult) FRESetObject:(FREObject)asObject property:(const uint8_t*)propertyName toDouble:(double)value;
{
    FREResult result;
    FREObject asValue;
    result = FRENewObjectFromDouble( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

- (FREResult) FRESetObject:(FREObject)asObject property:(const uint8_t*)propertyName toDate:(NSDate*)value;
{
    if( value == nil )
    {
        return FRE_INVALID_ARGUMENT;
    }
    FREResult result;
    FREObject asValue;
    result = [self FREGetDate:value asObject:&asValue];
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

- (FREResult) FRESetObject:(FREObject)asObject property:(const uint8_t*)propertyName toError:(NSError*)value;
{
    if( value == nil )
    {
        return FRE_INVALID_ARGUMENT;
    }
    FREResult result;
    FREObject asValue;
    result = [self FREGetError:value asObject:&asValue];
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

- (FREResult) FRESetObject:(FREObject)asObject property:(const uint8_t*)propertyName toData:(NSData*)value;
{
    if( value == nil )
    {
        return FRE_INVALID_ARGUMENT;
    }
    FREResult result;
    FREObject asValue;
    result = [self FREGetData:value asObject:&asValue];
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

- (FREResult) FREGetSKProduct:(SKProduct*)product asObject:(FREObject*)asProduct;
{
    if( product == nil )
    {
        return FRE_INVALID_ARGUMENT;
    }
    FREResult result;
    
    result = FRENewObject( ASProduct, 0, NULL, asProduct, NULL);
    if( result != FRE_OK ) return result;
    
    if( product.productIdentifier )
    {
        result = [self FRESetObject:*asProduct property:"id" toString:product.productIdentifier];
        if( result != FRE_OK ) return result;
    }
    
    if( product.localizedTitle )
    {
        result = [self FRESetObject:*asProduct property:"title" toString:product.localizedTitle];
        if( result != FRE_OK ) return result;
    }
    
    if( product.localizedDescription )
    {
        result = [self FRESetObject:*asProduct property:"desc" toString:product.localizedDescription];
        if( result != FRE_OK ) return result;
    }
    
    if( product.price )
    {
        result = [self FRESetObject:*asProduct property:"price" toDouble:product.price.doubleValue];
        if( result != FRE_OK ) return result;
    
        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    
        result = [self FRESetObject:*asProduct property:"formattedPrice" toString:formattedPrice];
        if( result != FRE_OK ) return result;
    }
    
    if( product.priceLocale )
    {
        result = [self FRESetObject:*asProduct property:"priceLocale" toString:[product.priceLocale localeIdentifier]];
        if( result != FRE_OK ) return result;
    }
    
    return FRE_OK;
}

- (FREResult) FREGetSKTransaction:(SKPaymentTransaction*)transaction asObject:(FREObject*)asTransaction;
{
    if( transaction == nil )
    {
        return FRE_INVALID_ARGUMENT;
    }
    FREResult result;
    
    result = FRENewObject( ASTransaction, 0, NULL, asTransaction, NULL);
    if( result != FRE_OK ) return result;
    
    if( transaction.payment && transaction.payment.productIdentifier )
    {
        result = [self FRESetObject:*asTransaction property:"productId" toString:transaction.payment.productIdentifier];
        if( result != FRE_OK ) return result;
    }
    
    if( transaction.payment )
    {
        result = [self FRESetObject:*asTransaction property:"productQuantity" toInt:transaction.payment.quantity];
        if( result != FRE_OK ) return result;
    }
    
    if( transaction.transactionIdentifier )
    {
        result = [self FRESetObject:*asTransaction property:"id" toString:transaction.transactionIdentifier];
        if( result != FRE_OK ) return result;
    }
    
    if( transaction.transactionDate )
    {
        result = [self FRESetObject:*asTransaction property:"date" toDate:transaction.transactionDate];
        if( result != FRE_OK ) return result;
    }
    
    result = [self FRESetObject:*asTransaction property:"state" toInt:transaction.transactionState];
    if( result != FRE_OK ) return result;
    
    if( transaction.transactionState == SKPaymentTransactionStateFailed && transaction.error )
    {
        result = [self FRESetObject:*asTransaction property:"error" toError:transaction.error];
        if( result != FRE_OK ) return result;
    }
    
    if( transaction.transactionState == SKPaymentTransactionStatePurchased && transaction.transactionReceipt )
    {
        result = [self FRESetObject:*asTransaction property:"receipt" toData:transaction.transactionReceipt];
        if( result != FRE_OK ) return result;
    }
    
    if( transaction.transactionState == SKPaymentTransactionStateRestored && transaction.originalTransaction )
    {
        FREObject original;
        result = [self FREGetSKTransaction:transaction.originalTransaction asObject:&original];
        if( result != FRE_OK ) return result;
        result = FRESetObjectProperty( *asTransaction, "originalTransaction", original, NULL );
        if( result != FRE_OK ) return result;
    }
    
    return FRE_OK;
}


@end
