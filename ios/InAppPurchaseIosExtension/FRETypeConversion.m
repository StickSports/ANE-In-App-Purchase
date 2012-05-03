//
//  FRETypeConversion.c
//  GameCenterIosExtension
//
//  Created by Richard Lord on 25/01/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//

#import "FRETypeConversion.h"

FREResult FREGetObjectAsString( FREObject object, NSString** value )
{
    FREResult result;
    uint32_t length = 0;
    const uint8_t* tempValue = NULL;
    
    result = FREGetObjectAsUTF8( object, &length, &tempValue );
    if( result != FRE_OK ) return result;
    
    *value = [NSString stringWithUTF8String: (char*) tempValue];
    return FRE_OK;
}

FREResult FREGetObjectAsArrayOfStrings( FREObject object, NSMutableArray** value )
{
    FREResult result;
    uint32_t length;
    
    result = FREGetArrayLength( object, &length );
    if( result != FRE_OK ) return result;
    
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:length];
    
    FREObject item;
    NSString* string;
    
    for( int i = 0; i < length; ++i )
    {
        result = FREGetArrayElementAt( object, i, &item );
        if( result != FRE_OK ) return result;
        
        result = FREGetObjectAsString( item, &string );
        if( result != FRE_OK ) return result;
        
        [array addObject:string];
    }
    
    *value = array;
    return FRE_OK;
}

FREResult FREGetObjectAsSetOfStrings( FREObject object, NSMutableSet** value )
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
        
        result = FREGetObjectAsString( item, &string );
        if( result != FRE_OK ) return result;
        
        [set addObject:string];
    }
    
    *value = set;
    return FRE_OK;
}

FREResult FRENewObjectFromString( NSString* string, FREObject* asString )
{
    const char* utf8String = string.UTF8String;
    unsigned long length = strlen( utf8String );
    return FRENewObjectFromUTF8( length + 1, (uint8_t*) utf8String, asString );
}

FREResult FRENewObjectFromError( NSError* error, FREObject* asError )
{
    FREResult result;
    
    FREObject code;
    result = FRENewObjectFromInt32( error.code, &code );
    if( result != FRE_OK ) return result;
    FREObject message;
    result = FRENewObjectFromString( error.localizedDescription, &message );
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

FREResult FRENewObjectFromDate( NSDate* date, FREObject* asDate )
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

FREResult FRENewObjectFromData( NSData* data, FREObject* asData )
{
    FREResult result;
    result = FRENewObject( "flash.utils.ByteArray", 0, NULL, asData, NULL );
    if( result != FRE_OK ) return result;
    result = FRESetObjectPropertyInt( *asData, "length", data.length );
    if( result != FRE_OK ) return result;
    
    FREByteArray actualBytes;
    result = FREAcquireByteArray( *asData, &actualBytes );
    if( result != FRE_OK ) return result;
    memcpy( actualBytes.bytes, data.bytes, data.length );
    result = FREReleaseByteArray( *asData );
    if( result != FRE_OK ) return result;
    
    return FRE_OK;
}

FREResult FRESetObjectPropertyString( FREObject asObject, const uint8_t* propertyName, NSString* value )
{
    FREResult result;
    FREObject asValue;
    result = FRENewObjectFromString( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

FREResult FRESetObjectPropertyBool( FREObject asObject, const uint8_t* propertyName, uint32_t value )
{
    FREResult result;
    FREObject asValue;
    result = FRENewObjectFromBool( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

FREResult FRESetObjectPropertyInt( FREObject asObject, const uint8_t* propertyName, int32_t value )
{
    FREResult result;
    FREObject asValue;
    result = FRENewObjectFromInt32( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

FREResult FRESetObjectPropertyNum( FREObject asObject, const uint8_t* propertyName, double value )
{
    FREResult result;
    FREObject asValue;
    result = FRENewObjectFromDouble( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

FREResult FRESetObjectPropertyDate( FREObject asObject, const uint8_t* propertyName, NSDate* value )
{
    FREResult result;
    FREObject asValue;
    result = FRENewObjectFromDate( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

FREResult FRESetObjectPropertyError( FREObject asObject, const uint8_t* propertyName, NSError* value )
{
    FREResult result;
    FREObject asValue;
    result = FRENewObjectFromError( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

FREResult FRESetObjectPropertyData( FREObject asObject, const uint8_t* propertyName, NSData* value )
{
    FREResult result;
    FREObject asValue;
    result = FRENewObjectFromData( value, &asValue );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( asObject, propertyName, asValue, NULL );
    if( result != FRE_OK ) return result;
    return FRE_OK;
}