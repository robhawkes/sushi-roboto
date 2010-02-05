package game {
	public class GameLevelData {
		private var _width:int;
		private var _height:int;
		private var _rows:int;
		private var _columns:int;
		
		private var _objectInventory:Array; 
		
		public function GameLevelData(levelId:int) {
			this._populateData();
		}
		
		private function _populateData():void {
			/* Pretend we've already grabbed external XML data for tutorial level */
			this._width = 200;
			this._height = 200;
			this._rows = 5;
			this._columns = 5;
			
			this._objectInventory = new Array();
			this._objectInventory["debug"] = 1;
			this._objectInventory["direction"] = 3;
		}
		
		public function getObjectInventory(item:String):int {
			if (this._objectInventory[item])
				return this._objectInventory[item];
			
			return 0;
		}
		
		public function get width():int {
			return this._width;
		}
		
		public function get height():int {
			return this._height;
		}
		
		public function get rows():int {
			return this._rows;
		}
		
		public function get columns():int {
			return this._columns;
		}
	}
}