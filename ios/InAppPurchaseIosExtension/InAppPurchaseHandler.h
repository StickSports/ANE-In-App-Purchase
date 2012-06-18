//
//  InAppPurchaseHandler.h
//  InAppPurchaseIosExtension
//
//  Created by Richard Lord on 18/06/2012.
//  Copyright (c) 2012 Stick Sports Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"

@interface InAppPurchaseHandler : NSObject
{
}

- (NSString*) storeReturnObject:(id)object;
- (id) getReturnObject:(NSString*) key;
- (FREObject) canMakePayments;
- (FREObject) getProductInformationForIds:(FREObject)asId;
- (FREObject) getStoredProductInformation:(FREObject)asKey;
- (FREObject) purchaseProduct:(FREObject)asId quantity:(FREObject)asQuantity;
- (FREObject) finishTransaction:(FREObject)asId;
- (FREObject) restoreTransactions;
- (FREObject) getCurrentTransactions;
- (FREObject) getStoredTransaction:(FREObject)asKey;

@end
