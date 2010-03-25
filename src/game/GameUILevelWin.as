package game {
	import caurina.transitions.Tweener;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	public class GameUILevelWin extends EventDispatcher {
		private var _levelMenu:MovieClip;
		private var _mask:Shape;
		private var _ui:MovieClip;
		
		public function GameUILevelWin(width:int, height:int) {
			this._ui = new MovieClip();
			
			this._mask = new Shape();
			this._mask.graphics.beginFill(0x222222);
			this._mask.graphics.drawRect(0, 0, width, height);
			this._mask.alpha = 0.7;
			
			this._ui.addChild(this._mask);
			
			this._levelMenu = new LevelMenuWin();
			this._levelMenu.x = width/2;
			this._levelMenu.y = height/2;
			
			this._ui.addChild(this._levelMenu);
			
			var nextButton:MovieClip = this._levelMenu.getChildByName("nextButton") as MovieClip;
			nextButton.addEventListener(MouseEvent.CLICK, this._onClickNextButton);
			
			var menuButton:MovieClip = this._levelMenu.getChildByName("menuButton") as MovieClip;
			menuButton.addEventListener(MouseEvent.CLICK, this._onClickMenuButton);
			
			/* Hide UI by default */
			this._ui.visible = false;
			this._levelMenu.scaleX = 0;
			this._levelMenu.scaleY = 0;
			this._mask.alpha = 0;
		}
		
		private function _onClickNextButton(e:MouseEvent):void {
			dispatchEvent(new Event("GAME_NEXT_LEVEL"));
		}
		
		private function _onClickMenuButton(e:MouseEvent):void {
			dispatchEvent(new Event("GAME_MENU"));
		}
		
		public function show(delay:Number = 0):void {
			this._ui.visible = true;
			Tweener.addTween(this._mask, {alpha: 0.8, time: 0.2, delay: delay, transition: "linear"});
			Tweener.addTween(this._levelMenu, {scaleX: 1, scaleY: 1, time: 0.3, delay: delay+0.2, transition: "easeOutBack"});
		}
		
		public function hide():void {
			Tweener.addTween(this._levelMenu, {scaleX: 0, scaleY: 0, time: 0.3, transition: "easeInBack"});
			Tweener.addTween(this._mask, {alpha: 0, time: 0.2, delay: 0.3, transition: "linear", onCompleteScope: this, onComplete: onHideComplete});
			
			function onHideComplete():void {
				this._ui.visible = false;
				dispatchEvent(new Event("GAME_UI_CLOSED"));
			}
		}
		
		public function get ui():MovieClip {
			return this._ui;
		}
	}
}