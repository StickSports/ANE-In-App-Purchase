package com.sticksports.nativeExtensions.inAppPurchase
{
	import flash.utils.ByteArray;
	
	public class IAPTransaction
	{
		public var id : String;
		public var productId : String;
		public var productQuantity : int;
		public var date : Date;
		public var state : int;
		public var error : Error;
		public var receipt : ByteArray;
		public var originalTransaction : IAPTransaction;
	}
}
