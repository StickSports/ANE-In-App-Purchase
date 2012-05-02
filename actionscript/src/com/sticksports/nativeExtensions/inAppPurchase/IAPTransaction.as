package com.sticksports.nativeExtensions.inAppPurchase
{
	public class IAPTransaction
	{
		public var error : String;
		public var productIdentifier : String;
		public var productQuantity : int;
		public var date : Date;
		public var transactionIdentifier : String;
		public var receipt : String;
		public var state : int;
		public var originalTransaction : IAPTransaction;
	}
}
