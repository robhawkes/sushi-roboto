/*
 * TODO: Combine updateActiveDirectionalObject() and updateActivePlayerObjet() methods as they have similar functionality
 */
package game {
	import caurina.transitions.Tweener;
	
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.utils.geom.FLARPVGeomUtils;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import org.papervision3d.core.effects.BitmapFireEffect;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.render.data.RenderHitData;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.view.layer.BitmapEffectLayer;
	import org.papervision3d.view.layer.ViewportLayer;
	import org.papervision3d.view.layer.util.ViewportLayerSortMode;

	public class GameBoard {
		private var _activeDirectionObjectId:int = -1;
		private var _activeLevelObjectId:int = -1;
		private var _activePlayerObjectId:int = -1;
		private var _bfxFire:BitmapEffectLayer;
		private var _boardViewportLayer:ViewportLayer;
		private var _character:GameCharacter;
		private var _completed:Boolean;
		private var _container:DisplayObject3D;
		private var _directionObjects:Vector.<GameDirectionObject>;
		private var _grid:GameGrid;
		private var _inventory:GameInventory;
		private var _levelData:GameLevelData;
		private var _levelObjects:Vector.<GameLevelObject>;
		private var _objectsInUseByType:Array;
		private var _objectViewportLayer:ViewportLayer;
		private var _objectViewportLayerBottom:ViewportLayer;
		private var _objectViewportLayerTop:ViewportLayer;
		private var _playerObjects:Vector.<GamePlayerObject>;
		private var _registry:GameRegistry; 
		private var _savedState:Object;
		private var _subtitleSprite:Sprite;
		
		/* Subtitles assets */
		[Embed(source="assets/subtitles/level1_setup.swf")]
		private var _subtitleLevel1Setup:Class;
		[Embed(source="assets/subtitles/level1_firstDirectionMarker.swf")]
		private var _subtitleLevel1FirstDirectionMarker:Class;
		
		[Embed(source="assets/subtitles/level2_setup.swf")]
		private var _subtitleLevel2Setup:Class;
		
		[Embed(source="assets/subtitles/death_fire.swf")]
		private var _subtitleDeathFire:Class;
		[Embed(source="assets/subtitles/death_water.swf")]
		private var _subtitleDeathWater:Class;
		[Embed(source="assets/subtitles/death_wasabi.swf")]
		private var _subtitleDeathWasabi:Class;
		[Embed(source="assets/subtitles/death_solid.swf")]
		private var _subtitleDeathSolid:Class;
		[Embed(source="assets/subtitles/death_boundary.swf")]
		private var _subtitleDeathBoundary:Class;
		
		[Embed(source="assets/subtitles/marker_water.swf")]
		private var _subtitleMarkerWater:Class;
		[Embed(source="assets/subtitles/marker_wok.swf")]
		private var _subtitleMarkerWok:Class;
		
		public function GameBoard() {
			this._registry = GameRegistry.getInstance();
			
			this._container = new DisplayObject3D();
			
			/* Debug settings to show board on load */
			this._container.x = 0;
			this._container.y = 0;
			this._container.z = 400;
			this._container.rotationX = -135;
			this._container.pitch(180);
			
			this._levelObjects = new Vector.<GameLevelObject>();
			this._directionObjects = new Vector.<GameDirectionObject>();
			this._playerObjects = new Vector.<GamePlayerObject>();
			
			this._objectsInUseByType = new Array();
			
			this._levelData = this._registry.getEntry("levelData");
			if (this._levelData)
				this._grid = new GameGrid(this._levelData.width, this._levelData.height, this._levelData.rows, this._levelData.columns);
			
			this._subtitleSprite = new Sprite();
		}
		
		public function initViewportLayers():void {
			var papervision:GamePapervision = this._registry.getEntry("papervision");
			if (papervision) {
				trace("Setting up viewport layers");
				
				this._boardViewportLayer = papervision.viewport.getChildLayer(this._grid.container, true);
				this._boardViewportLayer.sortMode = ViewportLayerSortMode.INDEX_SORT;
				
				this._objectViewportLayerBottom = new ViewportLayer(papervision.viewport, null);
				this._boardViewportLayer.addLayer(this._objectViewportLayerBottom);
				/* Mask out green areas (walls of pits etc) http://saqoosha.net/en/2009/01/08/1676/ */
				this._objectViewportLayerBottom.filters = [
					new ColorMatrixFilter([
						1, 0, 0, 0, 0,
						0, 1, 0, 0, 0,
						0, 0, 1, 0, 0,
						1, -1, 1, 1, 0
					])
				];

				this._objectViewportLayer = new ViewportLayer(papervision.viewport, null);
				this._objectViewportLayer.alpha = 0.8;
				this._boardViewportLayer.addLayer(this._objectViewportLayer);
				
				this._objectViewportLayerTop = new ViewportLayer(papervision.viewport, null);
				this._boardViewportLayer.addLayer(this._objectViewportLayerTop);
				
				/* Enable double click mouse events */
				this._objectViewportLayer.doubleClickEnabled = true;
				
				this._bfxFire = new BitmapEffectLayer(papervision.viewport, 800, 600);
				var fire:BitmapFireEffect = new BitmapFireEffect();
				fire.fadeRate = 0.1;
				fire.flameSpread = 1;
				fire.flameHeight = 0.5;
				fire.distortion = 0.5;
				fire.distortionScale = 1;
				fire.smoke = 0.4;
				this._bfxFire.addEffect(fire);

				this._boardViewportLayer.addLayer(this._bfxFire);
				
				this._objectViewportLayerBottom.layerIndex = 0;
				this._objectViewportLayer.layerIndex = 2;
				this._bfxFire.layerIndex = 1;
			}
		}
		
		public function populateBoard():void {
			/* Add grid 3D object to board */
			this._container.addChild(this._grid.container);
			this._grid.container.scale = 0;
			Tweener.addTween(this._grid.container, {scale: 1, time: 0.3, delay: 0.5, transition: "easeOutBack"})
			
			/* Add character to board */
			this._character = new GameCharacter();
			this._addCharacter();
			
			/* Add level objects to board */
			this._addLevelObjects();
			
			/* Add environment objects */
			this._addEnvironmentObjects();
			
			/* Level setup subtitle */
			var subtitleId:int;
			switch (this._levelData.levelId) {
				case 1: // Level 1
					subtitleId = 0;
					break;
				case 2: // Level 2
					subtitleId = 2;
					break;
			}
			if (subtitleId >= 0) {
				this._showSubtitle(subtitleId);
			}
		}
		
		private function _addColladaToViewportLayer(e:Event):void {
			var collada:DAE = e.target as DAE;
			var object:GameObject = collada.parent as GameObject;
			
			this._objectViewportLayer.addDisplayObject3D(object, true);
			this._container.addChild(object);
			object.scale = 1;
			object.z = 0;
		}
		
		private function _addColladaToViewportLayerTop(e:Event):void {
			var collada:DAE = e.target as DAE;
			var object:GameObject = collada.parent as GameObject;
			
			this._objectViewportLayerTop.addDisplayObject3D(object, true);
			this._container.addChild(object);
			object.scale = 1;
			object.z = 0;
		}
		
		private function _addCharacter():void {
			var characterPosition:Point = this._grid.gridReferenceToWorldCoord(1, 0);
			this._character.moveToPoint(characterPosition.x, characterPosition.y);
			
			this._character.container.scale = 0;
			var previousRotationZ:int = this._character.container.rotationZ;
			this._character.container.rotationZ = -1440;
			
			Tweener.addTween(this._character.container, {scale: 1, rotationZ: 0, time: 3, delay: 1, transition: "easeInOutExpo"});
			
			this._character.container.collada.addEventListener(FileLoadEvent.LOAD_COMPLETE, this._addColladaToViewportLayer);
		}
		
		private function _addEnvironmentObjects():void {
			for each (var envObjectItem:Object in this._levelData.environmentObjects) {
				var envObject:GameEnvironmentObject;
				var orientation:String;
				
				switch (envObjectItem.type) {
					case "chopsticks":
						if (envObjectItem.orientation) {
							orientation = envObjectItem.orientation;
						}
						envObject = new GameEnvironmentChopsticksObject(orientation);
						break;
					case "plate":
						if (envObjectItem.orientation) {
							orientation = envObjectItem.orientation;
						}
						envObject = new GameEnvironmentPlateObject();
						break;
					case "sink":
						if (envObjectItem.size) {
							var size:Point = envObjectItem.size;	
						}
						envObject = new GameEnvironmentSinkObject(size);
						break;
					case "tap":
						if (envObjectItem.orientation) {
							orientation = envObjectItem.orientation;
						}
						envObject = new GameEnvironmentTapObject(orientation);
						break;
					default:
						trace("There are no objects of type "+envObjectItem.type);
						break;
				}
				
				if (envObject) {
					var coord:Point = this._grid.gridReferenceToWorldCoord(envObjectItem.position.x, envObjectItem.position.y);
					
					envObject.x = coord.x;
					envObject.y = coord.y;
					
					if (envObjectItem.size) {
						envObject.x += ((envObjectItem.size.x/2)-0.5)*40;
						envObject.y += ((envObjectItem.size.y/2)-0.5)*40;
					}
					
					var previousZ:int = envObject.z;
					envObject.z = -300;
					envObject.scale = 0;
					
					Tweener.addTween(envObject, {scale: 1, z: previousZ, time: 0.6, delay: 1+Math.random()*1, transition: "easeOutExpo"});
					
					/* Add object to objects viewport layer */
					switch (envObjectItem.type) {
						case "sink":
							this._objectViewportLayerBottom.addDisplayObject3D(envObject, true);
							this._container.addChild(envObject);
							break;
						case "chopsticks":
						case "plate":
						case "tap":
							envObject.collada.addEventListener(FileLoadEvent.LOAD_COMPLETE, this._addColladaToViewportLayer);
							break;
						default:
							this._objectViewportLayer.addDisplayObject3D(envObject, true);
							this._container.addChild(envObject);
					}
				}
			}
		}
		
		private function _addLevelObjects():void {
			for each (var levelObjectItem:Object in this._levelData.levelObjects) {
				//trace("Place "+levelObjectItem.type+" at "+levelObjectItem.position);
				var levelObject:GameLevelObject;
				var texture:String;
				var orientation:String
				
				switch (levelObjectItem.type) {
					case "conveyor":
						if (levelObjectItem.orientation) {
							orientation = levelObjectItem.orientation;
							levelObject = new GameLevelConveyorObject(orientation);
						} else {
							levelObject = new GameLevelConveyorObject();
						}
						break;
					case "finish":
						if (levelObjectItem.orientation) {
							orientation = levelObjectItem.orientation;
							levelObject = new GameLevelFinishObject(orientation);
						} else {
							levelObject = new GameLevelFinishObject();
						}
						break;
					case "fire":
						levelObject = new GameLevelFireObject();	
						break;
					case "start":
						levelObject = new GameLevelStartObject();
						break;
					case "wall":
						var invisible:Boolean = false;
						if (levelObjectItem.invisible) {
							invisible = levelObjectItem.invisible;
						}
						levelObject = new GameLevelWallObject(invisible);
						break;
					case "wasabi":
						texture = "single";
						if (levelObjectItem.texture) {
							texture = levelObjectItem.texture;
						}
						levelObject = new GameLevelWasabiObject(texture);
						break;
					case "dough":
						texture = "single";
						if (levelObjectItem.texture) {
							texture = levelObjectItem.texture;
						}
						levelObject = new GameLevelDoughObject(texture);
						break;
					case "soy":
						texture = "single";
						if (levelObjectItem.texture) {
							texture = levelObjectItem.texture;
						}
						levelObject = new GameLevelSoyObject(texture);
						break;
					case "water":
						levelObject = new GameLevelWaterObject();
						break;
					default:
						trace("There are no objects of type "+levelObjectItem.type);
						break;
				}
				
				if (levelObject) {
					var coord:Point = this._grid.gridReferenceToWorldCoord(levelObjectItem.position.x, levelObjectItem.position.y);
										
					levelObject.x = coord.x;
					levelObject.y = coord.y;
					
					var previousZ:int = levelObject.z;
					levelObject.z = -300;
					levelObject.scale = 0;
					
					Tweener.addTween(levelObject, {scale: 1, z: previousZ, time: 0.6, delay: 1+Math.random()*2, transition: "easeOutExpo"});
					
					/* Add object to objects viewport layer */
					this._objectViewportLayer.addDisplayObject3D(levelObject, true);
					
					this._levelObjects.push(levelObject);
					this._container.addChild(levelObject);
					
					//this._bfx.addEffect(new BitmapLayerEffect(new DropShadowFilter(25, 90, 0, 0.25, 8, 8, 0.5, 1)));
					if (levelObjectItem.type == "fire") {
						this._bfxFire.addDisplayObject3D(levelObject, true);
					}
					
					levelObject.playAmbientSound();
				}
			}
		}
		
		private function removeLevelObject(levelObjectId:int):void {	
			if (levelObjectId == this._activeLevelObjectId)
				this._activeLevelObjectId = -1;
			
			var object:GameLevelObject = this._levelObjects[levelObjectId];
			
			/* Decrease number of direction objects in use */
			if (this._objectsInUseByType[object.type]) {
				this._objectsInUseByType[object.type] -= 1;
			} else {
				this._objectsInUseByType[object.type] = 0;
			}
			
			this._levelObjects.splice(levelObjectId, 1);
			
			this._container.removeChild(object);
		}
		
		public function addDirectionObject(x:int = 0, y:int = 0, z:int = 0, rotationX:int = 0, rotationY:int = 0, rotationZ:int = 0):void {
			/* Add new directional object */
			if (this.objectsRemainingByType("direction") > 0) {
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
					
					object.interactiveObject.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, this._onClickDirectionalObject);
					object.interactiveObject.addEventListener(InteractiveScene3DEvent.OBJECT_DOUBLE_CLICK, this._onDoubleClickDirectionalObject);
				
					this._container.addChild(object);
					
					if (this._objectsInUseByType[object.type] == 1) {
						this._showSubtitle(1);
					}
				}
			}
		}
		
		private function _onClickDirectionalObject(e:InteractiveScene3DEvent):void {
			var directionObjectId:int = this._directionObjects.indexOf(e.displayObject3D.parent);
			this._activeDirectionObjectId = directionObjectId;
			
			trace("Clicked directional object "+directionObjectId);
		}
		
		private function _onDoubleClickDirectionalObject(e:InteractiveScene3DEvent):void {
			var directionObjectId:int = this._directionObjects.indexOf(e.displayObject3D.parent);
			this.removeDirectionObject(directionObjectId);
			
			trace("Double clicked directional object "+directionObjectId);
		}
		
		public function removeDirectionObject(directionObjectId:int):void {
			if (directionObjectId == this._activeDirectionObjectId)
				this._activeDirectionObjectId = -1;
			
			var object:GameObject = this._directionObjects[directionObjectId];
			
			/* Decrease number of direction objects in use */
			if (this._objectsInUseByType[object.type]) {
				this._objectsInUseByType[object.type] -= 1;
			} else {
				this._objectsInUseByType[object.type] = 0;
			}
			
			this._directionObjects.splice(directionObjectId, 1);
			
			this._container.removeChild(object);
		}
		
		public function addPlayerObjectByType(object:String):void {
			if (this.objectsRemainingByType(object) > 0) {
				switch (object) {
					case "water":
						this.addPlayerWaterObject();
						break;
					case "wok":
						this.addPlayerWokObject();
						break;
				}
			}
		}
		
		public function addPlayerWaterObject(x:int = 0, y:int = 0, z:int = 0, rotationX:int = 0, rotationY:int = 0, rotationZ:int = 0):void {
			if (this._levelData.getObjectInventory("water") > 0) {
				var object:GamePlayerWaterObject = new GamePlayerWaterObject();
				object.x = x;
				object.y = y;
				object.rotationX = rotationX;
				object.rotationY = rotationY;
				object.rotationZ = rotationZ;
				
				/* Add object to objects viewport layer */
				this._objectViewportLayer.addDisplayObject3D(object, true);
				
				/* Add object to list and set _activeObjectId to object position in list */
				this._activePlayerObjectId = this._playerObjects.push(object)-1;
				
				/* Increase number of direction objects in use */
				if (this._objectsInUseByType[object.type]) {
					this._objectsInUseByType[object.type] += 1;
				} else {
					this._objectsInUseByType[object.type] = 1;
				}
				
				object.interactiveObject.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, this._onClickPlayerObject);
				object.interactiveObject.addEventListener(InteractiveScene3DEvent.OBJECT_DOUBLE_CLICK, this._onDoubleClickPlayerObject);
				
				this._container.addChild(object);
				
				this._showSubtitle(7);
			} else {
				trace("No water objects left");
			}
		}
		
		public function addPlayerWokObject(x:int = 0, y:int = 0, z:int = 0, rotationX:int = 0, rotationY:int = 0, rotationZ:int = 0):void {
			if (this._levelData.getObjectInventory("wok") > 0) {
				var object:GamePlayerWokObject = new GamePlayerWokObject();
				object.x = x;
				object.y = y;
				object.rotationX = rotationX;
				object.rotationY = rotationY;
				object.rotationZ = rotationZ;
				
				/* Add object to list and set _activeObjectId to object position in list */
				this._activePlayerObjectId = this._playerObjects.push(object)-1;
				
				/* Increase number of direction objects in use */
				if (this._objectsInUseByType[object.type]) {
					this._objectsInUseByType[object.type] += 1;
				} else {
					this._objectsInUseByType[object.type] = 1;
				}
				
				object.interactiveObject.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, this._onClickPlayerObject);
				object.interactiveObject.addEventListener(InteractiveScene3DEvent.OBJECT_DOUBLE_CLICK, this._onDoubleClickPlayerObject);
				
				object.collada.addEventListener(FileLoadEvent.LOAD_COMPLETE, this._addColladaToViewportLayer);
				
				this._showSubtitle(8);
			} else {
				trace("No wok objects left");
			}
		}
		
		private function _onClickPlayerObject(e:InteractiveScene3DEvent):void {
			var playerObjectId:int = this._playerObjects.indexOf(e.displayObject3D.parent);
			this._activePlayerObjectId = playerObjectId;
			
			trace("Clicked player object "+playerObjectId);
		}
		
		private function _onDoubleClickPlayerObject(e:InteractiveScene3DEvent):void {
			var playerObjectId:int = this._playerObjects.indexOf(e.displayObject3D.parent);
			this.removePlayerObject(playerObjectId);
			
			trace("Double clicked player object "+playerObjectId);
		}
		
		public function removePlayerObject(playerObjectId:int):void {
			if (playerObjectId == this._activePlayerObjectId)
				this._activePlayerObjectId = -1;
			
			var object:GameObject = this._playerObjects[playerObjectId];
			
			/* Decrease number of direction objects in use */
			if (this._objectsInUseByType[object.type]) {
				this._objectsInUseByType[object.type] -= 1;
			} else {
				this._objectsInUseByType[object.type] = 0;
			}
			
			this._container.removeChild(object);
		}
		
		/* Recode this method so it actually resets the board to previous state */
		public function resetBoard():void {
			this._completed = false;
			this._activeDirectionObjectId = -1;
			this._activePlayerObjectId = -1;
			
			/* Reset character */
			this._character.reset();
			this._character.container.rotationZ = 0;
			var characterPosition:Point = this._grid.gridReferenceToWorldCoord(1, 0);
			this._character.moveToPoint(characterPosition.x, characterPosition.y);
		}
		
		public function updateBoard(marker:FLARMarker):void {
			/* Transform board to new position in 3D space */
			this._container.transform = FLARPVGeomUtils.convertFLARMatrixToPVMatrix(marker.transformMatrix);
			
			/* Change X rotation to correct angle */
			this._container.pitch(180);
			
			/*
			trace("Scale: "+this._container.scale);
			trace("RotationX: "+this._container.rotationX);
			trace("RotationY: "+this._container.rotationY);
			trace("RotationZ: "+this._container.rotationZ);
			trace("X: "+this._container.x);
			trace("Y: "+this._container.y);
			trace("Z: "+this._container.z);
			*/
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
				
				if (this._directionObjects[this._activeDirectionObjectId].x != coord.x || this._directionObjects[this._activeDirectionObjectId].y != coord.y) {
					this._directionObjects[this._activeDirectionObjectId].x = coord.x;
					this._directionObjects[this._activeDirectionObjectId].y = coord.y;
					var sound:GameSound = new GameSound(new URLRequest("resources/sounds/MarkerPlacement.mp3"));
					sound.play(0, 1, new SoundTransform(0.5));
				}
				
				/* Rotation of the game board */
				var boardRotation:Number3D = Matrix3D.matrix2euler(this._container.transform);
				/* Rotation of the marker */
				var markerRotation:Number3D = Matrix3D.matrix2euler(FLARPVGeomUtils.convertFLARMatrixToPVMatrix(marker.transformMatrix));
				/* Calculated rotation for object */
				var objectRotation:Number = markerRotation.z-boardRotation.z;
				
				if (objectRotation >= -46 && objectRotation <= 45 && this._directionObjects[this._activeDirectionObjectId].rotationZ != 0) {
					//trace(0);
					this._directionObjects[this._activeDirectionObjectId].rotationZ = 0;
					playDirectionSwishSound();
				} else if (objectRotation >= 46 && objectRotation <= 135 && this._directionObjects[this._activeDirectionObjectId].rotationZ != 90) {
					//trace(90);
					this._directionObjects[this._activeDirectionObjectId].rotationZ = 90;
					playDirectionSwishSound();
				} else if ((objectRotation >= 136 && objectRotation <= 180 && this._directionObjects[this._activeDirectionObjectId].rotationZ != 180) || (objectRotation >= -180 && objectRotation <= -135 && this._directionObjects[this._activeDirectionObjectId].rotationZ != 180)) {
					//trace(180);
					this._directionObjects[this._activeDirectionObjectId].rotationZ = 180;
					playDirectionSwishSound();
				} else if (objectRotation >= -134 && objectRotation <= -45 && this._directionObjects[this._activeDirectionObjectId].rotationZ != -90) {
					//trace(-90);
					this._directionObjects[this._activeDirectionObjectId].rotationZ = -90;
					playDirectionSwishSound();
				}
				
				function playDirectionSwishSound():void {
					var swishSound:GameSound = new GameSound(new URLRequest("resources/sounds/objects/direction/direction_turn.mp3"));
					swishSound.play(0, 1, new SoundTransform(1));
				}
				
				if (map)
					map.updateMarker(Math.round(u*100)/100, Math.round((v*-1+1)*100)/100);
			} else {
				if (map)
					map.removeMarker();
			}
		}
		
		public function updateActiveLevelObject(marker:FLARMarker, stageWidth:int = 0, stageHeight:int = 0):void {
			var papervision:GamePapervision = this._registry.getEntry("papervision");
			var map:GameMap = this._registry.getEntry("gameMap");
			
			var rhd:RenderHitData = papervision.viewport.hitTestPointObject(new Point(marker.centerpoint.x-(stageWidth/2), marker.centerpoint.y-(stageHeight/2)), this._grid.container);
			if (rhd.hasHit) {
				var u:Number = rhd.u;
				var v:Number = rhd.v;
				
				/* Reverse V to take reversed Y coordinates into concideration */ 
				var gridRef:Point = this._grid.coordToGridReference(u*this._grid.width, (v*-1+1)*this._grid.height);
				var coord:Point = this._grid.gridReferenceToWorldCoord(gridRef.x, gridRef.y);
				
				this._levelObjects[this._activeLevelObjectId].x = coord.x;
				this._levelObjects[this._activeLevelObjectId].y = coord.y;
				
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
				
				if (this._playerObjects[this._activePlayerObjectId].x != coord.x || this._playerObjects[this._activePlayerObjectId].y != coord.y) {
					this._playerObjects[this._activePlayerObjectId].x = coord.x;
					this._playerObjects[this._activePlayerObjectId].y = coord.y;
					var sound:GameSound = new GameSound(new URLRequest("resources/sounds/MarkerPlacement.mp3"));
					sound.play(0, 1);
				}
				
				if (map)
					map.updateMarker(Math.round(u*100)/100, Math.round((v*-1+1)*100)/100);
			} else {
				if (map)
					map.removeMarker();
			}
		}
		
		public function updateObjects():void {
			this._updateLevelObjects();
			this._updatePlayerObjects();
			
			/* Only update if character isn't moving */
			if (!this.character.moving)
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
		
		private function _updatePlayerObjects():void {
			/* Store reference to amount of objects on board */
			var i:int = this._playerObjects.length;
			var object:GamePlayerObject;
			
			/* Loop through all objects */
			while (i--) {
				/* Basic object checks and updates */
				object = this._playerObjects[i];
			}
		}
		
		private function _updateCharacter():void {
			/* Calculate next segment based on direction rather than manually */
			var characterGridRef:Point = this._grid.worldCoordToGridReference(this._character.container.x, this._character.container.y);
			var nextSegmentCoord:Point = this._grid.gridReferenceToWorldCoord(characterGridRef.x, characterGridRef.y+1);
			var nextSegmentDistance:int = nextSegmentCoord.y-this._character.container.y;
			
			/* Store reference to amount of direction objects on board */
			var directionIndex:int = this._directionObjects.length;
			var directionObject:GameDirectionObject;
			
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
					break;
				}
			}
			
			/* Reference to current character rotation and position */
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
						
			/* Character toggles */
			var killCharacter:Boolean = false;
			var keepCharacterAlive:Boolean = false;
			var moveCharacter:Boolean = true;
			
			/* Store reference to amount of level objects on board */
			var levelIndex:int = this._levelObjects.length;
			var levelObject:GameLevelObject;
			
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
				
				/* Object attributes */
				var fatal:Boolean = levelObject.getAttribute("fatal");
				var finish:Boolean = levelObject.getAttribute("finish");
				var solid:Boolean = levelObject.getAttribute("solid");
				var fluid:Boolean = levelObject.getAttribute("fluid");
				var direction:String = levelObject.getAttribute("direction");
				
				var playerObjectInFront:*;
				
				var subtitleId:int;
				
				/* Object is on the same tile as character */
				if (levelObjectDistanceSegmentsY == 0 && levelObjectDistanceSegmentsX == 0) {
					if (fatal === true) {
						killCharacter = true;
						moveCharacter = false;
					}
					
					playerObjectInFront = this._playerObjectAtGridReference(this.grid.worldCoordToGridReference(levelObject.x, levelObject.y));
					
					/* Check if fluid and water */
					if (fluid === true) {						
						/* Sink if water */
						if ((levelObject.type == "water" || levelObject.type == "wasabi") && this._character.container.z <= 0) {
							if (playerObjectInFront && playerObjectInFront.type == "wok") {
								playerObjectInFront.x += (nextSegmentDistance*nextSegDistanceX);
								playerObjectInFront.y += (nextSegmentDistance*nextSegDistanceY);
								killCharacter = false;
								moveCharacter = true;
								keepCharacterAlive = true;
								break;
							} else {
								this._character.animateDown(nextSegmentDistance);
								switch (levelObject.type) {
									case "water":
										subtitleId = 4;
										break;
									case "wasabi":
										subtitleId = 5;
										break;
								}
							}
						}
					} else if (levelObject.type == "fire") {
						if (this._character.container.z <= 0) {
							this._character.animateUp(nextSegmentDistance*2);
							subtitleId = 3;
						}
					} else if (levelObject.type == "conveyor") {
						var conveyorObject:GameLevelConveyorObject = levelObject as GameLevelConveyorObject;
						moveCharacter = false;					
						killCharacter = false;
						keepCharacterAlive = true;
						
						var coord:Point = this._grid.gridReferenceToWorldCoord(characterGridRef.x, characterGridRef.y);
						switch (conveyorObject.orientation) {
							case "top":
								coord.y += nextSegmentDistance;
								break;
							case "bottom":
								coord.y -= nextSegmentDistance;
								break;
							case "left":
								coord.x -= nextSegmentDistance;
								break;
							case "right":
								coord.x += nextSegmentDistance;
								break;
						}
						
						var directionObjectOnTile:* = this._directionObjectAtGridReference(this.grid.worldCoordToGridReference(levelObject.x, levelObject.y));
						if (directionObjectOnTile) {
							switch (directionObjectOnTile.rotationZ) {
								case 0: // Up
									coord.x = character.container.x;
									coord.y += nextSegmentDistance;
									break;
								case 180: // Down
									coord.x = character.container.x;
									coord.y -= nextSegmentDistance;
									break;
								case 90: // Left
									coord.y = character.container.y;
									coord.x -= nextSegmentDistance;
									break;
								case -90: // Right
									coord.y = character.container.y;
									coord.x += nextSegmentDistance;
									break;
							}	
						}
						
						this._character.animateToPoint(coord.x, coord.y);
					}
				/* Object is on the tile in front of character */ 
				} else if (levelObjectDistanceSegmentsY == nextSegDistanceY && levelObjectDistanceSegmentsX == nextSegDistanceX) {
					/* Check if finish line */
					if (finish === true) {
						this._completed = true;
						keepCharacterAlive = true;
						this._character.animateForward(nextSegmentDistance);
						break;
					}
					
					playerObjectInFront = this._playerObjectAtGridReference(this.grid.worldCoordToGridReference(levelObject.x, levelObject.y));
					if (playerObjectInFront) {
						//trace("Object is in front of character");
					}
					
					/* Check if object is solid */
					if (solid === true) {
						if (fatal === true) {
							killCharacter = true;
							moveCharacter = false;
							subtitleId = 6;
						}
					}
					
					switch (levelObject.type) {
						case "fire":
							if (playerObjectInFront && playerObjectInFront.type == "water") {
								this.removeLevelObject(this._levelObjects.indexOf(levelObject));
							}
							break;
						case "wasabi":
						case "water":
							if (playerObjectInFront && playerObjectInFront.type == "wok") {
								killCharacter = false;
								moveCharacter = true;
							}
							break;
					}
				/* Object is not on the same or next tile as character */ 
				} else {
					
				}
			}
				
			/* Character will be within grid boundary if moved */
			if (!this._grid.gridRefIsOutsideBoundary(nextSegGrid.x, nextSegGrid.y)) {
				if (moveCharacter)
					this._character.animateForward(nextSegmentDistance);
			} else {
				killCharacter = true;
				subtitleId = 9;
			}
			
			if (killCharacter && !keepCharacterAlive) {
				if (subtitleId >= 0) {
					this._showSubtitle(subtitleId);
				}
				
				this._character.alive = false;
				levelObject.playKillSound();
			}
		}
		
		private function _getObjectsInUseByType(type:String):int {
			if (this._objectsInUseByType[type])
				return this._objectsInUseByType[type];
			
			return 0;
		}
		
		public function objectsRemainingByType(type:String):int {
			if (this._levelData.getObjectInventory(type) > 0)
				return this._levelData.getObjectInventory(type)-this._getObjectsInUseByType(type);
			
			return 0;
		}
		
		public function getTotalDirectionObjects():int {
			return this._directionObjects.length;
		}
		
		public function getTotalLevelObjects():int {
			return this._levelObjects.length;
		}
		
		public function getTotalPlayerObjects():int {
			return this._playerObjects.length;
		}
		
		private function _directionObjectAtGridReference(target:Point):* {
			/* Store reference to amount of player objects on board */
			var objectIndex:int = this._directionObjects.length;
			var object:GameDirectionObject;
			var objectGridRef:Point
			
			/* Loop through all player objects */
			while (objectIndex--) {
				/* Reference to current player object */
				object = this._directionObjects[objectIndex];
				objectGridRef = this.grid.worldCoordToGridReference(object.x, object.y);
				
				if (objectGridRef.x == target.x && objectGridRef.y == target.y)
					return object;
			}
			
			return false;
		}
		
		private function _playerObjectAtGridReference(target:Point):* {
			/* Store reference to amount of player objects on board */
			var playerIndex:int = this._playerObjects.length;
			var playerObject:GamePlayerObject;
			var playerObjectGridRef:Point
			
			/* Loop through all player objects */
			while (playerIndex--) {
				/* Reference to current player object */
				playerObject = this._playerObjects[playerIndex];
				playerObjectGridRef = this.grid.worldCoordToGridReference(playerObject.x, playerObject.y);
				
				if (playerObjectGridRef.x == target.x && playerObjectGridRef.y == target.y)
					return playerObject;
			}
			
			return false;
		}
		
		private function _showSubtitle(subtitleId:int):void {
			var subtitle:MovieClip;
			
			switch (subtitleId) {
				case 0: // Level 1 Setup
					subtitle = new this._subtitleLevel1Setup();
					break;
				case 1: // Level 1 First Direction Marker
					subtitle = new this._subtitleLevel1FirstDirectionMarker();
					break;
				case 2: // Level 2 Setup
					subtitle = new this._subtitleLevel2Setup();
					break;
				case 3: // Death Fire
					subtitle = new this._subtitleDeathFire();
					break;
				case 4: // Death Water
					subtitle = new this._subtitleDeathWater();
					break;
				case 5: // Death Wasabi
					subtitle = new this._subtitleDeathWasabi();
					break;
				case 6: // Death Solid
					subtitle = new this._subtitleDeathSolid();
					break;
				case 7: // Marker Water
					subtitle = new this._subtitleMarkerWater();
					break;
				case 8: // Marker Wok
					subtitle = new this._subtitleMarkerWok();
					break;
				case 9: // Death Boundary
					subtitle = new this._subtitleDeathBoundary();
					break;
			}
			
			if (this._subtitleSprite.numChildren > 0) {
				this._subtitleSprite.removeChildAt(0);
			}
			
			subtitle.x =+ 10;
			subtitle.y =+ 10;
			
			this._subtitleSprite.addChild(subtitle);
			
			this._subtitleSprite.alpha = 0;
			this._subtitleSprite.visible = true;
			
			Tweener.autoOverwrite = true;
			Tweener.addTween(this._subtitleSprite, {alpha: 1, time: 1, transition: "easeInOut", onComplete: this._hideSubtitle});
		}
		
		private function _hideSubtitle():void {
			Tweener.addTween(this._subtitleSprite, {alpha: 0, visible: false, time: 1, delay: 3, transition: "easeInOut"});
		}
		
		public function set activeDirectionObjectId(id:int):void {
			this._activeDirectionObjectId = id;
		}
		
		public function get activeDirectionObjectId():int {
			return this._activeDirectionObjectId;
		}
		
		public function get character():GameCharacter {
			return this._character;
		}
		
		public function get completed():Boolean {
			return this._completed;
		}
		
		public function get container():DisplayObject3D {
			return this._container;
		}
		
		public function get grid():GameGrid {
			return this._grid;
		}
		
		public function get subtitleSprite():Sprite {
			return this._subtitleSprite;
		}
	}
}