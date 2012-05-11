package com.sticksports.nativeExtensions.inAppPurchase
{
	import com.sticksports.nativeExtensions.inAppPurchase.signals.IAPSignal0;
	import com.sticksports.nativeExtensions.inAppPurchase.signals.IAPSignal1;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;


	public class InAppPurchase
	{
		public static var productInformationReceived : IAPSignal1 = new IAPSignal1( Array );
		public static var productInformationFailed : IAPSignal0 = new IAPSignal0();
		
		public static var restoreTransactionsComplete : IAPSignal0 = new IAPSignal0();
		public static var restoreTransactionsFailed : IAPSignal1 = new IAPSignal1( String );
		
		public static var transactionPurchased : IAPSignal1 = new IAPSignal1( IAPTransaction );
		public static var transactionFailed : IAPSignal1 = new IAPSignal1( IAPTransaction );
		public static var transactionRestored : IAPSignal1 = new IAPSignal1( IAPTransaction );
		
		private static var extensionContext : ExtensionContext = null;
		private static var initialised : Boolean = false;

		/**
		 * Initialise the extension
		 */
		public static function init() : void
		{
			if ( !initialised )
			{
				initialised = true;
				extensionContext = ExtensionContext.createExtensionContext( "com.sticksports.nativeExtensions.InAppPurchase", null );
				extensionContext.addEventListener( StatusEvent.STATUS, handleStatusEvent );
			}
		}
		
		private static function handleStatusEvent( event : StatusEvent ) : void
		{
			switch( event.level )
			{
				case InternalMessages.fetchProductsFailed :
					productInformationFailed.dispatch();
					break;
				case InternalMessages.fetchProductsSuccess :
					var products : Array = getReturnedProducts( event.code );
					if( products )
					{
						productInformationReceived.dispatch( products );
					}
					else
					{
						productInformationFailed.dispatch();
					}
					break;
				case InternalMessages.restoreTransactionsComplete :
					restoreTransactionsComplete.dispatch();
					break;
				case InternalMessages.restoreTransactionsFailed :
					restoreTransactionsFailed.dispatch( event.code );
					break;
				case InternalMessages.transactionPurchased :
					var t1 : IAPTransaction = getReturnedTransaction( event.code );
					if( t1 )
					{
						transactionPurchased.dispatch( t1 );
					}
					break;
				case InternalMessages.transactionFailed :
					var t2 : IAPTransaction = getReturnedTransaction( event.code );
					if( t2 )
					{
						transactionFailed.dispatch( t2 );
					}
					break;
				case InternalMessages.transactionRestored :
					var t3 : IAPTransaction = getReturnedTransaction( event.code );
					if( t3 )
					{
						transactionRestored.dispatch( t3 );
					}
					break;
			}
		}
		
		/**
		 * Are in-app purchases supported. Returns false if the user has disabled in-app purchases.
		 */
		public static function get isSupported() : Boolean
		{
			return true;
		}
		
		public static function get canMakePayments() : Boolean
		{
			init();
			return extensionContext.call( NativeMethods.canMakePayments ) as Boolean;
		}
		
		public static function fetchProductInformation( ...productIds ) : void
		{
			var ids : Array = ( productIds.length == 1 && productIds[0] is Array ) ? productIds[0] : productIds;
			if( ids.length == 0 )
			{
				productInformationReceived.dispatch( [] );
			}
			else
			{
				extensionContext.call( NativeMethods.getProductInformation, ids );
			}
		}
		
		public static function purchaseProduct( productId : String, quantity : int = 1 ) : void
		{
			if( productId && quantity > 0 )
			{
				extensionContext.call( NativeMethods.purchaseProduct, productId, quantity );
			}
		}
		
		public static function finishTransaction( transactionId : String ) : Boolean
		{
			var success : Boolean = false;
			if( transactionId )
			{
				success = extensionContext.call( NativeMethods.finishTransaction, transactionId ) as Boolean;
			}
			return success;
		}
		
		public static function restorePurchases() : void
		{
			extensionContext.call( NativeMethods.restoreTransactions );
		}
		
		public static function getCurrentTransactions() : Array
		{
			return extensionContext.call( NativeMethods.getCurrentTransactions ) as Array;
		}
		
		private static function getReturnedProducts( key : String ) : Array
		{
			return extensionContext.call( NativeMethods.getStoredProductInformation, key ) as Array;
		}

		private static function getReturnedTransaction( key : String ) : IAPTransaction
		{
			return extensionContext.call( NativeMethods.getStoredTransaction, key ) as IAPTransaction;
		}
		
		/**
		 * Clean up the extension - only if you no longer need it or want to free memory. All listeners will be removed.
		 */
		public static function dispose() : void
		{
			if ( extensionContext )
			{
				extensionContext.dispose();
				extensionContext = null;
			}
			productInformationReceived.removeAll();
			productInformationFailed.removeAll();
			restoreTransactionsComplete.removeAll();
			restoreTransactionsFailed.removeAll();
			transactionPurchased.removeAll();
			transactionFailed.removeAll();
			transactionRestored.removeAll();
			initialised = false;
		}
	}
}
