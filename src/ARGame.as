package {
	/* Tweener Class [http://code.google.com/p/tweener/] */
	import caurina.transitions.Tweener;
	
	import com.argame.grid.ARGameGrid;
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.utils.geom.FLARPVGeomUtils;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import org.libspark.flartoolkit.support.pv3d.FLARCamera3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.render.LazyRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	
	/* Change output settings */
	[SWF(width="640", height="480", frameRate="25", backgroundColor="#000000")]
	public class ARGame extends Sprite {
		/* FLARManager pointer */
		private var fm:FLARManager;
		/* Papervision Scene3D pointer */
		private var scene3D:Scene3D;
		/* Papervision Viewport3D pointer */
		private var viewport3D:Viewport3D;
		/* FLARToolkit FLARCamera3D pointer */ 
		private var camera3D:FLARCamera3D;
		/* Papervision render engine pointer */
		private var lre:LazyRenderEngine;
		/* Papervision PointLight3D pointer */
		private var pointLight3D:PointLight3D;
		
		/* Initialise glow filter to add a white border around selected objects in our scene */
		private var glow:GlowFilter = new GlowFilter(0xFFFFFF, 1, 7, 7, 30, 1, false, false);
		
		/* ARGame Grid pointer */
		private var grid:ARGameGrid;
		
		/* Vector storing references to all markers on screen, grouped by pattern id */
		private var markersByPatternId:Vector.<Vector.<FLARMarker>>;
		/* Dictionary storing references to marker containers, indexed by relevant marker object */
		private var containersByMarker:Dictionary;
		
		/* Dictionary storing references to the corner nodes for each marker, indexed by relevant marker object */
		private var nodesByMarker:Dictionary;
		
		/* Reference to debug output */
		private var debugOutput:TextField;
		
		/* Constructor method */
		public function ARGame() {
			/* Run augmented reality initialisation */
			this.initFLAR();
		}
		
		/* Augmented reality initialisation */
		private function initFLAR():void {
			/* Initialise FLARManager */
			this.fm = new FLARManager("flarConfig.xml");
			
			/* Temporary declaration of how many patterns are being used */ 
			var numPatterns:int = 6;
			/* Initialise markerByPatternId vector object */
			this.markersByPatternId = new Vector.<Vector.<FLARMarker>>(numPatterns, true);
			/* Loop through each pattern */
			while (numPatterns--) {
				/* Add empty Vector to each pattern */
				this.markersByPatternId[numPatterns] = new Vector.<FLARMarker>();
			}
			
			/* Initialise empty containersByMarker dictionary object */
			this.containersByMarker = new Dictionary(true);
			
			/* Initialise empty nodesByMarker dictionary object */
			this.nodesByMarker = new Dictionary(true);
			
			/* Event listener for when a new marker is recognised */
			fm.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onAdded);
			/* Event listener for when a marker is removed */
			fm.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onRemoved);
			/* Event listener for when the FLARManager object has loaded */
			fm.addEventListener(Event.INIT, this.onFlarManagerLoad);
			
			/* Display webcam */
			this.addChild(Sprite(fm.flarSource));
		}
		
		/* Run if FLARManager object has loaded */
		private function onFlarManagerLoad(e:Event):void {
			/* Remove event listener so this method doesn't run again */
			this.fm.removeEventListener(Event.INIT, this.onFlarManagerLoad);
			/* Run Papervision initialisation method */
			this.initPaperVision();
		}
		
		/* Run when a new marker is recognised */
		private function onAdded(e:FLARMarkerEvent):void {
			switch (e.marker.patternId) {
				case 3:
					/* Run method to create game grid */
					if (!this.grid) {
						this.addGrid(e.marker);
					} else {
						this.grid.marker = e.marker;
						this.grid.active = true;
					}
					break;
				default:
					/* Run method to add a new marker */
					this.addMarker(e.marker);	
			}
		}
		/* Run when a marker is removed */
		private function onRemoved(e:FLARMarkerEvent):void {
			switch (e.marker.patternId) {
				case 3:
					/* Grid marker is removed */
					this.removeGrid(e.marker);
					break;
				default:
					/* Run method to remove a marker */
					this.removeMarker(e.marker);	
			}	
		}
		
		/* Add grid to the system */
		private function addGrid(marker:FLARMarker):void {		
			/* Grid details */
			var gridWidth:int = 150;
			var gridHeight:int = 150;
			
			/* Initialise grid object */
			this.grid = new ARGameGrid(0, 0, gridWidth, gridHeight, 5, 5);
			this.grid.marker = marker;
			
			/* Initialise the grid container object */
			var container:DisplayObject3D = new DisplayObject3D();
			
			this.grid.container = container;
			
			/* Create grid */
			var segWidth:int = this.grid.width/5;
			var segHeight:int = this.grid.height/5;			
			for (var i:int = 1; i <= this.grid.segRowCount; i++) {
				for (var j:int = 1; j <= this.grid.segColCount; j++) {
					var colour:Number = Math.random()*0xFFFFFF;
					var gridSegFlatShaderMat:FlatShadeMaterial = new FlatShadeMaterial(pointLight3D, colour, colour);
					var gridSegMaterials:MaterialsList = new MaterialsList({all: gridSegFlatShaderMat});
					var gridSeg:Cube = new Cube(gridSegMaterials, segWidth, 0, segHeight);
					gridSeg.x = (j-0.5)*(this.grid.width/this.grid.segColCount)-(this.grid.width/2);
					gridSeg.y = (i-0.5)*(this.grid.height/this.grid.segRowCount)-(this.grid.height/2);
					container.addChild(gridSeg);
				}
			}
			
			/* Add grid container to the Papervision scene */
			this.scene3D.addChild(container);
		}
		
		/* Grid marker removed */
		private function removeGrid(marker:FLARMarker):void {
			this.grid.active = false;
		}

		/* Add a new marker to the system */
		private function addMarker(marker:FLARMarker):void {
			/* Store reference to list of existing markers with same pattern id */
			var markerList:Vector.<FLARMarker> = this.markersByPatternId[marker.patternId];
			/* Add new marker to the list */
			markerList.push(marker);
			
			/* Initialise the marker container object */
			var container:DisplayObject3D = new DisplayObject3D();
			
			/* Prepare material to be used by the Papervision cube based on pattern id */
			var flatShaderMat:FlatShadeMaterial = new FlatShadeMaterial(pointLight3D, getColorByPatternId(marker.patternId), getColorByPatternId(marker.patternId, true));
			/* Add material to all sides of the cube */
			var cubeMaterials:MaterialsList = new MaterialsList({all: flatShaderMat});
			
			/* Initialise the cube with material and set dimensions of all sides to 40 */
			var cube:Cube = new Cube(cubeMaterials, 20, 20, 20);
			
			/* Shift cube upwards so it sits on top of paper instead of being cut half-way */
			cube.z = 0.5 * 20;
			
			/* Scale cube to 0 so it's invisible */
			cube.scale = 0;
			/* Add animation which scales cube to full size */
			Tweener.addTween(cube, {scale: 1, time:0.5, transition:"easeInOutExpo"});
			
			/* Set cube to be individually affected by filters */
			cube.useOwnContainer = true;
			/* Add cellshaded border using glow filter */
			cube.filters = [this.glow];
			
			/* Add finished cube object to marker container */
			container.addChild(cube);
			
			/* Add marker container to the Papervision scene */
			this.scene3D.addChild(container);
			
			/* Add marker container to containersByMarker Dictionary object */
			this.containersByMarker[marker] = container;
		}
		
		/* Remove a marker from the system */
		private function removeMarker(marker:FLARMarker):void {
			/* Store reference to list of existing markers with same pattern id */
			var markerList:Vector.<FLARMarker> = this.markersByPatternId[marker.patternId];
			/* Find index value of marker to be removed */
			var markerIndex:uint = markerList.indexOf(marker);
			/* If marker exists in markerList */
			if (markerIndex != -1) {
				/* Remove marker from markersByPatternId */
				markerList.splice(markerIndex, 1);
			}
			
			/* Store reference to marker container from containersByMarker Dictionary object */
			var container:DisplayObject3D = this.containersByMarker[marker];
			/* If a container exists */
			if (container) {
				/* Remove container from the Papervision scene */
				this.scene3D.removeChild(container);
			}
			/* Remove container reference from containersByMarker Dictionary object */
			delete this.containersByMarker[marker];
			
			/* Clear any corner nodes for this marker from the display */ 
			this.nodesByMarker[marker].graphics.clear();
			/* Remove reference to corner nodes for this marker from nodesByMarker Dictionary object */
			delete this.nodesByMarker[marker];
		}
		
		/* Papervision initialisation method */
		private function initPaperVision():void {
			/* Initialise a new Papervision scene */
			this.scene3D = new Scene3D();
			/* Initialise a new FLARCamera3D object to enable full AR goodness */
			this.camera3D = new FLARCamera3D(this.fm.cameraParams);
			
			/* Define a new Papervision viewport object */
			this.viewport3D = new Viewport3D(640, 480, true);
			/* Add viewport to the main scene */
			this.addChild(this.viewport3D);
			
			/* Define a new Papervision point light */
			this.pointLight3D = new PointLight3D(true, false);
			/* Set light position */
			this.pointLight3D.x = 1000;
			this.pointLight3D.y = 1000;
			this.pointLight3D.z = -1000;
			/* Add light to the Papervision scene */
			this.scene3D.addChild(pointLight3D);
			
			/* Initialise the Papervision render engine */
			this.lre = new LazyRenderEngine(this.scene3D, this.camera3D, this.viewport3D);
			
			/* Create event listner to run a method on each frame */
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		/* Method to run on each frame */
		private function onEnterFrame(e:Event):void {
			/* Loop through corner nodes */
			for (var marker:Object in nodesByMarker) {
				/* Clear any corner nodes for this marker from the display */ 
				nodesByMarker[marker].graphics.clear();
			}
			
			/* Run method to update grid */
			this.updateGrid();
			
			/* Run method to update markers */
			this.updateMarkers();
			
			/* Update debug output */
			this.updateDebugOutput();
			
			/* Render the Papervision scene */
			this.lre.render();
		}
		
		/* Update grid method */
		private function updateGrid():void {
			if (this.grid && this.grid.active) {
				/* Update grid postion variables */
				this.grid.x = this.grid.container.x;
				this.grid.y = this.grid.container.y;
				
				/* Transform container to new position in 3d space */
				this.grid.container.transform = FLARPVGeomUtils.convertFLARMatrixToPVMatrix(this.grid.marker.transformMatrix);
			}
		}
		
		/* Update markers method */
		private function updateMarkers():void {
			/* Store reference to amount of patterns being tracked */
			var i:int = this.markersByPatternId.length;
			/* Store reference to list of existing markers */
			var markerList:Vector.<FLARMarker>;
			/* Empty marker variable */
			var marker:FLARMarker;
			/* Empty container variable */
			var container:DisplayObject3D;
			/* Empty integer */
			var j:int;
			
			/* Loop through all tracked patterns */
			while (i--) {
				/* Store reference to all markers with this pattern id */
				markerList = this.markersByPatternId[i];
				/* Amount of markers with this pattern */
				j = markerList.length;
				/* Loop through markers with this pattern */
				while (j--) {
					/* Store reference to current marker */
					marker = markerList[j];
					
					/* Initialise a new Shape object */
					var nodes:Shape = new Shape();
					/* Define line style for corner nodes */
					nodes.graphics.lineStyle(3, getColorByPatternId(marker.patternId));
					/* Store reference to coordinates for each corner of the marker */
					var corners:Vector.<Point> = marker.corners;
					/* Empty coordinate variable */
					var vertex:Point;
					/* Loop through rest of corner coordinates */
					for (var c:uint=0; c<corners.length; c++) {
						/* Store reference to current corner coordinates */
						vertex = corners[c];
						/* Draw a 2D circle at these coordinates */
						nodes.graphics.drawCircle(vertex.x, vertex.y, 5);
					}
					/* Add reference to corner nodes to nodesByMarker Dictionary object */
					this.nodesByMarker[marker] = nodes;
					/* Add corner nodes to the main scene */
					this.addChild(nodes);
					
					/* Find reference to marker container in containersByMarker Dictionary object */
					container = this.containersByMarker[marker];
					/* Transform container to new position in 3d space */
					container.transform = FLARPVGeomUtils.convertFLARMatrixToPVMatrix(marker.transformMatrix);
					trace(container.x+', '+container.y);
				}
			}
		}
		
		/* Update debug output */
		private function updateDebugOutput():void {
			if (!this.debugOutput) {
				this.debugOutput = new TextField();
				this.debugOutput.x = 20;
				this.debugOutput.y = 20;
				this.debugOutput.width = stage.stageWidth;
				this.debugOutput.height = 100;
				this.debugOutput.textColor = 0xFF0000;
				
				var format:TextFormat = new TextFormat();
				format.size = 26;
				
				this.debugOutput.defaultTextFormat = format;
				
				this.addChild(this.debugOutput);
			}
			
			if (this.grid)
				this.debugOutput.text = 'Grid x: '+Math.round(this.grid.x)+'\nGrid y: '+Math.round(this.grid.y);
		}
		
		/* Get colour values dependent on pattern id */
		private function getColorByPatternId(patternId:int, shaded:Boolean = false):Number {
			switch (patternId) {
				case 0:
					if (!shaded)
						return 0xFF1919;
					return 0x730000;
				case 1:
					if (!shaded)
						return 0xFF19E8;
					return 0x730067;
				case 2:
					if (!shaded)
						return 0x9E19FF;
					return 0x420073;
				case 3:
					if (!shaded)
						return 0x192EFF;
					return 0x000A73;
				case 4:
					if (!shaded)
						return 0x1996FF;
					return 0x003E73;
				case 5:
					if (!shaded)
						return 0x19FDFF;
					return 0x007273;
				default:
					if (!shaded)
						return 0xCCCCCC;
					return 0x666666;
			}
		}
	}
}