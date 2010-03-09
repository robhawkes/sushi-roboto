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
			this._levelObjects.push({type: "start", position: new Point(1, 0)},
									{type: "conveyor", position: new Point(3, 2)},
									{type: "conveyor", position: new Point(3, 3)},
									{type: "wall", position: new Point(1, 3)},
									{type: "wall", position: new Point(2, 3)},
									{type: "wall", position: new Point(2, 1)},
									{type: "wall", position: new Point(2, 5)},
									{type: "wall", position: new Point(4, 5)},
									{type: "wall", position: new Point(6, 5)},
									{type: "fire", position: new Point(5, 1)},
									{type: "fire", position: new Point(5, 2)},
									{type: "fire", position: new Point(6, 2)},
									{type: "fire", position: new Point(3, 6)},
									{type: "wasabi", position: new Point(4, 1), texture: "bottom"},
									{type: "wasabi", position: new Point(4, 2), texture: "top"},
									{type: "finish", position: new Point(6, 0)});
			
			this._objectInventory = new Array();
			this._objectInventory["direction"] = 6;
			this._objectInventory["water"] = 3;
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