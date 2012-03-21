package com.hdi.nativeExtensions
{
	import flash.external.ExtensionContext;
	import flash.events.EventDispatcher;
    import flash.events.StatusEvent;

	public class NativeAds
	{
		private static var extensionContext : ExtensionContext = null;
		private static var adVisible:Boolean = false;
		private static var _dispatcher:EventDispatcher;
		
		
		private static var _x:int;
		private static var _y:int;
		private static var _w:int;
		private static var _h:int;
		private static var _wasVisible:Boolean = false;
		
		
		private static function initExtension():void
		{
			if ( !extensionContext)
			{
				extensionContext = ExtensionContext.createExtensionContext( "com.hdi.nativeExtensions.NativeAds", null );
				extensionContext.addEventListener( StatusEvent.STATUS, onAdHandler );
			}
		}
		
		private static function onAdHandler( event : StatusEvent ) : void
        {
            if( event.code == NativeAdsEvent.AD_CLICKED )
            {
                dispatcher.dispatchEvent( new NativeAdsEvent(NativeAdsEvent.AD_CLICKED));
            } else if(event.code == NativeAdsEvent.AD_ERROR)
			{
				dispatcher.dispatchEvent( new NativeAdsEvent(NativeAdsEvent.AD_ERROR));
			} 	else if(event.code == NativeAdsEvent.AD_RECEIVED)
			{
				dispatcher.dispatchEvent( new NativeAdsEvent(NativeAdsEvent.AD_RECEIVED));
			}
        }
		
		/**
		 * Is the extension supported on this platform.
		 * Adobe recomment to implement this method in every native extension.
		 */
		public static function get isSupported() : Boolean
		{
			initExtension();
			return extensionContext ? true : false;
		}
		/** 
		 * Dispatcher object, which will dispatch different events.
		 * If you wat to be notified when an event is fired add a listenr to this object.
		 * For more information look at NativeAdsEvent
		 * @see com.hdi.nativeExtensions.NativeAdsEvent
		 */
		public static function get dispatcher():EventDispatcher
		{
			if(!_dispatcher)
			{
				_dispatcher = new EventDispatcher();
			}
			return _dispatcher;
		}
		
		/**
		 * Set unit-id
		 */
		public static function setUnitId(unitId:String): void
		{
			initExtension();
			extensionContext.call("setUnitId",unitId);
		}
		
		/**
		 * Set ad mode. Default value is false, which means that the the component
		 * will display test ad. If true is passed then all request will return real ads.
		 * Be sure that it's true, when the app is published.
		 * Otherwise no impresions will be tracked and your users will see the test ad only.
		 */
		public static function setAdMode(isInRelaMode:Boolean): void
		{
			initExtension();
			extensionContext.call("setAdMode",isInRelaMode);
		}
		
		/**
		 * Init ad on a screen, in the specified rectangle.
		 * Works on iOS only.
		 */
		public static function initAd( x:int, y:int, width:int, height:int ) : void
		{
			initExtension();
			if(extensionContext)
			{
			
				extensionContext.call( "initAd", x, y, width, height );
			}	
		}

		/**
		 * Show ad on a screen, in the specified rectangle.
		 * This works similar to StageWebView class in AIR
		 */
		public static function showAd( x:int, y:int, width:int, height:int ) : void
		{
			if(!adVisible)
			{
				initExtension();
				if(extensionContext)
				{
					//record last position
					_x = x; _y = y;
					_w = width; _h = height;
					
					extensionContext.call( "showAd", x, y, width, height );
					adVisible = true;
				}

			}
			
		}
		/**
		 * Restor ad state. If the ad was visible then
		 * it will be displayed automatically.
		 * Usually this method is called on view.activate 
		 */
		public static function restoreAd():void
		{
			if(_wasVisible)
			{
				showAd(_x,_y,_w,_h);
				_wasVisible = false;
			}
		}
		/**
		 * Hide native ad view if it's visible
		 * Usually this method is called on view.deactivate
		 */
		public static function deactivateAd():void
		{
			if(adVisible)
			{
				initExtension();
				if(extensionContext)
				{
				
						extensionContext.call("hideAd");
						adVisible = false;
						_wasVisible =  true;
				
				}
			}
		}
		
		/**
		 * Hide ad view.
		 */
		public static function hideAd() : void
		{
			if(adVisible)
			{
				initExtension();
				if(extensionContext)
				{
					extensionContext.call("hideAd");
					adVisible = false;
				}
			}
		}
		
		
		/**
		 * Removes the ad view
		 */
		public static function removeAd() : void
		{
			initExtension();
			if(extensionContext)
			{
				extensionContext.call("removeAd");
				adVisible = false;
				_wasVisible = false;
			}

		}
		
		/**
		 * Clean up the extension - only if you no longer need it or want to free memory.
		 */
		public static function dispose() : void
		{
			if( extensionContext )
			{
                extensionContext.removeEventListener( StatusEvent.STATUS, onAdHandler );
				extensionContext.dispose();
				extensionContext = null;
				adVisible = false;
			}
		}
	}
}

