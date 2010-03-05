package game {
	import flash.geom.Point;

	public class GameLevelData {
		private var _width:int;
		private var _height:int;
		private var _rows:int;
		private var _columns:int;
		
		private var _levelObjects:Array;
		private var _objectInventory:Array; 
		
		public function GameLevelData(levelId:int) {
			this._populateData();
		}
		
		private function _populateData():void {
			/* Pretend we've already grabbed external XML data for tutorial level */
			this._width = 240;
			this._height = 240;
			this._rows = 6;
			this._columns = 6;
			
			this._levelObjects = new Array();
			this._levelObjects.push({type: "wall", position: new Point(3, 2)},
									{type: "wall", position: new Point(4, 4)},
									{type: "water", position: new Point(1, 3)},
									{type: "finish", position: new Point(5, 7)});
			
			this._objectInventory = new Array();
			this._objectInventory["debug"] = 3;
			this._objectInventory["direction"] = 6;
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
		
		public function get levelObjects():Array {
			return this._levelObjects;
		}
		
		public function get objectInventory():Object {
			return this._objectInventory;
		}
	}
}