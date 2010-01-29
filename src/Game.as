package {
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import game.GameBoard;
	import game.GamePapervision;
	
	/* Change output settings */
	[SWF(width="640", height="480", frameRate="25", backgroundColor="#000000")]
	public class Game extends Sprite {
		/* GameBoard object */
		private var board:GameBoard;
		
		/* FLARManager object */
		private var flarManager:FLARManager;
		
		/* Markers */
		private var boardPatternId:int = 3;
		private var objectPatternId:int = 1;
		private var activeMarker:FLARMarker;
		
		/* Papervision object */
		private var papervision:GamePapervision;
		
		/* Constructor method */
		public function Game() {
			/* Initialise game board */
			this.initBoard();
			
			/* Initialise augmented reality */
			this.initFLAR();
		}
		
		/* Game board initialisation */
		private function initBoard():void {
			/* Initialise game board */
			this.board = new GameBoard();
		}
		
		/* Augmented reality initialisation */
		private function initFLAR():void {
			/* Initialise FLARManager */
			this.flarManager = new FLARManager("flarConfig.xml");

			/* Event listener for when a new marker is recognised */
			flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			/* Event listener for when a marker is removed */
			flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
			
			/* Event listener for when the FLARManager object has loaded */
			flarManager.addEventListener(Event.INIT, this.onFlarManagerLoad);
		}
		
		/* Run if FLARManager object has loaded */
		private function onFlarManagerLoad(e:Event):void {
			/* Remove event listener so this method doesn't run again */
			this.flarManager.removeEventListener(Event.INIT, this.onFlarManagerLoad);
			
			/* Display webcam */
			this.addChild(Sprite(flarManager.flarSource));
			
			/* Run Papervision initialisation method */
			this.initPapervision();
		}
		
		/* Papervision initialisation method */
		private function initPapervision():void {
			/* Initialise Papervision environment */
			this.papervision = new GamePapervision(this.flarManager.cameraParams);
			
			/* Add Papervision viewport to the main stage */
			this.addChild(this.papervision.viewport);
			
			/* Add empty board containter to Papervision scene */
			this.papervision.scene.addChild(this.board.container);
			
			/* Create event listner to run a method on each frame */
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		/* Run when a new marker is recognised */
		private function onMarkerAdded(e:FLARMarkerEvent):void {
			this.addMarker(e.marker);
		}
		/* Run when a marker is removed */
		private function onMarkerRemoved(e:FLARMarkerEvent):void {
			this.removeMarker(e.marker);
		}

		/* Add a new marker to the system */
		private function addMarker(marker:FLARMarker):void {
			this.activeMarker = marker;
			
			switch (marker.patternId) {
				case boardPatternId: // Board marker
					trace("Added board marker");
					break;
				case objectPatternId: // Object marker
					trace("Added object marker");
					this.board.addObject(marker);
					break;
			}	
		}
		
		/* Remove a marker from the system */
		private function removeMarker(marker:FLARMarker):void {			
			switch (marker.patternId) {
				case boardPatternId: // Board marker
					trace("Removed board marker");
					break;
				case objectPatternId: // Object marker
					trace("Removed object marker");
					break;	
			}	
			
			this.activeMarker = null;
		}
		
		/* Method to run on every frame */
		private function onEnterFrame(e:Event):void {			
			/* Update markers */
			this.updateMarkers();
			
			/* Update board objects */
			this.board.updateObjects();
			
			/* Render the Papervision scene */
			this.papervision.render();
		}
		
		/* Update markers method */
		private function updateMarkers():void {
			if (this.activeMarker) {
				switch (this.activeMarker.patternId) {
					case boardPatternId: // Board marker
						//trace("Update board marker");
						this.board.updateBoard(this.activeMarker);
						break;
					case objectPatternId: // Object marker
						//trace("Update object marker");
						this.board.updateActiveObject(this.activeMarker);
						break;	
				}
			}
		}
	}
}