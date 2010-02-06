package game {
	import flash.display.Sprite;
	import flash.text.TextField;

	public class GameInventory {
		private var _levelData:GameLevelData;
		private var _registry:GameRegistry;
		private var _sprite:Sprite;
		
		public function GameInventory() {
			this._registry = GameRegistry.getInstance();
			this._levelData = this._registry.getEntry("levelData");
			
			this._drawInventory();
		}
		
		private function _drawInventory():void {
			/* Set up container sprite */
			this._sprite = new Sprite();
			
			var object:Object;
			var objectLabel:TextField;
			var objectAmount:TextField;
			/* Loop through objects in inventory */
			for (object in this._levelData.objectInventory) {
				objectLabel = new TextField();
				objectLabel.text = object.toString();
				
				objectAmount = new TextField();
				objectAmount.text = this._levelData.objectInventory[object];
				
				trace(objectLabel.text+": "+objectAmount.text);
			}
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
	}
}