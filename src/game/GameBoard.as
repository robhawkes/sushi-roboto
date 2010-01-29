package game {
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.utils.geom.FLARPVGeomUtils;
	
	import flash.utils.Dictionary;
	
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;

	public class GameBoard {
		private var activeObjectId:int;
		public var container:DisplayObject3D;
		private var containersByObject:Dictionary;
		private var grid:GameGrid;
		private var map:GameMap;
		private var objects:Vector.<GameObject>;
		
		public function GameBoard() {
			this.container = new DisplayObject3D();
			
			this.containersByObject = new Dictionary(true);
			this.objects = new Vector.<GameObject>();
			
			this.populateBoard();
		}
		
		private function populateBoard():void {
			var plane:Plane = new Plane(new ColorMaterial(0xFF0000), 100, 100, 4, 4);
			plane.rotationY = 180;
			this.container.addChild(plane);
		}
		
		public function addObject(marker:FLARMarker):void {
			var object:GameObject = new GameDebugObject();
			this.objects.push(object);
			
			this.container.addChild(object);
		}
		
		public function updateBoard(marker:FLARMarker):void {
			/* Transform board to new position in 3D space */
			this.container.transform = FLARPVGeomUtils.convertFLARMatrixToPVMatrix(marker.transformMatrix);
		}
		
		public function updateActiveObject(marker:FLARMarker):void {
			/* Transform active object, etc */
		}
		
		public function updateObjects():void {
			/* Store reference to amount of objects on board */
			var i:int = this.objects.length;
			var object:GameObject;
			
			/* Loop through all objects */
			while (i--) {
				/* Basic object checks and updates */
				object = this.objects[i];
			}
		}
	}
}