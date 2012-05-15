package
{
	import com.sticksports.nativeExtensions.inAppPurchase.IAPProduct;
	import com.sticksports.nativeExtensions.inAppPurchase.IAPTransaction;
	import com.sticksports.nativeExtensions.inAppPurchase.InAppPurchase;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	[SWF(width='320', height='480', frameRate='30', backgroundColor='#000000')]
	
	public class InAppPurchaseExtensionTest extends Sprite
	{
		private var direction : int = 1;
		private var shape : Shape;
		private var feedback : TextField;
		
		private var buttonFormat : TextFormat;
		
		private var completePurchases : Dictionary = new Dictionary();
		private var failedPurchases : Dictionary = new Dictionary();
		private var restoredPurchases : Dictionary = new Dictionary();
		
		public function InAppPurchaseExtensionTest()
		{
			shape = new Shape();
			shape.graphics.beginFill( 0x666666 );
			shape.graphics.drawCircle( 0, 0, 100 );
			shape.graphics.endFill();
			shape.x = 0;
			shape.y = 240;
			addChild( shape );
			
			feedback = new TextField();
			var format : TextFormat = new TextFormat();
			format.font = "_sans";
			format.size = 16;
			format.color = 0xFFFFFF;
			feedback.defaultTextFormat = format;
			feedback.width = 320;
			feedback.height = 260;
			feedback.x = 10;
			feedback.y = 210;
			feedback.multiline = true;
			feedback.wordWrap = true;
			feedback.text = "Hello";
			addChild( feedback );
			
			createButtons();
			
			addEventListener( Event.ENTER_FRAME, animate );
			addEventListener( Event.ENTER_FRAME, init );
		}
		
		private function init( event : Event ) : void
		{
			removeEventListener( Event.ENTER_FRAME, init );
			InAppPurchase.transactionPurchased.add( purchaseComplete );
			InAppPurchase.transactionFailed.add( purchaseFailed );
			InAppPurchase.transactionRestored.add( purchaseRestored );
			InAppPurchase.init();
		}
		
		private function purchaseComplete( transaction : IAPTransaction ) : void
		{
			completePurchases[ transaction.id ] = transaction;
			feedback.appendText( "\n> transactionComplete" );
			outputTransactionDetails( transaction );
		}
		
		private function purchaseFailed( transaction : IAPTransaction ) : void
		{
			if( transaction )
			{
				failedPurchases[ transaction.id ] = transaction;
				feedback.appendText( "\n> transactionFailed" );
				outputTransactionDetails( transaction );
			}
			else
			{
				feedback.appendText( "\n> transactionFailed. No transaction object returned." );
			}
		}
		
		private function purchaseRestored( transaction : IAPTransaction ) : void
		{
			restoredPurchases[ transaction.id ] = transaction;
			feedback.appendText( "\n> transactionRestored" );
			outputTransactionDetails( transaction );
		}
		
		private function createButtons() : void
		{
			var tf : TextField = createButton( "canMakePayments" );
			tf.x = 10;
			tf.y = 10;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, checkPayments );
			addChild( tf );
			
			tf = createButton( "getProducts" );
			tf.x = 170;
			tf.y = 10;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, getProducts );
			addChild( tf );
			
			tf = createButton( "getCurrentTransactions" );
			tf.x = 10;
			tf.y = 50;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, getCurrentTransactions );
			addChild( tf );

			tf = createButton( "consumable" );
			tf.x = 170;
			tf.y = 50;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, validConsumable );
			addChild( tf );

			tf = createButton( "non-consumable" );
			tf.x = 10;
			tf.y = 90;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, validNonconsumable );
			addChild( tf );
			
			tf = createButton( "finishCompletePurchases" );
			tf.x = 170;
			tf.y = 90;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, finishCompletePurchases );
			addChild( tf );
			
			tf = createButton( "invalid purchase" );
			tf.x = 10;
			tf.y = 130;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, invalidPurchase );
			addChild( tf );
			
			tf = createButton( "finishFailedPurchases" );
			tf.x = 170;
			tf.y = 130;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, finishFailedPurchases );
			addChild( tf );
			
			tf = createButton( "restorePurchases" );
			tf.x = 10;
			tf.y = 170;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, restorePurchases );
			addChild( tf );
			
			tf = createButton( "finishRestoredPurchases" );
			tf.x = 170;
			tf.y = 170;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, finishRestoredPurchases );
			addChild( tf );
		}
		
		private function createButton( label : String ) : TextField
		{
			if( !buttonFormat )
			{
				buttonFormat = new TextFormat();
				buttonFormat.font = "_sans";
				buttonFormat.size = 14;
				buttonFormat.bold = true;
				buttonFormat.color = 0xFFFFFF;
				buttonFormat.align = TextFormatAlign.CENTER;
			}
			
			var textField : TextField = new TextField();
			textField.defaultTextFormat = buttonFormat;
			textField.width = 140;
			textField.height = 30;
			textField.text = label;
			textField.backgroundColor = 0xCC0000;
			textField.background = true;
			textField.selectable = false;
			textField.multiline = false;
			textField.wordWrap = false;
			return textField;
		}
		
		private function checkPayments( event : MouseEvent ) : void
		{
			feedback.text = "InAppPurchase.canMakePayments:\n  " + InAppPurchase.canMakePayments;
		}
		
		private function getProducts( event : MouseEvent ) : void
		{
			feedback.text = "InAppPurchase.fetchProductInformation( 'consumable1', 'nonconsumable1' ):";
			InAppPurchase.productInformationReceived.add( productInformationReceived );
			InAppPurchase.productInformationFailed.add( productInformationFailed );
			InAppPurchase.fetchProductInformation( "consumable1", "nonconsumable1" );
		}

		private function productInformationReceived( products : Array ) : void
		{
			InAppPurchase.productInformationReceived.remove( productInformationReceived );
			InAppPurchase.productInformationFailed.remove( productInformationFailed );
			feedback.appendText( "\n  productInformationReceived" );
			for each( var product : IAPProduct in products )
			{
				feedback.appendText( "\n  id: " + product.id );
				feedback.appendText( "\n    title: " + product.title );
				feedback.appendText( "\n    description: " + product.desc );
				feedback.appendText( "\n    price: " + product.price );
				feedback.appendText( "\n    formattedPrice: " + product.formattedPrice );
				feedback.appendText( "\n    locale: " + product.priceLocale );
			}
		}
		
		private function productInformationFailed() : void
		{
			InAppPurchase.productInformationReceived.remove( productInformationReceived );
			InAppPurchase.productInformationFailed.remove( productInformationFailed );
			feedback.appendText( "\n  productInformationFailed" );
		}

		private function validConsumable( event : MouseEvent ) : void
		{
			feedback.text = "InAppPurchase.purchaseProduct( 'consumable1' ):";
			InAppPurchase.purchaseProduct( "consumable1" );
		}
		
		private function validNonconsumable( event : MouseEvent ) : void
		{
			feedback.text = "InAppPurchase.purchaseProduct( 'nonconsumable1' ):";
			InAppPurchase.purchaseProduct( "nonconsumable1" );
		}
		
		private function invalidPurchase( event : MouseEvent ) : void
		{
			feedback.text = "InAppPurchase.purchaseProduct( 'invalid1' ):";
			InAppPurchase.purchaseProduct( "invalid1" );
		}
		
		private function restorePurchases( event : MouseEvent ) : void
		{
			feedback.text = "InAppPurchase.restorePurchases():";
			InAppPurchase.restorePurchases();
		}
		
		private function getCurrentTransactions( event : MouseEvent ) : void
		{
			feedback.text = "InAppPurchase.getCurrentTransactions():";
			var transactions : Array = InAppPurchase.getCurrentTransactions();
			if( transactions.length > 0 )
			{
				feedback.appendText( "\n  transactions received" );
				for each( var transaction : IAPTransaction in transactions )
				{
					outputTransactionDetails( transaction );
				}
			}
			else
			{
				feedback.appendText( "\n  no current transactions" );
			}
		}
		
		private function outputTransactionDetails( transaction : IAPTransaction ) : void
		{
			feedback.appendText( "\n  id: " + transaction.id );
			feedback.appendText( "\n    product: " + transaction.productId );
			feedback.appendText( "\n    quantity: " + transaction.productQuantity );
			feedback.appendText( "\n    state: " + transaction.state );
			feedback.appendText( "\n    date: " + transaction.date );
			if( transaction.error )
			{
				feedback.appendText( "\n    error: " + transaction.error.errorID + ", " + transaction.error.errorID );
			}
			if( transaction.receipt )
			{
				feedback.appendText( "\n    receipt received, length " + transaction.receipt.length );
			}
			if( transaction.originalTransaction )
			{
				feedback.appendText( "\n    originalTransaction: " );
				feedback.appendText( "\n    id: " + transaction.originalTransaction.id );
				feedback.appendText( "\n      product: " + transaction.originalTransaction.productId );
				feedback.appendText( "\n      quantity: " + transaction.originalTransaction.productQuantity );
				feedback.appendText( "\n      state: " + transaction.originalTransaction.state );
				feedback.appendText( "\n      date: " + transaction.originalTransaction.date );
			}
		}
		
		private function finishCompletePurchases( event : MouseEvent ) : void
		{
			var transactions : Vector.<IAPTransaction> = new Vector.<IAPTransaction>();
			var transaction : IAPTransaction;
			for each( transaction in completePurchases )
			{
				transactions.push( transaction );
			}
			if( transactions.length == 0 )
			{
				feedback.text = "No complete transactions to process.";
			}
			else
			{
				feedback.text = "InAppPurchase.finishTransaction( id ):";
				for each( transaction in transactions )
				{
					var success : Boolean = InAppPurchase.finishTransaction( transaction.id );
					feedback.appendText( "\n  " + transaction.id + ":" + transaction.productId + " - " + success );
					if( success )
					{
						delete completePurchases[ transaction.id ];
					}
				}
			}
		}
		
		private function finishFailedPurchases( event : MouseEvent ) : void
		{
			var transactions : Vector.<IAPTransaction> = new Vector.<IAPTransaction>();
			var transaction : IAPTransaction;
			for each( transaction in failedPurchases )
			{
				transactions.push( transaction );
			}
			if( transactions.length == 0 )
			{
				feedback.text = "No failed transactions to process.";
			}
			else
			{
				feedback.text = "InAppPurchase.finishTransaction( id ):";
				for each( transaction in transactions )
				{
					var success : Boolean = InAppPurchase.finishTransaction( transaction.id );
					feedback.appendText( "\n  " + transaction.id + ":" + transaction.productId + " - " + success );
					if( success )
					{
						delete failedPurchases[ transaction.id ];
					}
				}
			}
		}
		
		private function finishRestoredPurchases( event : MouseEvent ) : void
		{
			var transactions : Vector.<IAPTransaction> = new Vector.<IAPTransaction>();
			var transaction : IAPTransaction;
			for each( transaction in restoredPurchases )
			{
				transactions.push( transaction );
			}
			if( transactions.length == 0 )
			{
				feedback.text = "No restored transactions to process.";
			}
			else
			{
				feedback.text = "InAppPurchase.finishTransaction( id ):";
				for each( transaction in transactions )
				{
					var success : Boolean = InAppPurchase.finishTransaction( transaction.id );
					feedback.appendText( "\n  " + transaction.id + ":" + transaction.productId + " - " + success );
					if( success )
					{
						delete restoredPurchases[ transaction.id ];
					}
				}
			}
		}
		
		private function animate( event : Event ) : void
		{
			shape.x += direction;
			if( shape.x <= 0 )
			{
				direction = 1;
			}
			if( shape.x > 320 )
			{
				direction = -1;
			}
		}
	}
}