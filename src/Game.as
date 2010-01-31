package {
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import game.GameBoard;
	import game.GameLevelData;
	import game.GameMap;
	import game.GamePapervision;
	import game.GameRegistry;
	
	/* Change output settings */
	[SWF(width="640", height="480", frameRate="25", backgroundColor="#000000")]
	public class Game extends Sprite {
		/* GameRegistry object */
		private var _registry:GameRegistry;
		
		/* GameLevelData object */
		private var _levelData:GameLevelData;
		
		/* GameBoard object */
		private var _board:GameBoard;
		
		/* GameMap object */
		private var _map:GameMap;
		
		/* FLARManager object */
		private var _flarManager:FLARManager;
		
		/* Markers */
		private const _boardPatternId:int = 3;
		private const _objectPatternId:int = 1;
		private var _activeMarker:FLARMarker;
		
		/* Papervision object */
		private var _papervision:GamePapervision;
		
		/* Constructor method */
		public function Game() {
			/* Initialise game registry */
			this._registry = GameRegistry.getInstance();
			
			/* Initialise current level data */
			this._initLevelData();	
			
			/* Initialise game board */
			this._initBoard();
			
			/* Initialise augmented reality */
			this._initFLAR();
			
			/* Initialise keyboard listeners */
			this._initKeyboardListeners();
		}
		
		/* Game level data initialisation */
		private function _initLevelData():void {
			this._levelData = new GameLevelData(0);
			this._registry.setEntry("levelData", this._levelData);
		}
		
		/* Game map initialisation */
		private function _initMap():void {
			this._map = new GameMap();
			
			if (this._levelData)
				this._map.drawGrid(this._levelData.rows, this._levelData.columns);
			
			this.addChild(this._map);
			this._registry.setEntry("gameMap", this._map);
		}
		
		/* Game board initialisation */
		private function _initBoard():void {
			this._board = new GameBoard();
		}
		
		/* Augmented reality initialisation */
		private function _initFLAR():void {
			/* Initialise FLARManager */
			this._flarManager = new FLARManager("flarConfig.xml");

			/* Event listener for when a new marker is recognised */
			this._flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this._onMarkerAdded);
			/* Event listener for when a marker is removed */
			this._flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this._onMarkerRemoved);
			
			/* Event listener for when the FLARManager object has loaded */
			this._flarManager.addEventListener(Event.INIT, this._onFlarManagerLoad);
		}
		
		/* Keyboard listeners initialisation */
		private function _initKeyboardListeners():void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, this._onKeyDown);
		}
		
		/* Run if FLARManager object has loaded */
		private function _onFlarManagerLoad(e:Event):void {
			/* Remove event listener so this method doesn't run again */
			this._flarManager.removeEventListener(Event.INIT, this._onFlarManagerLoad);
			
			/* Display webcam */
			this.addChild(Sprite(this._flarManager.flarSource));
			
			/* Run Papervision initialisation method */
			this._initPapervision();
			
			/* Initialise game map */
			this._initMap();
		}
		
		/* Papervision initialisation method */
		private function _initPapervision():void {
			/* Initialise Papervision environment */
			this._papervision = new GamePapervision();
			this._papervision.setFLARCamera(this._flarManager.cameraParams);
			
			/* Add Papervision viewport to the main stage */
			this.addChild(this._papervision.viewport);
			
			/* Add empty board containter to Papervision scene */
			this._papervision.addChildToScene(this._board.container);
			
			/* Add Papervision object to registry */
			this._registry.setEntry("papervision", this._papervision);
			
			/* Create event listner to run a method on each frame */
			this.addEventListener(Event.ENTER_FRAME, this._onEnterFrame);
		}
		
		/* Run when a new marker is recognised */
		private function _onMarkerAdded(e:FLARMarkerEvent):void {
			this._addMarker(e.marker);
		}
		/* Run when a marker is removed */
		private function _onMarkerRemoved(e:FLARMarkerEvent):void {
			this._removeMarker(e.marker);
		}

		/* Add a new marker to the system */
		private function _addMarker(marker:FLARMarker):void {
			this._activeMarker = marker;
			
			switch (marker.patternId) {
				case _boardPatternId: // Board marker
					trace("Added board marker");
					break;
				case _objectPatternId: // Object marker
					trace("Added object marker");
					this._board.addDebugObject();
					break;
			}	
		}
		
		/* Remove a marker from the system */
		private function _removeMarker(marker:FLARMarker):void {			
			switch (marker.patternId) {
				case _boardPatternId: // Board marker
					trace("Removed board marker");
					break;
				case _objectPatternId: // Object marker
					trace("Removed object marker");
					break;	
			}	
			
			this._map.removeMarker();
			this._activeMarker = null;
		}
		
		/* Method to run on every frame */
		private function _onEnterFrame(e:Event):void {			
			/* Update markers */
			this._updateMarkers();
			
			/* Update board objects */
			this._board.updateObjects();
			
			/* Render the Papervision scene */
			this._papervision.render();
		}
		
		/* Update markers method */
		private function _updateMarkers():void {
			if (this._activeMarker) {
				switch (this._activeMarker.patternId) {
					case _boardPatternId: // Board marker
						//trace("Update board marker");
						this._board.updateBoard(this._activeMarker);
						break;
					case _objectPatternId: // Object marker
						//trace("Update object marker");
						this._board.updateActiveObject(this._activeMarker, this.stage.stageWidth, this.stage.stageHeight);
						break;
				}
			}
		}
		
		/* Keyboard listeners */
		private function _onKeyDown(e:KeyboardEvent):void {
			switch (e.keyCode) {
				case 38: // Up arrow
					trace("Up");
					this._board.character.moveUp();
					break;
				case 40: // Down arrow
					trace("Down");
					this._board.character.moveDown();
					break;
				case 37: // Left arrow
					trace("Left");
					this._board.character.moveLeft();
					break;
				case 39: // Right arrow
					trace("Right");
					this._board.character.moveRight();
					break;
			}
		}
	}
}