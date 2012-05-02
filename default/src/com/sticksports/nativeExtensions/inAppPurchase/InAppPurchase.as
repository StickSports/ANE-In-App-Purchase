package com.sticksports.nativeExtensions.inAppPurchase
{
	import net.richardlord.signals.Signal0;
	import net.richardlord.signals.Signal1;

	public class InAppPurchase
	{
		public static var productInformationReceived : Signal1 = new Signal1( Array );
		public static var productInformationFailed : Signal0 = new Signal0();
		
		public static var restoreTransactionsComplete : Signal0 = new Signal0();
		public static var restoreTransactionsFailed : Signal1 = new Signal1( String );
		
		public static var transactionPurchased : Signal1 = new Signal1( IAPTransaction );
		public static var transactionFailed : Signal1 = new Signal1( IAPTransaction );
		public static var transactionRestored : Signal1 = new Signal1( IAPTransaction );
		
		/**
		 * Initialise the extension
		 */
		public static function init() : void
		{
		}
		
		/**
		 * Are in-app purchases supported. Returns false if the user has disabled in-app purchases.
		 */
		public static function get isSupported() : Boolean
		{
			return false;
		}
		
		private static function throwNotSupportedError() : void
		{
			throw new Error( "In-App Purchase is not supported on this device." );
		}

		public static function fetchProductInformation( ...productIds ) : void
		{
			throwNotSupportedError();
		}
		
		public static function purchaseProduct( productId : String, quantity : int = 1 ) : void
		{
			throwNotSupportedError();
		}
		
		public static function finishTransaction( transactionId : String ) : Boolean
		{
			throwNotSupportedError();
			return false;
		}
		
		public static function restoreTransactions() : void
		{
			throwNotSupportedError();
		}
		
		public static function getCurrentTransactions() : Array
		{
			throwNotSupportedError();
			return null;
		}
		
		/**
		 * Clean up the extension - only if you no longer need it or want to free memory. All listeners will be removed.
		 */
		public static function dispose() : void
		{
			productInformationReceived.removeAll();
			productInformationFailed.removeAll();
			restoreTransactionsComplete.removeAll();
			restoreTransactionsFailed.removeAll();
			transactionPurchased.removeAll();
			transactionFailed.removeAll();
			transactionRestored.removeAll();
		}
	}
}
