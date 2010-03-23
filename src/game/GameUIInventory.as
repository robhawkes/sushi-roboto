package game {
	import caurina.transitions.Tweener;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	public class GameUIInventory extends EventDispatcher {
		private var _inventoryMenu:MovieClip;
		private var _ui:MovieClip;
		private var _originX:int;
		
		public function GameUIInventory(width:int, height:int) {
			this._ui = new MovieClip();
			
			this._inventoryMenu = new InventoryMenu();
			this._inventoryMenu.x = this._originX = width;
			this._inventoryMenu.y = 0;
			
			this._ui.addChild(this._inventoryMenu);
			
			if (this._inventoryMenu.getChildByName("directionButton")) {
				var directionButton:MovieClip = this._inventoryMenu.getChildByName("directionButton") as MovieClip;
				directionButton.addEventListener(MouseEvent.CLICK, this._onClickDirectionButton);
			}
			
			var menuButton:MovieClip = this._inventoryMenu.getChildByName("menuButton") as MovieClip;
			menuButton.addEventListener(MouseEvent.CLICK, this._onClickMenuButton);
		}
		
		private function _onClickMenuButton(e:MouseEvent):void {
			dispatchEvent(new Event("GAME_LEVELUI_OPEN"));
		}
		
		private function _onClickDirectionButton(e:MouseEvent):void {
			dispatchEvent(new Event("GAME_OBJECT_ADD_DIRECTION"));
		}
		
		public function show():void {
			Tweener.addTween(this._inventoryMenu, {x: this._originX-this._ui.width, time: 0.3, delay: 0.2, transition: "easeOutExpo"});
		}
		
		public function hide():void {
			Tweener.addTween(this._inventoryMenu, {x: this._originX, time: 0.3, transition: "easeInExpo", onCompleteScope: this, onComplete: onHideComplete});
			
			function onHideComplete():void {
				dispatchEvent(new Event("GAME_INVENTORYUI_CLOSED"));
			}
		}
		
		public function get ui():MovieClip {
			return this._ui;
		}
	}
}