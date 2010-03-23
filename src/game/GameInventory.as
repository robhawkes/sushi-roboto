package game {
	import flash.display.Sprite;
	import flash.text.TextField;

	public class GameInventory {
		private var _levelData:GameLevelData;
		private var _registry:GameRegistry;
		private var _selectedItem:String;
		private var _sprite:Sprite;
		
		public function GameInventory() {
			this._registry = GameRegistry.getInstance();
			this._levelData = this._registry.getEntry("levelData");

			/* Default selection to debug object */
			this._selectedItem = "debug";
		}
		
		private function _updateInventory():void {
			
		}
		
		public function decreaseAmountOfItem(item:String):void {
			if (this._levelData.getObjectInventory(item) > 0) {
				
			}
		}
		
		public function increaseAmountOfItem(item:String):void {
			if (this._levelData.getObjectInventory(item) > 0) {
				
			}
		}
		
		public function getSelectedItem():String {
			return this._selectedItem;
		}
	}
}