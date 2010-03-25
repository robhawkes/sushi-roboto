package game {
	import caurina.transitions.Tweener;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	public class GameUIHelpMarker extends EventDispatcher {
		private var _helpLevelMarker:MovieClip;
		private var _mask:Shape;
		private var _ui:MovieClip;
		
		public function GameUIHelpMarker(width:int, height:int) {
			this._ui = new MovieClip();
			
			this._mask = new Shape();
			this._mask.graphics.beginFill(0x222222);
			this._mask.graphics.drawRect(0, 0, width, height);
			this._mask.alpha = 0.7;
			
			this._ui.addChild(this._mask);
			
			this._helpLevelMarker = new HelpLevelMarker();
			this._helpLevelMarker.x = width/2;
			this._helpLevelMarker.y = height/2;
			
			this._ui.addChild(this._helpLevelMarker);
			
			if (this._helpLevelMarker.getChildByName("closeButton")) {
				var closeButton:MovieClip = this._helpLevelMarker.getChildByName("closeButton") as MovieClip;
				closeButton.addEventListener(MouseEvent.CLICK, this._onClickCloseButton);
			}
			
			/* Hide UI by default */
			this._ui.visible = false;
			this._helpLevelMarker.scaleX = 0;
			this._helpLevelMarker.scaleY = 0;
			this._mask.alpha = 0;
		}
		
		private function _onClickCloseButton(e:MouseEvent):void {
			this.hide();
		}
		
		public function show():void {
			this._ui.visible = true;
			Tweener.addTween(this._mask, {alpha: 0.8, time: 0.2, delay: 1, transition: "linear"});
			Tweener.addTween(this._helpLevelMarker, {scaleX: 1, scaleY: 1, time: 0.5, delay: 1.7, transition: "easeOutBack"});
		}
		
		public function hide():void {
			Tweener.addTween(this._helpLevelMarker, {scaleX: 0, scaleY: 0, time: 0.5, transition: "easeInBack"});
			Tweener.addTween(this._mask, {alpha: 0, time: 0.2, delay: 1, transition: "linear", onCompleteScope: this, onComplete: onHideComplete});
			
			function onHideComplete():void {
				this._ui.visible = false;
				dispatchEvent(new Event("GAME_HELPUI_CLOSED"));
			}
		}
		
		public function get ui():MovieClip {
			return this._ui;
		}
	}
}