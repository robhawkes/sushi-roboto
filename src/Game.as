package {
	/*
	 * TODO: Decouple classes; end reliance on GameRegistry to pass classes around like GameLevelData
	 */
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.SoundShortcuts;
	
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import game.GameBoard;
	import game.GameInventory;
	import game.GameLevelData;
	import game.GameMap;
	import game.GamePapervision;
	import game.GameRegistry;
	import game.GameUILevel;
	import game.GameUIMain;
	
	import org.papervision3d.core.math.Matrix3D;
	
	/* Change output settings */
	[SWF(width="800", height="600", frameRate="25", backgroundColor="#000000")]
	public class Game extends Sprite {
		private var _uiSprite:Sprite;
		private var _levelSprite:Sprite;
		
		private var _mainUI:GameUIMain;
		private var _levelUI:GameUILevel;
		
		[Embed(source="resources/sounds/Game Sounds.swf", symbol="GameSoundMainLoop")]
		private var _gameSoundMainLoop:Class;
		
		private var _soundtrack:Sound;
		private var _soundtrackTransform:SoundTransform;
		private var _soundtrackChannel:SoundChannel;
		private var _soundtrackPositionWhenStopped:Number;
		
		/* GameRegistry object */
		private var _registry:GameRegistry;
		
		/* GameLevelData object */
		private var _levelData:GameLevelData;
		
		/* GameInventory object */
		private var _inventory:GameInventory;
		
		/* GameBoard object */
		private var _board:GameBoard;
		private var _play:Boolean = false; // Is game playing (true), or paused (false)
		
		/* GameMap object */
		private var _map:GameMap;
		
		/* FLARManager object */
		private var _flarManager:FLARManager;
		
		/* Markers */
		private const _boardPatternId:int = 3;
		private const _objectPatternId:int = 1;
		private const _directionPatternId:int = 0;
		private var _activeMarker:FLARMarker;
		
		/* Papervision object */
		private var _papervision:GamePapervision;
		
		/* Constructor method */
		public function Game() {
			/* Enable Tweener sound functions */
			SoundShortcuts.init();
			
			this._levelSprite = new Sprite();
			this.addChild(this._levelSprite);
			
			this._uiSprite = new Sprite();
			this.addChild(this._uiSprite);
			
			this._mainUI = new GameUIMain();
			this._uiSprite.addChild(this._mainUI.ui);
			
			this._mainUI.addEventListener("GAME_LEVEL_1", this._onClickLevel1);
			this._mainUI.addEventListener("GAME_LEVEL_2", this._onClickLevel2);
			
			/* Initialise keyboard listeners */
			this._initKeyboardListeners();
		}
		
		private function _onClickLevel1(e:Event):void {
			this._initLevel(1);
		}
		
		private function _onClickLevel2(e:Event):void {
			this._initLevel(2);
		}
		
		private function _initLevel(levelId:int):void {
			/* Initialise game registry */
			this._registry = GameRegistry.getInstance();
			
			/* Initialise current level data */
			this._initLevelData(levelId);	
			
			/* Initialise game inventory system */
			this._initInventory();
			
			/* Initialise game board */
			this._initBoard();
			
			/* Initialise augmented reality */
			if (!this._flarManager) {
				this._initFLAR();
				
				/* Seriously messy code duplication from onFlarManagerInit */
			} else {
				/* Display webcam */
				this._levelSprite.addChild(Sprite(this._flarManager.flarSource));
				
				this._levelSprite.removeChild(this._papervision.viewport);
				this._papervision.resetViewport();
				this._levelSprite.addChild(this._papervision.viewport);
				
				this._papervision.addChildToScene(this._board.container);
				
				/* Initialise board viewport layers */
				this._board.initViewportLayers();
				
				this._mainUI.hide();
				
				this._enableMarkerEvents();
			}
			
			//var soundtrack:GameSoundMainLoop = new GameSound(new URLRequest("resources/sounds/Main Loop.mp3"));
			this._soundtrack = new this._gameSoundMainLoop();
			this._soundtrackTransform = new SoundTransform(0);
			this._soundtrackChannel = this._soundtrack.play(0, 999, this._soundtrackTransform);
			
			Tweener.addTween(this._soundtrackChannel, {_sound_volume: 1, time: 4, transition: "linear"});
		}
		
		/* Game level data initialisation */
		private function _initLevelData(levelId:int):void {
			this._levelData = new GameLevelData(levelId);
			this._registry.setEntry("levelData", this._levelData);
		}
		
		/* Game map initialisation */
		private function _initMap():void {
			this._map = new GameMap();
			
			if (this._levelData)
				this._map.drawGrid(this._levelData.rows, this._levelData.columns);
			
			this._levelSprite.addChild(this._map);
			this._registry.setEntry("gameMap", this._map);
		}
		
		/* Game inventory initialisation */
		private function _initInventory():void {
			this._inventory = new GameInventory();
		}
		
		/* Game board initialisation */
		private function _initBoard():void {
			this._board = new GameBoard();
		}
		
		/* Augmented reality initialisation */
		private function _initFLAR():void {
			/* Initialise FLARManager */
			this._flarManager = new FLARManager("flarConfig.xml");
			
			/* Event listener for when the FLARManager object has loaded */
			this._flarManager.addEventListener(Event.INIT, this._onFlarManagerLoad);
		}
		
		private function _enableMarkerEvents():void {
			/* Event listener for when a new marker is recognised */
			this._flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this._onMarkerAdded);
			/* Event listener for when a marker is removed */
			this._flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this._onMarkerRemoved);
		}
		
		private function _disableMarkerEvents():void {
			/* Event listener for when a new marker is recognised */
			this._flarManager.removeEventListener(FLARMarkerEvent.MARKER_ADDED, this._onMarkerAdded);
			/* Event listener for when a marker is removed */
			this._flarManager.removeEventListener(FLARMarkerEvent.MARKER_REMOVED, this._onMarkerRemoved);
		}
		
		/* Papervision initialisation method */
		private function _initPapervision():void {
			/* Initialise Papervision environment */
			this._papervision = new GamePapervision();
			this._papervision.setFLARCamera(this._flarManager.cameraParams);
			
			/* Add Papervision viewport to the main stage */
			this._levelSprite.addChild(this._papervision.viewport);
			
			/* Add empty board containter to Papervision scene */
			this._papervision.addChildToScene(this._board.container);
			
			/* Add Papervision object to registry */
			this._registry.setEntry("papervision", this._papervision);
			
			/* Initialise game level UI */
			this._initLevelUI();
		}
		
		/* Level UI */
		private function _initLevelUI():void {
			this._levelUI = new GameUILevel(stage.stageWidth, stage.stageHeight);
			this._uiSprite.addChild(this._levelUI.ui);
			
			this._levelUI.addEventListener("GAME_RESET", this._onClickMenuReset);
			this._levelUI.addEventListener("GAME_MENU", this._onClickMenuMenu);
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
			this._levelSprite.addChild(Sprite(this._flarManager.flarSource));
			
			/* Run Papervision initialisation method */
			this._initPapervision();
			
			/* Initialise board viewport layers */
			this._board.initViewportLayers();
			
			this._mainUI.hide();
			
			this._enableMarkerEvents();
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
					if (!this._map || this._map == null) {
						/* Initialise game map */
						this._initMap();
						
						this._board.populateBoard();
						
						this.addEventListener(Event.ENTER_FRAME, this._onEnterFrame);
					}
					break;
				case _objectPatternId: // Player object marker
					trace("Added player object marker");
					/*var selectedItemName:String = this._inventory.getSelectedItem();
					if (selectedItemName) {
						if (this._board.objectsRemainingByType(selectedItemName) > 0) {
							this._board.addDebugObject();
						} else {
							trace("No more "+selectedItemName+" objects left in invetory")
						}
					}*/
					break;
				case _directionPatternId: // Direction marker
					trace("Added direction marker");
					/*if (this._board.getObjectsInUseByName("direction") < 1) {
						this._board.addDirectionObject();
					}*/
					break;
			}	
		}
		
		/* Remove a marker from the system */
		private function _removeMarker(marker:FLARMarker):void {			
			switch (marker.patternId) {
				case _boardPatternId: // Board marker
					trace("Removed board marker");
					break;
				case _objectPatternId: // Player object marker
					trace("Removed player object marker");
					break;
				case _directionPatternId: // Direction marker
					trace("Removed direction marker");
					break;
			}	
			
			if (this._map)
				this._map.removeMarker();
			
			this._activeMarker = null;
		}
		
		/* Method to run on every frame */
		private function _onEnterFrame(e:Event):void {			
			/* Update markers */
			this._updateMarkers();
			
			/* Game is playing and character is alive */
			if (this._play && this._board.character.alive) {
				if (this._board.completed) {
					trace("You win!");
					this._play = false;
					
					/* Show win scenario UI */
				} else {				
					/* Update board objects */
					this._board.updateObjects();
				}
			} else if (this._play && !this._board.character.alive) {
				trace("Character is dead");
				this._play = false;
				
				/* Show lose scenario UI */
			}
			
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
					case _objectPatternId: // Player object marker
						//trace("Update player object marker");
						if (this._board.getTotalPlayerObjects() > 0 && !this._play) { 
							this._board.updateActivePlayerObject(this._activeMarker, this.stage.stageWidth, this.stage.stageHeight);
						}
						break;
					case _directionPatternId: // Direction marker
						//trace("Update direction marker");
						if (this._board.getTotalDirectionObjects() > 0 && this._board.activeDirectionObjectId >= 0 && !this._play) {
							this._board.updateActiveDirectionObject(this._activeMarker, this.stage.stageWidth, this.stage.stageHeight);
						}
						break;
				}
			}
		}
		
		private function _onClickMenuReset(e:Event):void {
			this._levelUI.hide();
			
			this._enableMarkerEvents();
			
			this._levelUI.addEventListener("GAME_UI_CLOSED", this._resetGame);
		}
		
		private function _onClickMenuMenu(e:Event):void {
			this._levelUI.hide();
			
			this._papervision.removeChildFromScene(this._board.container);
			this._levelSprite.removeChild(this._papervision.viewport);
			this._papervision.resetViewport();
			
			this.removeChild(this._levelSprite);
			this._levelSprite = new Sprite();
			this.addChildAt(this._levelSprite, 0);
			
			this._levelSprite.addChild(this._papervision.viewport);
			
			this._play = false;
			this._board = null;
			this._levelData = null;
			this._map = null;
			this._registry = null;
			
			this._mainUI.show();
		}
		
		private function _resetGame(e:Event = null):void {
			this._levelUI.removeEventListener("GAME_UI_CLOSED", this._resetGame);
				
			this._play = false;
			
			var previousBoardTransform:Matrix3D = this._board.container.transform;
			this._papervision.removeChildFromScene(this._board.container);
			
			this._levelSprite.removeChild(this._papervision.viewport);
			this._papervision.resetViewport();
			this._levelSprite.addChild(this._papervision.viewport);
			
			this._initBoard();
			this._board.container.transform = previousBoardTransform;
			this._papervision.addChildToScene(this._board.container);
			
			this._board.initViewportLayers();
			this._board.populateBoard();
			
			if (!this.hasEventListener(Event.ENTER_FRAME))
				this.addEventListener(Event.ENTER_FRAME, this._onEnterFrame);
		}
		
		private function _pauseGame():void {
			this._disableMarkerEvents();
			this.removeEventListener(Event.ENTER_FRAME, this._onEnterFrame);
			this._soundtrackPositionWhenStopped = this._soundtrackChannel.position;
			this._soundtrackChannel.stop();
		}
		
		private function _continueGame():void {
			this._enableMarkerEvents();
			this.addEventListener(Event.ENTER_FRAME, this._onEnterFrame);
			this._soundtrackChannel = this._soundtrack.play(this._soundtrackPositionWhenStopped, 1);
			this._soundtrackChannel.addEventListener(Event.SOUND_COMPLETE, this._restartSoundLoop);
		}
		
		private function _restartSoundLoop(e:Event):void {
			this._soundtrackChannel.removeEventListener(Event.SOUND_COMPLETE, this._restartSoundLoop);
			this._soundtrackChannel = this._soundtrack.play(0, 999);
		}
		
		/* Keyboard listeners */
		private function _onKeyDown(e:KeyboardEvent):void {
			//trace(e.keyCode);
			switch (e.keyCode) {
				case 32: // Spacebar
					if (!this._play) {
						this._play = true;
					} else {
						this._play = false;
					}
					break;
				case 38: // Up arrow
					trace("Forward");
					this._board.character.container.rotationZ = 0;
					break;
				case 40: // Down arrow
					trace("Backward");
					this._board.character.container.rotationZ = 180;
					break;
				case 37: // Left arrow
					trace("Left");
					this._board.character.container.rotationZ = 90;
					break;
				case 39: // Right arrow
					trace("Right");
					this._board.character.container.rotationZ = -90;
					break;
				case 68: // d
					/* Add new directional object */
					if (this._board.objectsRemainingByType("direction") > 0) {
						this._board.addDirectionObject();
					} else {
						trace("No more directional objects left in invetory")
					}
					break;
				case 71: // g
					if (!this._levelUI.ui.visible) {
						this._pauseGame();
						this._levelUI.show();
					} else {
						this._continueGame();
						this._levelUI.hide();
					}
					break;
				case 72: // h
					this._mainUI.hide();
					break;
				case 79: // o
					/* Add new wok object */
					if (this._board.objectsRemainingByType("wok") > 0) {
						this._board.addPlayerWokObject();
					} else {
						trace("No more wok objects left in invetory")
					}
					break;
				case 82: // r
					if (!this._map) {
						/* Initialise game map */
						this._initMap();
						
						this._board.populateBoard();
						
						this.addEventListener(Event.ENTER_FRAME, this._onEnterFrame);
					}
					break;
				case 83: // s
					if (!this._map || this._map == null) {
						/* Initialise game map */
						this._initMap();
						
						this._board.populateBoard();
						
						this.addEventListener(Event.ENTER_FRAME, this._onEnterFrame);
					}
					break;
				case 87: // w
					/* Add new water object */
					if (this._board.objectsRemainingByType("water") > 0) {
						this._board.addPlayerWaterObject();
					} else {
						trace("No more water objects left in invetory")
					}
					break;
			}
		}
	}
}