package argame.grid
{
	import com.transmote.flar.marker.FLARMarker;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	
	public class ARGameGrid extends Object {
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
		
		public function ARGameGrid(oriX:Number = 0, oriY:Number = 0, width:int = 100, height:int = 100, segColCount:int = 5, segRowCount:int = 0) {
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
			
			/* Draw grid map */
			this.drawGridMap();
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
		
		public function drawGridMap():void {			
			var gridOutline:Shape = new Shape();
			gridOutline.graphics.lineStyle(4, 0xFF0000);
			gridOutline.graphics.drawRect(20, 20, 100, 100);
			
			this.gridMap = new Sprite();
			this.gridMap.addChild(gridOutline);
		}
		
		public function drawMarkerOnGridmap(x:Number, y:Number):void {
			if (!this.gridMapMarker) {
				//trace("Setting up grid map marker");
				var markerPoint:Shape = new Shape();
				markerPoint.graphics.beginFill(0x00FF00);
				markerPoint.graphics.drawCircle(0, 0, 3);
				
				this.gridMapMarker = new Sprite();
				this.gridMapMarker.x = (x*100)+20;
				this.gridMapMarker.y = (100-(y*100))+20;
				
				this.gridMapMarker.addChild(markerPoint);
				this.gridMap.addChild(this.gridMapMarker);
			} else {
				//trace("Updating grid map marker [x: "+x+", y: "+y+"]");
				this.gridMapMarker.x = (x == 1) ? 120 : (x*100)+20;
				this.gridMapMarker.y = (y == 1) ? 20 : (100-(y*100))+20;
			}
		}
		
		public function getGridMap():Sprite {
			return this.gridMap;
		}
	}
}