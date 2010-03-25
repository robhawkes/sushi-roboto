package game {
	import flash.geom.Point;

	public class GameLevelData {
		private var _levelId:int = 0;
		
		private var _width:int;
		private var _height:int;
		private var _rows:int;
		private var _columns:int;
		
		private var _levelObjects:Array;
		private var _environmentObjects:Array;
		private var _objectInventory:Array; 
		
		public function GameLevelData(levelId:int) {
			this._levelId = levelId;
			this._populateData();
		}
		
		private function _populateData():void {
			/* Pretend we've already grabbed external XML data for level */
			
			this._width = 240;
			this._height = 240;
			this._rows = 6;
			this._columns = 6;
			
			this._levelObjects = new Array();
			this._environmentObjects = new Array();
			this._objectInventory = new Array();
			
			switch (this._levelId) {
				case 1:
					this._levelObjects.push({type: "start", position: new Point(1, 0)},
						{type: "wall", position: new Point(1, 3), invisible: true},
						{type: "wall", position: new Point(2, 3), invisible: true},
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
					
					this._objectInventory["direction"] = 8;
					this._objectInventory["water"] = 3;
					
					this._environmentObjects.push({type: "chopsticks", position: new Point(3, 3), orientation: "left"});
					
					break;
				case 2:
					this._levelObjects.push({type: "start", position: new Point(1, 0)},
						{type: "conveyor", position: new Point(3, 4), orientation: "bottom"},
						{type: "conveyor", position: new Point(3, 5), orientation: "bottom"},
						{type: "conveyor", position: new Point(3, 6), orientation: "bottom"},
						{type: "wall", position: new Point(2, 2)},
						{type: "wall", position: new Point(4, 5), invisible: true},
						{type: "wall", position: new Point(4, 6), invisible: true},
						{type: "fire", position: new Point(5, 3)},
						{type: "fire", position: new Point(6, 2)},
						{type: "wasabi", position: new Point(1, 2), texture: "right"},
						{type: "wasabi", position: new Point(0, 2), texture: "left"},
						{type: "dough", position: new Point(2, 3), texture: "bottom"},
						{type: "dough", position: new Point(2, 4), texture: "middle"},
						{type: "dough", position: new Point(2, 5), texture: "top"},
						{type: "water", position: new Point(3, 1)},
						{type: "water", position: new Point(3, 2)},
						{type: "water", position: new Point(3, 3)},
						{type: "water", position: new Point(4, 1)},
						{type: "water", position: new Point(4, 2)},
						{type: "water", position: new Point(4, 3)},
						{type: "finish", position: new Point(5, 7), orientation: "bottom"});
					
					this._environmentObjects.push({type: "sink", position: new Point(3, 1), size: new Point(2, 3)},
						{type: "tap", position: new Point(5, 2), orientation: "left"},
						{type: "chopsticks", position: new Point(4, 5), orientation: "top"});
					
					this._objectInventory["direction"] = 6;
					this._objectInventory["water"] = 1;
					this._objectInventory["wok"] = 1;
					
					break
				default:
					trace("Level id doesn't exist");
					break;
			}
		}
		
		public function getObjectInventory(item:String):int {
			if (this._objectInventory[item])
				return this._objectInventory[item];
			
			return 0;
		}
		
		public function get levelId():int {
			return this._levelId;
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
		
		public function get environmentObjects():Array {
			return this._environmentObjects;
		}
		
		public function get objectInventory():Object {
			return this._objectInventory;
		}
	}
}