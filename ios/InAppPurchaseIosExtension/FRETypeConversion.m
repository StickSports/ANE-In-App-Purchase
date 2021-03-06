//
//  FRETypeConversion.c
//  GameCenterIosExtension
//
//  Created by Richard Lord on 25/01/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import "FRETypeConversion.h"
#import "NativeMessages.h"

FREResult IAP_FREGetObjectAsString( FREObject object, NSString** value )
{
    FREResult result;
    uint32_t length = 0;
    const uint8_t* tempValue = NULL;
    
    result = FREGetObjectAsUTF8( object, &length, &tempValue );
    if( result != FRE_OK ) return result;
    
    *value = [NSString stringWithUTF8String: (char*) tempValue];
    return FRE_OK;
}

FREResult IAP_FREGetObjectAsSetOfStrings( FREObject object, NSMutableSet** value )
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
        
        result = IAP_FREGetObjectAsString( item, &string );
        if( result != FRE_OK ) return result;
        
        [set addObject:string];
    }
    
    *value = set;
    return FRE_OK;
}

FREResult IAP_FRENewObjectFromString( NSString* string, FREObject* asString )
{
    const char* utf8String = string.UTF8String;
    unsigned long length = strlen( utf8String );
    return FRENewObjectFromUTF8( length + 1, (uint8_t*) utf8String, asString );
}

FREResult IAP_FRENewObjectFromError( NSError* error, FREObject* asError )
{
    FREResult result;
    
    FREObject code;
    result = FRENewObjectFromInt32( error.code, &code );
    if( result != FRE_OK ) return result;
    FREObject message;
    result = IAP_FRENewObjectFromString( error.localizedDescription, &message );
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

FREResult IAP_FRENewObjectFromDate( NSDate* date, FREObject* asDate )
{
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

FREResult IAP_FRENewObjectFromData( NSData* data, FREObject* asData )
{
    FREResult result;
    result = FRENewObject( "flash.utils.ByteArray", 0, NULL, asData, NULL );
    if( result != FRE_OK ) return result;
    result = IAP_FRESetObjectPropertyInt( *asData, "length", data.length );
    if( result != FRE_OK ) return result;
    
    FREByteArray actualBytes;
    result = FREAcquireByteArray( *asData, &actualBytes );
    if( result != FRE_OK ) return result;
    memcpy( actualBytes.bytes, data.bytes, data.length );
    result = FREReleaseByteArray( *asData );
    if( result != FRE_OK ) return result;
    
    return FRE_OK;
}

FREResult IAP_FRESetObjectPropertyString( FREObject asObject, const uint8_t* propertyName, NSString* value )
{
    FREResult result;
    FREObject asValue;
    result = IAP_FRENewObjectFromString( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

FREResult IAP_FRESetObjectPropertyInt( FREObject asObject, const uint8_t* propertyName, int32_t value )
{
    FREResult result;
    FREObject asValue;
    result = FRENewObjectFromInt32( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

FREResult IAP_FRESetObjectPropertyNum( FREObject asObject, const uint8_t* propertyName, double value )
{
    FREResult result;
    FREObject asValue;
    result = FRENewObjectFromDouble( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

FREResult IAP_FRESetObjectPropertyDate( FREObject asObject, const uint8_t* propertyName, NSDate* value )
{
    FREResult result;
    FREObject asValue;
    result = IAP_FRENewObjectFromDate( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

FREResult IAP_FRESetObjectPropertyError( FREObject asObject, const uint8_t* propertyName, NSError* value )
{
    FREResult result;
    FREObject asValue;
    result = IAP_FRENewObjectFromError( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

FREResult IAP_FRESetObjectPropertyData( FREObject asObject, const uint8_t* propertyName, NSData* value )
{
    FREResult result;
    FREObject asValue;
    result = IAP_FRENewObjectFromData( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

FREResult IAP_FRENewObjectFromSKProduct( SKProduct* product, FREObject* asProduct )
{
    FREResult result;
    
    result = FRENewObject( ASProduct, 0, NULL, asProduct, NULL);
    if( result != FRE_OK ) return result;
    
    result = IAP_FRESetObjectPropertyString( *asProduct, "id", product.productIdentifier );
    if( result != FRE_OK ) return result;
    
    result = IAP_FRESetObjectPropertyString( *asProduct, "title", product.localizedTitle );
    if( result != FRE_OK ) return result;
    
    result = IAP_FRESetObjectPropertyString( *asProduct, "desc", product.localizedDescription );
    if( result != FRE_OK ) return result;
    
    result = IAP_FRESetObjectPropertyNum( *asProduct, "price", product.price.doubleValue );
    if( result != FRE_OK ) return result;
    
    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    
    result = IAP_FRESetObjectPropertyString( *asProduct, "formattedPrice", formattedPrice );
    if( result != FRE_OK ) return result;
    
    result = IAP_FRESetObjectPropertyString( *asProduct, "priceLocale", [product.priceLocale localeIdentifier] );
    if( result != FRE_OK ) return result;
    
    return FRE_OK;
}

FREResult IAP_FRENewObjectFromSKTransaction( SKPaymentTransaction* transaction, FREObject* asTransaction )
{
    FREResult result;
    
    result = FRENewObject( ASTransaction, 0, NULL, asTransaction, NULL);
    if( result != FRE_OK ) return result;
    
    result = IAP_FRESetObjectPropertyString( *asTransaction, "productId", transaction.payment.productIdentifier );
    if( result != FRE_OK ) return result;
    
    result = IAP_FRESetObjectPropertyInt( *asTransaction, "productQuantity", transaction.payment.quantity );
    if( result != FRE_OK ) return result;
    
    result = IAP_FRESetObjectPropertyString( *asTransaction, "id", transaction.transactionIdentifier );
    if( result != FRE_OK ) return result;
    
    result = IAP_FRESetObjectPropertyDate( *asTransaction, "date", transaction.transactionDate );
    if( result != FRE_OK ) return result;
    
    result = IAP_FRESetObjectPropertyInt( *asTransaction, "state", transaction.transactionState );
    if( result != FRE_OK ) return result;
    
    if( transaction.transactionState == SKPaymentTransactionStateFailed )
    {
        result = IAP_FRESetObjectPropertyError( *asTransaction, "error", transaction.error );
        if( result != FRE_OK ) return result;
    }
    
    if( transaction.transactionState == SKPaymentTransactionStatePurchased )
    {
        result = IAP_FRESetObjectPropertyData( *asTransaction, "receipt", transaction.transactionReceipt );
        if( result != FRE_OK ) return result;
    }
    
    if( transaction.transactionState == SKPaymentTransactionStateRestored )
    {
        FREObject original;
        result = IAP_FRENewObjectFromSKTransaction( transaction.originalTransaction, &original );
        if( result != FRE_OK ) return result;
        result = FRESetObjectProperty( *asTransaction, "originalTransaction", original, NULL );
        if( result != FRE_OK ) return result;
    }
    
    return FRE_OK;
}

