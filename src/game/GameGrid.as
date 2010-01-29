package game {
	import com.transmote.flar.marker.FLARMarker;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	
	public class GameGrid extends Object {
		/* Dimensions */
		public var width:int;
		public var height:int;
		
		/* Position */
		public var oriX:Number;
		public var oriY:Number;
		public var x:Number;
		public var y:Number;
		public var active:Boolean;
		
		/* Segments */
		public var segColCount:int;
		public var segRowCount:int;
		public var segWidth:int;
		public var segHeight:int;
		
		/* Augmented Reality */
		public var marker:FLARMarker;
		public var container:DisplayObject3D;
		public var plane:Plane;
		
		/* Grid map */
		private var gridMap:Sprite;
		private var gridMapMarker:Sprite;
		
		public function GameGrid(oriX:Number = 0, oriY:Number = 0, width:int = 100, height:int = 100, segColCount:int = 5, segRowCount:int = 0) {
			/* Run parent constructor */ 
			super();
			
			/* Set grid dimensions */
			this.width = width;
			this.height = height;
			
			/* Set grid position */
			this.updatePosition(oriX, oriY);
			this.active = true;
			
			/* Set grid segments */
			this.segColCount = segColCount;
			this.segRowCount = segRowCount;
		}
		
		public function updatePosition(oriX:Number, oriY:Number):void {
			this.oriX = oriX;
			this.oriY = oriY;
			this.x = this.oriX-(this.width/2);
			this.y = this.oriY-(this.height/2);
		}
		
		public function calcGridReference(x:Number, y:Number):Point {
			var gridReference:Point = new Point();
			
			gridReference.x = Math.floor((x/(this.width/this.segColCount))+1);
			gridReference.y = Math.floor((y/(this.height/this.segRowCount))+1);
			
			return gridReference;
		}
		
		public function getGridMap():Sprite {
			return this.gridMap;
		}
	}
}