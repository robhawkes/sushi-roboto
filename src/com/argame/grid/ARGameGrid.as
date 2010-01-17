package com.argame.grid
{
	import com.transmote.flar.marker.FLARMarker;
	
	import org.papervision3d.objects.DisplayObject3D;
	
	public class ARGameGrid extends Object {
		/* Position */
		public var x:Number;
		public var y:Number;
		public var active:Boolean;
		
		/* Dimensions */
		public var width:int;
		public var height:int;
		
		/* Segments */
		public var segColCount:int;
		public var segRowCount:int;
		public var segWidth:int;
		public var segHeight:int;
		
		/* Augmented Reality */
		public var marker:FLARMarker;
		public var container:DisplayObject3D;
		
		public function ARGameGrid(x:Number = 0, y:Number = 0, width:int = 100, height:int = 100, segColCount:int = 5, segRowCount:int = 0) {
			/* Run parent constructor */ 
			super();
			
			/* Set grid position */
			this.x = x;
			this.y = y;
			this.active = true;
			
			/* Set grid dimensions */
			this.width = width;
			this.height = height;
			
			/* Set grid segments */
			this.segColCount = segColCount;
			this.segRowCount = segRowCount;
		}
	}
}