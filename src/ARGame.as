package {
	import argame.grid.ARGameGrid;
	
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
	import flash.utils.Dictionary;
	
	import org.libspark.flartoolkit.support.pv3d.FLARCamera3D;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.render.data.RenderHitData;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.Collada;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
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
			var gridWidth:int = 200;
			var gridHeight:int = 200;
			
			/* Initialise grid object */
			this.grid = new ARGameGrid(0, 0, gridWidth, gridHeight, 5, 5);
			
			/* Add marker to grid object */
			this.grid.marker = marker;
			
			/* Initialise the grid container object */
			var container:DisplayObject3D = new DisplayObject3D();
			
			/* Add container to grid object */
			this.grid.container = container;
			
			var colour:Number = Math.random()*0xFFFFFF;
			var gridMaterial:ColorMaterial = new ColorMaterial(colour, 0.6);
			//var gridMaterial:BitmapFileMaterial = new BitmapFileMaterial("resources/Grid-Texture.png");
			gridMaterial.interactive = true;
			gridMaterial.doubleSided = true;
			
			var grid:Plane = new Plane(gridMaterial, gridWidth, gridHeight, 4, 4);
			grid.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, this.clickGrid);
			
			this.grid.plane = grid;
			
			container.addChild(grid);
			
			/* Draw grid */
			/*
			var segWidth:int = this.grid.width/5;
			var segHeight:int = this.grid.height/5;			
			for (var i:int = 1; i <= this.grid.segRowCount; i++) {
				for (var j:int = 1; j <= this.grid.segColCount; j++) {
					var gridSegColour:Number = Math.random()*0xFFFFFF;
					var gridSegFlatShaderMat:FlatShadeMaterial = new FlatShadeMaterial(pointLight3D, gridSegColour, gridSegColour);
					gridSegFlatShaderMat.interactive = true;
					var gridSegMaterials:MaterialsList = new MaterialsList({all: gridSegFlatShaderMat});
					var gridSeg:Cube = new Cube(gridSegMaterials, segWidth, 0, segHeight);
					gridSeg.x = (j-0.5)*(this.grid.width/this.grid.segColCount)-(this.grid.width/2);
					gridSeg.y = (i-0.5)*(this.grid.height/this.grid.segRowCount)-(this.grid.height/2);
					container.addChild(gridSeg);
				}
			}
			*/
			
			/* Add grid container to the Papervision scene */
			this.scene3D.addChild(container);
		}
		
		private function clickGrid(event:InteractiveScene3DEvent):void {			
			var rhd:RenderHitData = this.viewport3D.hitTestMouse();
			//trace("[eX: "+event.x+", eY: "+event.y+"], [rhdX: "+rhd.x+", rhdY: "+rhd.y+"], [u: "+rhd.u+", v:"+rhd.v+"]");
			var eventXCalc:Number = event.x-0.5;
			var eventYCalc:Number = event.y-0.5;
			trace("[eX: "+event.x+", eY: "+event.y+"], [eX-0.5: "+eventXCalc+", eY-0.5: "+eventYCalc+"]");
				
			var planeMat:ColorMaterial = new ColorMaterial(0xFF0000);
			planeMat.doubleSided = true;
			var node:Plane = new Plane(planeMat, 5, 5);
			node.x = (event.x-0.5)*this.grid.width;
			node.y = ((event.y-0.5)*this.grid.height)*-1;
			this.grid.container.addChild(node);
			
			this.grid.drawMarkerOnGridmap(Math.round(event.x*100)/100, Math.round(event.y*100)/100);
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
			var flatShaderMat0:FlatShadeMaterial = new FlatShadeMaterial(pointLight3D, getColorByPatternId(0), getColorByPatternId(0, true));
			var flatShaderMat1:FlatShadeMaterial = new FlatShadeMaterial(pointLight3D, getColorByPatternId(5), getColorByPatternId(5, true));
			var flatShaderMat2:FlatShadeMaterial = new FlatShadeMaterial(pointLight3D, getColorByPatternId(2), getColorByPatternId(2, true));
			var flatShaderMat3:FlatShadeMaterial = new FlatShadeMaterial(pointLight3D, getColorByPatternId(3), getColorByPatternId(3, true));
			
			/* Add material to all sides of the cube */
			var cubeMaterials:MaterialsList = new MaterialsList({all: flatShaderMat, top: flatShaderMat0, bottom: flatShaderMat1, left: flatShaderMat2, right: flatShaderMat3});
			
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
			
			/* Work out why materials aren't loading on Collada model */
			var modelMaterial:BitmapFileMaterial = new BitmapFileMaterial("resources/Brick/texture0.jpg");
			modelMaterial.tiled = true;
			var modelMaterials:MaterialsList = new MaterialsList({all: modelMaterial});
			var model:Collada = new Collada("resources/Brick.dae", modelMaterials);
			
			model.scale = 0.01;
			model.rotationX = -90;
			model.rotationY = -180;
			//container.addChild(model);
			
			/* Add marker container to the Papervision scene */
			//this.scene3D.addChild(container);
			this.grid.container.addChild(container);
			
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
				//this.scene3D.removeChild(container);
				this.grid.container.removeChild(container);
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
			this.viewport3D = new Viewport3D(640, 480, true, true);
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
			
			/* Render the Papervision scene */
			this.lre.render();
		}
		
		/* Update grid method */
		private function updateGrid():void {
			if (this.grid && this.grid.active) {			
				/* Transform container to new position in 3d space */
				this.grid.container.transform = FLARPVGeomUtils.convertFLARMatrixToPVMatrix(this.grid.marker.transformMatrix);
				
				/* Update grid postion variables */
				this.grid.updatePosition(this.grid.container.x, this.grid.container.y);
				
				if (!this.contains(this.grid.getGridMap())) {
					this.addChild(this.grid.getGridMap());
				}
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
					//container.transform = FLARPVGeomUtils.convertFLARMatrixToPVMatrix(marker.transformMatrix);
					
					/* 
					 * Bit innacurate, could possibly subtract marker transformation from grid transformation
					 * instead of working out two calculations
					 */
					var gridRotation:Number3D = Matrix3D.matrix2euler(this.grid.container.transform);
					var markerRotation:Number3D = Matrix3D.matrix2euler(FLARPVGeomUtils.convertFLARMatrixToPVMatrix(marker.transformMatrix));
					var containerRotation:Number = (markerRotation.z-gridRotation.z)*-1;
					
					if (containerRotation >= -46 && containerRotation <= 45) {
						trace(0);
						container.rotationZ = 0;
					} else if (containerRotation >= 46 && containerRotation <= 135) {
						trace(90);
						container.rotationZ = 90;
					} else if ((containerRotation >= 136 && containerRotation <= 180) || (containerRotation >= -180 && containerRotation <= -135)) {
						trace(180);
						container.rotationZ = 180;
					} else if (containerRotation >= -134 && containerRotation <= -45) {
						trace(-90);
						container.rotationZ = -90;
					}

					//var rhd:RenderHitData = this.viewport3D.hitTestPointObject(new Point(marker.centerpoint.x, marker.centerpoint.y), this.grid.plane);
					var rhd:RenderHitData = this.viewport3D.hitTestPointObject(new Point(marker.centerpoint.x-(stage.stageWidth/2), marker.centerpoint.y-(stage.stageHeight/2)), this.grid.plane);
					if (rhd.hasHit) {					
						/* Convert to use ARGameGrid calcGridReference method */ 
						var gridX:Number = Math.floor((Math.floor(rhd.u*10)/10)*this.grid.segColCount)+1;
						var gridY:Number = Math.floor((Math.floor(rhd.v*10)/10)*this.grid.segRowCount)+1;

						//trace("[x: "+Math.round(rhd.x)+", y: "+Math.round(rhd.y)+"], [u: "+rhd.u+", v:"+rhd.v+"]");
						//trace("Grid pos: "+gridX+", "+gridY);
						
						container.x = (rhd.u-0.5)*this.grid.width;
						container.y = ((rhd.v-0.5)*this.grid.height)*-1;
						container.z = 0;
						
						//trace("CubeX: "+container.x+", CubeY: "+container.y+" CalcX: "+(rhd.u-0.5)*this.grid.width+", CalcY: "+((rhd.v-0.5)*this.grid.height)*-1);
						
						//this.grid.drawMarkerOnGridmap(Math.floor(rhd.u*10)/10, Math.floor(rhd.v*10)/10);
						this.grid.drawMarkerOnGridmap(Math.round(rhd.u*100)/100, Math.round(rhd.v*100)/100);
					}
					//trace(Math.round(container.x)+', '+Math.round(container.y));
					//trace(grid.calcGridReference(container.x, container.y));
				}
			}
		}
		
		/* Get colour values dependent on pattern id */
		private function getColorByPatternId(patternId:int, shaded:Boolean = false):Number {
			switch (patternId) {
				case 0:
					if (!shaded)
						return 0xFF1919; // Red
					return 0x730000;
				case 1:
					if (!shaded)
						return 0x00FF00; // Green
					return 0x02bf02;
				case 2:
					if (!shaded)
						return 0x9E19FF; // Purple
					return 0x420073;
				case 3:
					if (!shaded)
						return 0x1996FF; // Blue
					return 0x003E73;
				case 4:
					if (!shaded)
						return 0xff19e7; // Pink
					return 0xc501b1;
				case 5:
					if (!shaded)
						return 0xffec19; // Yellow
					return 0xd2c102;
				default:
					if (!shaded)
						return 0xCCCCCC;
					return 0x666666;
			}
		}
	}
}