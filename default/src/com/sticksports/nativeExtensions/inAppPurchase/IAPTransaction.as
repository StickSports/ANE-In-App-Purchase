package com.sticksports.nativeExtensions.inAppPurchase
{
	import flash.utils.ByteArray;
	
	public class IAPTransaction
	{
		public var error : Error;
		public var productIdentifier : String;
		public var productQuantity : int;
		public var date : Date;
		public var transactionIdentifier : String;
		public var receipt : ByteArray;
		public var state : int;
		public var originalTransaction : IAPTransaction;
	}
}
