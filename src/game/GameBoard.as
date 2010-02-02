package game {
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.utils.geom.FLARPVGeomUtils;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.render.data.RenderHitData;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.layer.ViewportLayer;
	import org.papervision3d.view.layer.util.ViewportLayerSortMode;

	public class GameBoard {
		private var _activeObjectId:int = -1;
		private var _boardViewportLayer:ViewportLayer;
		private var _character:GameCharacter;
		private var _container:DisplayObject3D;
		private var _containersByObject:Dictionary;
		private var _grid:GameGrid;
		private var _levelData:GameLevelData;
		private var _levelObjects:Vector.<GameLevelObject>;
		private var _objectViewportLayer:ViewportLayer;
		private var _playerObjects:Vector.<GameObject>;
		private var _registry:GameRegistry; 
		
		public function GameBoard() {
			this._registry = GameRegistry.getInstance();
			
			this._container = new DisplayObject3D();
			
			this._containersByObject = new Dictionary(true);
			this._levelObjects = new Vector.<GameLevelObject>();
			this._playerObjects = new Vector.<GameObject>();
			
			this._levelData = this._registry.getEntry("levelData");
			if (this._levelData)
				this._grid = new GameGrid(this._levelData.width, this._levelData.height, this._levelData.rows, this._levelData.columns);
			
			this._character = new GameCharacter();
		}
		
		public function initViewportLayers():void {
			var papervision:GamePapervision = this._registry.getEntry("papervision");
			if (papervision) {
				trace("Setting up viewport layers");
				
				this._boardViewportLayer = papervision.viewport.getChildLayer(this._grid.container, true);
				this._boardViewportLayer.sortMode = ViewportLayerSortMode.INDEX_SORT;

				this._objectViewportLayer = new ViewportLayer(papervision.viewport, null);
				this._boardViewportLayer.addLayer(this._objectViewportLayer);
				
				this._objectViewportLayer.addDisplayObject3D(this._character.container, true);
			}
		}
		
		public function populateBoard():void {
			/* Add grid 3D object to board */
			this._container.addChild(this._grid.container);
			
			/* Add character to board */
			this._container.addChild(this._character.container);
			var characterPosition:Point = this._grid.gridReferenceToWorldCoord(1, 0);
			this._character.moveToPoint(characterPosition.x, characterPosition.y);
			
			/* Add level objects to board */
			this._addLevelObjects();
		}
		
		private function _addLevelObjects():void {
			var wall:GameLevelWallObject = new GameLevelWallObject();
			
			var coord:Point = this._grid.gridReferenceToWorldCoord(1, 3);
			wall.x = coord.x;
			wall.y = coord.y;
			
			/* Add object to objects viewport layer */
			this._objectViewportLayer.addDisplayObject3D(wall, true);
			
			this._levelObjects.push(wall);
			this._container.addChild(wall);
		}
		
		public function addDebugObject(x:int = 0, y:int = 0, z:int = 0, rotationX:int = 0, rotationY:int = 0, rotationZ:int = 0):void {
			/* TODO: Convert mandatory method parameters into object of optional parameters */ 
			if (this._activeObjectId < 0) {
				var object:GameObject = new GameDebugObject();
				this._objectViewportLayer.addDisplayObject3D(object, true);
				
				/* Add object to list and set _activeObjectId to object position in list */
				this._activeObjectId = this._playerObjects.push(object)-1;
				
				this._container.addChild(object);
			}
		}
		
		public function updateBoard(marker:FLARMarker):void {
			/* Transform board to new position in 3D space */
			this._container.transform = FLARPVGeomUtils.convertFLARMatrixToPVMatrix(marker.transformMatrix);
			
			/* Change X rotation to correct angle */
			this._container.pitch(180);
		}
		
		public function updateActiveObject(marker:FLARMarker, stageWidth:int = 0, stageHeight:int = 0):void {
			var papervision:GamePapervision = this._registry.getEntry("papervision");
			var map:GameMap = this._registry.getEntry("gameMap");
			
			var rhd:RenderHitData = papervision.viewport.hitTestPointObject(new Point(marker.centerpoint.x-(stageWidth/2), marker.centerpoint.y-(stageHeight/2)), this._grid.container);
			if (rhd.hasHit) {
				var u:Number = rhd.u;
				var v:Number = rhd.v;
				
				/* Reverse V to take reversed Y coordinates into concideration */ 
				var gridRef:Point = this._grid.coordToGridReference(u*this._grid.width, (v*-1+1)*this._grid.height);
				var coord:Point = this._grid.gridReferenceToWorldCoord(gridRef.x, gridRef.y);
				
				this._playerObjects[this._activeObjectId].x = coord.x;
				this._playerObjects[this._activeObjectId].y = coord.y;
				
				if (map)
					map.updateMarker(Math.round(u*100)/100, Math.round((v*-1+1)*100)/100);
			} else {
				if (map)
					map.removeMarker();
			}
		}
		
		public function updateObjects():void {
			this._updateLevelObjects();
			this._updateCharacter();
		}
		
		private function _updateLevelObjects():void {
			/* Store reference to amount of objects on board */
			var i:int = this._levelObjects.length;
			var object:GameLevelObject;
			
			/* Loop through all objects */
			while (i--) {
				/* Basic object checks and updates */
				object = this._levelObjects[i];
			}
		}
		
		private function _updateCharacter():void {
			var characterGridRef:Point = this._grid.worldCoordToGridReference(this._character.container.x, this._character.container.y);
			var nextSegmentCoord:Point = this._grid.gridReferenceToWorldCoord(characterGridRef.x, characterGridRef.y+1);
			var nextSegmentDistance:int = nextSegmentCoord.y-this._character.container.y;
			
			/* Store reference to amount of objects on board */
			var i:int = this._levelObjects.length;
			var object:GameLevelObject;
			
			/* Character is inside grid boundary */
			if (!this._grid.gridRefIsOutsideBoundary(characterGridRef.x, characterGridRef.y+1)) {
				/* Loop through all objects */
				while (i--) {
					/* Basic object checks and updates */
					object = this._levelObjects[i];
					
					var objectGridRef:Point = this._grid.worldCoordToGridReference(object.x, object.y);
					
					var objectDistanceSegmentsX:int = objectGridRef.x-characterGridRef.x;
					var objectDistanceSegmentsY:int = objectGridRef.y-characterGridRef.y;
					
					var objectDistanceCoordX:int = objectGridRef.x-this._character.container.x;
					var objectDistanceCoordY:int = objectGridRef.y-this._character.container.y;
					
					/* Object is in the next segment in front of character */
					if (objectDistanceSegmentsY == 1 && objectDistanceSegmentsX == 0) {
						var solid:Boolean = object.getAttribute("solid");
						if (solid === true) {
							/* Stop character from moving */
						} else {
							this._character.animateForward(nextSegmentDistance);
						}
					} else {
						this._character.animateForward(nextSegmentDistance);
					}
				}
			}
		}
		
		public function get character():GameCharacter {
			return this._character;
		}
		
		public function get container():DisplayObject3D {
			return this._container;
		}
		
		public function get grid():GameGrid {
			return this._grid;
		}
	}
}