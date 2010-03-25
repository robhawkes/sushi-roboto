package game {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	public class GameUICredits extends EventDispatcher {
		private var _menu:MovieClip;
		private var _ui:MovieClip;
		
		public function GameUICredits(width:int, height:int) {
			this._ui = new MovieClip();
			
			this._menu = new CreditsMenu();
			this._menu.x = (width-40);
			this._menu.y = (height-40);
			
			this._ui.addChild(this._menu);

			var menuButton:MovieClip = this._menu.getChildByName("menuButton") as MovieClip;
			menuButton.addEventListener(MouseEvent.CLICK, this._onClickMenuButton);
		}
		
		private function _onClickMenuButton(e:MouseEvent):void {
			dispatchEvent(new Event("GAME_MENU"));
		}
		
		public function show(delay:Number = 0):void {
			this._ui.visible = true;
		}
		
		public function hide():void {
			this._ui.visible = false;
		}
		
		public function get ui():MovieClip {
			return this._ui;
		}
	}
}