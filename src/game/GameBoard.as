package game {
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.utils.geom.FLARPVGeomUtils;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.render.data.RenderHitData;
	import org.papervision3d.objects.DisplayObject3D;

	public class GameBoard {
		private var _activeObjectId:int = -1;
		private var _container:DisplayObject3D;
		private var _containersByObject:Dictionary;
		private var _grid:GameGrid;
		private var _objects:Vector.<GameObject>;
		private var _registry:GameRegistry; 
		
		public function GameBoard() {
			this._registry = GameRegistry.getInstance();
			
			this._container = new DisplayObject3D();
			
			this._containersByObject = new Dictionary(true);
			this._objects = new Vector.<GameObject>();
			
			var levelData:GameLevelData = this._registry.getEntry("levelData");
			if (levelData)
				this._grid = new GameGrid(levelData.width, levelData.height, levelData.rows, levelData.columns);
			
			this._populateBoard();
		}
		
		private function _populateBoard():void {
			this._container.addChild(this._grid.container);
		}
		
		public function addDebugObject(x:int = 0, y:int = 0, z:int = 0, rotationX:int = 0, rotationY:int = 0, rotationZ:int = 0):void {
			/* TODO: Convert mandatory method parameters into object of optional parameters */ 
			if (this._activeObjectId < 0) {
				var object:GameObject = new GameDebugObject();
				
				/* Add object to list and set _activeObjectId to object position in list */
				this._activeObjectId = this._objects.push(object)-1;
				
				this._container.addChild(object);
			}
		}
		
		public function updateBoard(marker:FLARMarker):void {
			/* Transform board to new position in 3D space */
			this._container.transform = FLARPVGeomUtils.convertFLARMatrixToPVMatrix(marker.transformMatrix);
		}
		
		public function updateActiveObject(marker:FLARMarker, stageWidth:int = 0, stageHeight:int = 0):void {
			var papervision:GamePapervision = this._registry.getEntry("papervision");
			var map:GameMap = this._registry.getEntry("gameMap");
			
			var rhd:RenderHitData = papervision.viewport.hitTestPointObject(new Point(marker.centerpoint.x-(stageWidth/2), marker.centerpoint.y-(stageHeight/2)), this._grid.grid3DObject);
			if (rhd.hasHit) {					
				//trace("Hit");
				
				trace(this._grid.coordToGridReference(rhd.u*this._grid.width, rhd.v*this._grid.height))
				
				this._objects[this._activeObjectId].rotationZ += 5;
				
				// Convert to use ARGameGrid calcGridReference method */
				//var gridX:Number = Math.floor((Math.floor(rhd.u*10)/10)*this.grid.segColCount)+1;
				//var gridY:Number = Math.floor((Math.floor(rhd.v*10)/10)*this.grid.segRowCount)+1;
				
				//trace("[x: "+Math.round(rhd.x)+", y: "+Math.round(rhd.y)+"], [u: "+rhd.u+", v:"+rhd.v+"]");
				//trace("Grid pos: "+gridX+", "+gridY);
				
				//container.x = (rhd.u-0.5)*this.grid.width;
				//container.y = ((rhd.v-0.5)*this.grid.height)*-1;
				//container.z = 0;
				
				//trace("CubeX: "+container.x+", CubeY: "+container.y+" CalcX: "+(rhd.u-0.5)*this.grid.width+", CalcY: "+((rhd.v-0.5)*this.grid.height)*-1);
				
				if (map)
					map.updateMarker(Math.round(rhd.u*100)/100, Math.round(rhd.v*100)/100);
			} else {
				if (map)
					map.removeMarker();
			}
		}
		
		public function updateObjects():void {
			/* Store reference to amount of objects on board */
			var i:int = this._objects.length;
			var object:GameObject;
			
			/* Loop through all objects */
			while (i--) {
				/* Basic object checks and updates */
				object = this._objects[i];
			}
		}
		
		public function get container():DisplayObject3D {
			return this._container;
		}
	}
}