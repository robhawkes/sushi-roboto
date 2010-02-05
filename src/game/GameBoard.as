/*
 * TODO: Combine updateActiveDirectionalObject() and updateActivePlayerObjet() methods as they have similar functionality
 */
package game {
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.utils.geom.FLARPVGeomUtils;
	
	import flash.geom.Point;
	
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.render.data.RenderHitData;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.layer.ViewportLayer;
	import org.papervision3d.view.layer.util.ViewportLayerSortMode;

	public class GameBoard {
		private var _activeDirectionObjectId:int = -1;
		private var _activePlayerObjectId:int = -1;
		private var _boardViewportLayer:ViewportLayer;
		private var _character:GameCharacter;
		private var _container:DisplayObject3D;
		private var _directionObjects:Vector.<GameDirectionObject>;
		private var _grid:GameGrid;
		private var _levelData:GameLevelData;
		private var _levelObjects:Vector.<GameLevelObject>;
		private var _objectsInUseByType:Array;
		private var _objectViewportLayer:ViewportLayer;
		private var _playerObjects:Vector.<GameDebugObject>;
		private var _registry:GameRegistry; 
		
		public function GameBoard() {
			this._registry = GameRegistry.getInstance();
			
			this._container = new DisplayObject3D();
			
			this._levelObjects = new Vector.<GameLevelObject>();
			this._directionObjects = new Vector.<GameDirectionObject>();
			this._playerObjects = new Vector.<GameDebugObject>();
			
			this._objectsInUseByType = new Array();
			
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
			this._addCharacter();
			
			/* Add level objects to board */
			this._addLevelObjects();
		}
		
		private function _addCharacter():void {
			this._container.addChild(this._character.container);
			var characterPosition:Point = this._grid.gridReferenceToWorldCoord(1, 0);
			this._character.moveToPoint(characterPosition.x, characterPosition.y);
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
		
		public function addDirectionObject(x:int = 0, y:int = 0, z:int = 0, rotationX:int = 0, rotationY:int = 0, rotationZ:int = 0):void {
			if (this._levelData.getObjectInventory("direction") > 0) {
				var object:GameDirectionObject = new GameDirectionObject();
				object.x = x;
				object.y = y;
				object.rotationX = rotationX;
				object.rotationY = rotationY;
				object.rotationZ = rotationZ;
				
				this._objectViewportLayer.addDisplayObject3D(object, true);
				
				/* Add object to list and set _activeObjectId to object position in list */
				this._activeDirectionObjectId = this._directionObjects.push(object)-1;
				
				/* Increase number of direction objects in use */
				if (this._objectsInUseByType[object.type]) {
					this._objectsInUseByType[object.type] += 1;
				} else {
					this._objectsInUseByType[object.type] = 1;
				}
			
				this._container.addChild(object);
			}
		}
		
		public function addDebugObject(x:int = 0, y:int = 0, z:int = 0, rotationX:int = 0, rotationY:int = 0, rotationZ:int = 0):void {
			if (this._levelData.getObjectInventory("debug") > 0) {
				var object:GameDebugObject = new GameDebugObject();
				object.x = x;
				object.y = y;
				object.rotationX = rotationX;
				object.rotationY = rotationY;
				object.rotationZ = rotationZ;
				
				this._objectViewportLayer.addDisplayObject3D(object, true);
				
				/* Add object to list and set _activeObjectId to object position in list */
				this._activePlayerObjectId = this._playerObjects.push(object)-1;
				
				this._container.addChild(object);
			}
		}
		
		public function resetBoard():void {
			this._activeDirectionObjectId = -1;
			this._activePlayerObjectId = -1;
			
			/* Remove current character object from the 3D scene */
			this._container.removeChild(this._character.container);
			
			/* Add a new character object and reset position */
			this._character = new GameCharacter();
			this._addCharacter();
		}
		
		public function updateBoard(marker:FLARMarker):void {
			/* Transform board to new position in 3D space */
			this._container.transform = FLARPVGeomUtils.convertFLARMatrixToPVMatrix(marker.transformMatrix);
			
			/* Change X rotation to correct angle */
			this._container.pitch(180);
		}
		
		public function updateActiveDirectionObject(marker:FLARMarker, stageWidth:int = 0, stageHeight:int = 0):void {
			var papervision:GamePapervision = this._registry.getEntry("papervision");
			var map:GameMap = this._registry.getEntry("gameMap");
			
			var rhd:RenderHitData = papervision.viewport.hitTestPointObject(new Point(marker.centerpoint.x-(stageWidth/2), marker.centerpoint.y-(stageHeight/2)), this._grid.container);
			if (rhd.hasHit) {
				var u:Number = rhd.u;
				var v:Number = rhd.v;
				
				/* Reverse V to take reversed Y coordinates into concideration */ 
				var gridRef:Point = this._grid.coordToGridReference(u*this._grid.width, (v*-1+1)*this._grid.height);
				var coord:Point = this._grid.gridReferenceToWorldCoord(gridRef.x, gridRef.y);
				
				this._directionObjects[this._activeDirectionObjectId].x = coord.x;
				this._directionObjects[this._activeDirectionObjectId].y = coord.y;
				
				/* Rotation of the game board */
				var boardRotation:Number3D = Matrix3D.matrix2euler(this._container.transform);
				/* Rotation of the marker */
				var markerRotation:Number3D = Matrix3D.matrix2euler(FLARPVGeomUtils.convertFLARMatrixToPVMatrix(marker.transformMatrix));
				/* Calculated rotation for object */
				var objectRotation:Number = markerRotation.z-boardRotation.z;
				
				if (objectRotation >= -46 && objectRotation <= 45) {
					//trace(0);
					this._directionObjects[this._activeDirectionObjectId].rotationZ = 0;
				} else if (objectRotation >= 46 && objectRotation <= 135) {
					//trace(90);
					this._directionObjects[this._activeDirectionObjectId].rotationZ = 90;
				} else if ((objectRotation >= 136 && objectRotation <= 180) || (objectRotation >= -180 && objectRotation <= -135)) {
					//trace(180);
					this._directionObjects[this._activeDirectionObjectId].rotationZ = 180;
				} else if (objectRotation >= -134 && objectRotation <= -45) {
					//trace(-90);
					this._directionObjects[this._activeDirectionObjectId].rotationZ = -90;
				}
				
				if (map)
					map.updateMarker(Math.round(u*100)/100, Math.round((v*-1+1)*100)/100);
			} else {
				if (map)
					map.removeMarker();
			}
		}
		
		public function updateActivePlayerObject(marker:FLARMarker, stageWidth:int = 0, stageHeight:int = 0):void {
			var papervision:GamePapervision = this._registry.getEntry("papervision");
			var map:GameMap = this._registry.getEntry("gameMap");
			
			var rhd:RenderHitData = papervision.viewport.hitTestPointObject(new Point(marker.centerpoint.x-(stageWidth/2), marker.centerpoint.y-(stageHeight/2)), this._grid.container);
			if (rhd.hasHit) {
				var u:Number = rhd.u;
				var v:Number = rhd.v;
				
				/* Reverse V to take reversed Y coordinates into concideration */ 
				var gridRef:Point = this._grid.coordToGridReference(u*this._grid.width, (v*-1+1)*this._grid.height);
				var coord:Point = this._grid.gridReferenceToWorldCoord(gridRef.x, gridRef.y);
				
				this._playerObjects[this._activePlayerObjectId].x = coord.x;
				this._playerObjects[this._activePlayerObjectId].y = coord.y;
				
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
			var directionIndex:int = this._directionObjects.length;
			var directionObject:GameDirectionObject;
			var levelIndex:int = this._levelObjects.length;
			var levelObject:GameLevelObject;
			
			/* Character is inside grid boundary by working out next grid segment based on character direction */
			var rotation:int = this._character.container.rotationZ;
			var nextSegGrid:Point = new Point(characterGridRef.x, characterGridRef.y);
			
			/* Distance in grid ref coords to next grid segment */ 
			var nextSegDistanceX:int = 0;
			var nextSegDistanceY:int = 0;

			switch (rotation) {
				case 0: // Up
					nextSegGrid.y += 1;
					nextSegDistanceY = 1;
					break;
				case -90: // Right
					nextSegGrid.x += 1;
					nextSegDistanceX = 1;
					break;
				case -180: // Down
				case 180:
					nextSegGrid.y -= 1;
					nextSegDistanceY = -1;
					break;
				case 90: // Left
					nextSegGrid.x -= 1;
					nextSegDistanceX = -1;
					break;
			}
			
			/* Character is within grid boundary */
			
			/* Loop through all direction objects */
			while (directionIndex--) {
				/* Reference to current direction object */
				directionObject = this._directionObjects[directionIndex];
				
				/* Grid reference of level object */
				var directionObjectGridRef:Point = this._grid.worldCoordToGridReference(directionObject.x, directionObject.y);
				
				/* Distance in grid segments between character and level object */
				var directionObjectDistanceSegmentsX:int = directionObjectGridRef.x-characterGridRef.x;
				var directionObjectDistanceSegmentsY:int = directionObjectGridRef.y-characterGridRef.y;
				
				/* Distance in coords between character and level object */
				var directionObjectDistanceCoordX:int = directionObjectGridRef.x-this._character.container.x;
				var directionObjectDistanceCoordY:int = directionObjectGridRef.y-this._character.container.y;
				
				/* Object is in the same segment as character */
				if (directionObjectDistanceSegmentsY === 0 && directionObjectDistanceSegmentsX === 0) {
					this._character.container.rotationZ = directionObject.rotationZ;
				}
			}
				
			if (!this._grid.gridRefIsOutsideBoundary(nextSegGrid.x, nextSegGrid.y)) {
				/* Loop through all level objects */
				while (levelIndex--) {
					/* Reference to current level object */
					levelObject = this._levelObjects[levelIndex];
					
					/* Grid reference of level object */
					var levelObjectGridRef:Point = this._grid.worldCoordToGridReference(levelObject.x, levelObject.y);
					
					/* Distance in grid segments between character and level object */
					var levelObjectDistanceSegmentsX:int = levelObjectGridRef.x-characterGridRef.x;
					var levelObjectDistanceSegmentsY:int = levelObjectGridRef.y-characterGridRef.y;
					
					/* Distance in coords between character and level object */
					var levelObjectDistanceCoordX:int = levelObjectGridRef.x-this._character.container.x;
					var levelObjectDistanceCoordY:int = levelObjectGridRef.y-this._character.container.y;
					
					/* Object is in the next segment in front of character */
					if (levelObjectDistanceSegmentsY == nextSegDistanceY && levelObjectDistanceSegmentsX == nextSegDistanceX) {
						var solid:Boolean = levelObject.getAttribute("solid");
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
		
		public function getTotalDirectionObjects():int {
			return this._directionObjects.length;
		}
		
		public function getTotalPlayerObjects():int {
			return this._playerObjects.length;
		}
		
		/*public function objectsInUseByType(type:String):int {
			if (this._objectsInUseByType[type])
				return this._objectsInUseByType[type];
			
			return 0; 
		}*/
		
		public function set activeDirectionObjectId(id:int):void {
			this._activeDirectionObjectId = id;
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