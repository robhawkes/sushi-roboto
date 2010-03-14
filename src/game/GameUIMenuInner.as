package game {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;

	public class GameUIMenuInner extends EventDispatcher {
		/* Game UI */
		[Embed(source="resources/GameUIMenuInnerTemplate.swf", symbol="InnerUI")]
		private var _gameUIMenuInner:Class;
		
		private var _ui:Sprite;
		
		public function GameUIMenuInner() {
			this._ui = new this._gameUIMenuInner() as Sprite;
			this._ui.x = 250;
			this._ui.y = 250;
			
			var resetButton:Sprite = this._ui.getChildByName("resetButton") as Sprite;
			resetButton.buttonMode = true;
			resetButton.addEventListener(MouseEvent.CLICK, this._onClickResetButton);
		}
		
		private function _onClickResetButton(e:MouseEvent):void {
			dispatchEvent(new Event("GAME_RESET"));
		}
		
		public function get ui():Sprite {
			return this._ui;
		}
	}
}