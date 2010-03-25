package {
	/*
	 * TODO: Decouple classes; end reliance on GameRegistry to pass classes around like GameLevelData
	 */
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.SoundShortcuts;
	
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import game.GameBoard;
	import game.GameInventory;
	import game.GameLevelData;
	import game.GameMap;
	import game.GamePapervision;
	import game.GameRegistry;
	import game.GameSound;
	import game.GameUIComplete;
	import game.GameUICredits;
	import game.GameUIHelpMarker;
	import game.GameUIInventory;
	import game.GameUILevel;
	import game.GameUILevelDead;
	import game.GameUILevelWin;
	import game.GameUIMain;
	
	import org.papervision3d.core.math.Matrix3D;
	
	/* Change output settings */
	[SWF(width="800", height="600", frameRate="25", backgroundColor="#000000")]
	public class Game extends Sprite {
		private var _uiSprite:Sprite;
		private var _levelSprite:Sprite;
		private var _subtitleSprite:Sprite;
		
		[Embed(source="assets/IntroScene.swf")]
		private var _intro:Class;
		private var _introScene:MovieClip;
		private var _introFrames:int;
		private var _introSprite:Sprite;
		
		[Embed(source="assets/EndCredits.swf")]
		private var _credits:Class;
		private var _creditsSprite:Sprite;
		
		private var _mainUI:GameUIMain;
		private var _levelUI:GameUILevel;
		private var _levelUIDead:GameUILevelDead;
		private var _levelUIWin:GameUILevelWin;
		private var _levelMarkerUI:GameUIHelpMarker;
		private var _inventoryUI:GameUIInventory;
		private var _completeUI:GameUIComplete;
		private var _creditsUI:GameUICredits;
		
		[Embed(source="resources/sounds/Game Sounds.swf", symbol="GameSoundBuildMode")]
		private var _gameSoundBuildLoop:Class;
		
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
			
			this._subtitleSprite = new Sprite();
			this.addChild(this._subtitleSprite);
			
			this._creditsSprite = new Sprite();
			this.addChild(this._creditsSprite);
			
			this._uiSprite = new Sprite();
			this.addChild(this._uiSprite);
			
			this._introSprite = new Sprite();
			this.addChild(this._introSprite);
			
			/*
			this._introScene = new this._intro();
			this._introSprite.addChild(this._introScene);
			
			var introTimer:Timer = new Timer(21500, 1);
			introTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this._introComplete);
			introTimer.start();
			*/
			
			this._initMainMenu();
			
			/* Initialise keyboard listeners */
			this._initKeyboardListeners();
		}
		
		private function _introComplete(event:TimerEvent = null):void {
			this._initMainMenu();
			Tweener.addTween(this._introSprite, {alpha: 0, visible: false, time: 1, transition: "linear"});
		}
		
		private function _initMainMenu(event:Event = null):void {
			this._mainUI = new GameUIMain();
			this._uiSprite.addChild(this._mainUI.ui);
			
			this._mainUI.addEventListener("GAME_LEVEL_1", this._onClickLevel1);
			this._mainUI.addEventListener("GAME_LEVEL_2", this._onClickLevel2);
			
			this._mainUI.show();
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
			
			/* Initialise game board */
			this._initBoard();
			
			/* Initialise game inventory system */
			this._initInventory();
			
			/* Temporary procedural code limiting objects by level */
			switch (levelId) {
				case 1:
					this._inventoryUI.removeButton("wokButton");
					break;
				case 2:
					
					break;
			}
			
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

			/* Show level marker reminder */
			this._levelMarkerUI = new GameUIHelpMarker(stage.stageWidth, stage.stageHeight);
			this._uiSprite.addChild(this._levelMarkerUI.ui);
			this._levelMarkerUI.show();
			
			this._soundtrack = new this._gameSoundBuildLoop();
			this._soundtrackTransform = new SoundTransform(0.5);
			this._soundtrackChannel = this._soundtrack.play(0, 999, new SoundTransform(0));
			
			Tweener.addTween(this._soundtrackChannel, {_sound_volume: 0.5, time: 4, delay: 2, transition: "linear"});
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
			
			this._inventoryUI = new GameUIInventory(stage.stageWidth, stage.stageHeight);
			this._uiSprite.addChild(this._inventoryUI.ui);
			
			this._addInventoryEvents();
		}
		
		private function _addInventoryEvents():void {
			this._inventoryUI.addEventListener("GAME_PLAY", this._playGame);
			this._inventoryUI.addEventListener("GAME_LEVELUI_OPEN", this._toggleLevelMenu);
			this._inventoryUI.addEventListener("GAME_OBJECT_ADD_DIRECTION", this._board.addDirectionObject);
			this._inventoryUI.addEventListener("GAME_OBJECT_ADD_WATER", this._board.addPlayerWaterObject);
			this._inventoryUI.addEventListener("GAME_OBJECT_ADD_WOK", this._board.addPlayerWokObject);
		}
		
		private function _removeInventoryEvents():void {
			this._inventoryUI.removeEventListener("GAME_LEVELUI_OPEN", this._toggleLevelMenu);
			this._inventoryUI.removeEventListener("GAME_OBJECT_ADD_DIRECTION", this._board.addDirectionObject);
			this._inventoryUI.removeEventListener("GAME_OBJECT_ADD_WATER", this._board.addPlayerWaterObject);
			this._inventoryUI.removeEventListener("GAME_OBJECT_ADD_WOK", this._board.addPlayerWokObject);
		}
		
		/* Game board initialisation */
		private function _initBoard():void {
			this._board = new GameBoard();
			this._subtitleSprite.addChild(this._board.subtitleSprite);
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
			
			/* Initialise game level UI dead */
			this._initLevelUIDead();
			
			/* Initialise game level UI win */
			this._initLevelUIWin();
		}
		
		/* Level UI */
		private function _initLevelUI():void {
			this._levelUI = new GameUILevel(stage.stageWidth, stage.stageHeight);
			this._uiSprite.addChild(this._levelUI.ui);
			
			this._levelUI.addEventListener("GAME_UI_CLOSED", this._continueGame);
			this._levelUI.addEventListener("GAME_RESET", this._onClickMenuReset);
			this._levelUI.addEventListener("GAME_MENU", this._onClickMenuMenu);
		}
		
		/* Level UI Dead */
		private function _initLevelUIDead():void {
			this._levelUIDead = new GameUILevelDead(stage.stageWidth, stage.stageHeight);
			this._uiSprite.addChild(this._levelUIDead.ui);
			
			this._levelUIDead.addEventListener("GAME_RESET", this._onClickMenuReset);
			this._levelUIDead.addEventListener("GAME_MENU", this._onClickMenuMenu);
		}
		
		/* Level UI Win */
		private function _initLevelUIWin():void {
			this._levelUIWin = new GameUILevelWin(stage.stageWidth, stage.stageHeight);
			this._uiSprite.addChild(this._levelUIWin.ui);
			
			this._levelUIWin.addEventListener("GAME_NEXT_LEVEL", this._onClickMenuNextLevel);
			this._levelUIWin.addEventListener("GAME_MENU", this._onClickMenuMenu);
		}
		
		/* Credits UI */
		private function _initCreditsUI():void {
			this._creditsUI = new GameUICredits(stage.stageWidth, stage.stageHeight);
			this._uiSprite.addChild(this._creditsUI.ui);
			
			this._creditsUI.addEventListener("GAME_MENU", this._onClickMenuMenu);
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
						this._levelMarkerUI.hide();
						
						/* Initialise game map */
						this._initMap();
						
						this._board.populateBoard();
						
						this._inventoryUI.show();
						
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
					//trace("You win!");
					this._play = false;
					
					/* Show win scenario UI */
					Tweener.addTween(this._soundtrackChannel, {_sound_volume: 0.1, time: 0.5, transition: "linear"});
					
					this._disableMarkerEvents();
					this.removeEventListener(Event.ENTER_FRAME, this._onEnterFrame);
					
					this._levelUIWin.show();
				} else {				
					/* Update board objects */
					this._board.updateObjects();
				}
			} else if (this._play && !this._board.character.alive) {
				//trace("Character is dead");
				this._play = false;
				
				/* Show lose scenario UI */
				Tweener.addTween(this._soundtrackChannel, {_sound_volume: 0.1, time: 0.5, transition: "linear"});
				
				this._disableMarkerEvents();
				this.removeEventListener(Event.ENTER_FRAME, this._onEnterFrame);
				
				this._levelUIDead.show();
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
		
		private function _toggleLevelMenu(e:Event):void {
			if (!this._levelUI.ui.visible) {
				this._pauseGame();
				this._inventoryUI.hide();
				this._levelUI.show();
			} else {
				this._continueGame();
				this._levelUI.hide();
				this._inventoryUI.show();
			}
		}
		
		private function _onClickMenuNextLevel(e:Event):void {
			var levelId:int = this._levelData.levelId;
			
			this._levelUI.removeEventListener("GAME_UI_CLOSED", this._resetGame);
			this._levelUI.removeEventListener("GAME_UI_CLOSED", this._continueGame);
			
			this._levelUI.hide();
			this._levelUIDead.hide();
			this._levelUIWin.hide();
			
			SoundMixer.stopAll();
			
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
			
			var nextLevelId:int;
			switch (levelId) {
				case 1:
					nextLevelId = 2;
					this._initLevel(2);
					break;
				case 2:
					/* Load win screen and credits */
					this._completeUI = new GameUIComplete(stage.stageWidth, stage.stageHeight);
					this._uiSprite.addChild(this._completeUI.ui);
					this._completeUI.show();
					var completeSound:GameSound = new GameSound(new URLRequest("resources/sounds/Completed.mp3"));
					completeSound.play(0, 1);
					
					var creditsTimer:Timer = new Timer(4000, 1);
					creditsTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this._showCredits);
					creditsTimer.start();
					
					break;
			}
		}
		
		private function _showCredits(event:TimerEvent = null):void {
			this._levelUI.removeEventListener("GAME_UI_CLOSED", this._resetGame);
			this._levelUI.removeEventListener("GAME_UI_CLOSED", this._continueGame);
			this._levelUI.hide();
			
			this._levelUIDead.hide();
			this._levelUIWin.hide();
			this._completeUI.hide();
			
			this._disableMarkerEvents();
			this.removeEventListener(Event.ENTER_FRAME, this._onEnterFrame);
			
			SoundMixer.stopAll();
			
			this._play = false;
			this._board = null;
			this._levelData = null;
			this._map = null;
			this._registry = null;
			
			this._soundtrack = new GameSound(new URLRequest("resources/sounds/MainMenu.mp3"));
			this._soundtrackChannel = this._soundtrack.play(0, 999, this._soundtrackTransform);
			
			var credits:MovieClip = new this._credits();
			this._creditsSprite.addChild(credits);
			
			this._creditsSprite.visible = true;
			this._initCreditsUI();
		}
		
		private function _onClickMenuReset(e:Event):void {
			this._levelUI.hide();
			this._levelUIDead.hide();
			this._levelUIDead.hide();
			
			this._enableMarkerEvents();
			
			this._levelUI.addEventListener("GAME_UI_CLOSED", this._resetGame);
		}
		
		private function _onClickMenuMenu(e:Event):void {
			if (this._creditsUI) {
				this._creditsUI.hide();
				this._creditsSprite.visible = false;
			}
			
			this._levelUI.removeEventListener("GAME_UI_CLOSED", this._resetGame);
			this._levelUI.removeEventListener("GAME_UI_CLOSED", this._continueGame);
			this._levelUI.hide();
			
			this._levelUIDead.hide();
			this._levelUIWin.hide();
			
			SoundMixer.stopAll();
			
			if (this._papervision && this._board) {
				this._papervision.removeChildFromScene(this._board.container);
			}
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
			
			SoundMixer.stopAll();
				
			this._play = false;
			
			var previousBoardTransform:Matrix3D = this._board.container.transform;
			this._papervision.removeChildFromScene(this._board.container);
			
			this._levelSprite.removeChild(this._papervision.viewport);
			this._papervision.resetViewport();
			this._levelSprite.addChild(this._papervision.viewport);
			
			this._initBoard();
			this._board.container.transform = previousBoardTransform;
			this._papervision.addChildToScene(this._board.container);
			
			this._soundtrack = new this._gameSoundBuildLoop();
			this._soundtrackChannel = this._soundtrack.play(0, 999, this._soundtrackTransform);
			
			this._board.initViewportLayers();
			this._board.populateBoard();
			
			this._addInventoryEvents();
			this._inventoryUI.show();
			
			if (!this.hasEventListener(Event.ENTER_FRAME))
				this.addEventListener(Event.ENTER_FRAME, this._onEnterFrame);
		}
		
		private function _pauseGame():void {
			this._levelUI.addEventListener("GAME_UI_CLOSED", this._continueGame);
			this._disableMarkerEvents();
			this.removeEventListener(Event.ENTER_FRAME, this._onEnterFrame);
			this._soundtrackPositionWhenStopped = this._soundtrackChannel.position;
			this._soundtrackChannel.stop();
		}
		
		private function _continueGame(e:Event = null):void {
			this._levelUI.removeEventListener("GAME_UI_CLOSED", this._continueGame);
			this._enableMarkerEvents();
			this.addEventListener(Event.ENTER_FRAME, this._onEnterFrame);
			this._soundtrackChannel = this._soundtrack.play(this._soundtrackPositionWhenStopped, 1, this._soundtrackTransform);
			this._soundtrackChannel.addEventListener(Event.SOUND_COMPLETE, this._restartSoundtrack);
			this._inventoryUI.show();
		}
		
		private function _playSoundtrack():void {
			this._soundtrackChannel = this._soundtrack.play(0, 999, this._soundtrackTransform);
		}
		
		private function _stopSoundtrack():void {
			
		}
		
		private function _restartSoundtrack(e:Event):void {
			this._soundtrackChannel.removeEventListener(Event.SOUND_COMPLETE, this._restartSoundtrack);
			this._soundtrackChannel = this._soundtrack.play(0, 999, this._soundtrackTransform);
		}
		
		private function _playGame(e:Event = null):void {
			this._inventoryUI.hide();
			Tweener.addTween(this._soundtrackChannel, {_sound_volume: 0, time: 0.5, transition: "linear"});
			var playSound:GameSound = new GameSound(new URLRequest("resources/sounds/StartPlaying.mp3"));
			var playSoundChannel:SoundChannel = playSound.play(0, 1, new SoundTransform(0.5));
			playSoundChannel.addEventListener(Event.SOUND_COMPLETE, this._startPlayingGame);
		}
		
		private function _startPlayingGame(e:Event = null):void {
			this._soundtrack = new GameSound(new URLRequest("resources/sounds/PlayModeLoop.mp3"));
			this._soundtrackChannel = this._soundtrack.play(0, 999, new SoundTransform(0));
			Tweener.addTween(this._soundtrackChannel, {_sound_volume: 0.5, time: 1, delay: 0.5, transition: "linear"});
			
			this._play = true;
		}
		
		private function _stopPlayingGame(e:Event = null):void {
			this._play = false;
		}
		
		/* Keyboard listeners */
		private function _onKeyDown(e:KeyboardEvent):void {
			//trace(e.keyCode);
			switch (e.keyCode) {
				case 32: // Spacebar
					break;
				case 38: // Up arrow
					break;
				case 40: // Down arrow
					break;
				case 37: // Left arrow
					break;
				case 39: // Right arrow
					break;
				case 68: // d
					
					break;
				case 71: // g
					
					break;
				case 72: // h
					this._mainUI.hide();
					break;
				case 79: // o
					break;
				case 82: // r
					break;
				case 83: // s
					if (!this._map || this._map == null) {
						this._levelMarkerUI.hide();
						
						/* Initialise game map */
						this._initMap();
						
						this._board.populateBoard();
						
						this._inventoryUI.show();
						
						this.addEventListener(Event.ENTER_FRAME, this._onEnterFrame);
					}
					break;
				case 87: // w
					break;
			}
		}
	}
}