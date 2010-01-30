package game {
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public class GameMap extends Sprite {
		/* Dimensions */
		private const _width:int = 100;
		private const _height:int = 100;
		
		/* Marker to be displayed on map */
		private var _marker:Sprite;
		
		public function GameMap() {
			this._initMap();
		}
		
		private function _initMap():void {
			var outline:Shape = new Shape();
			outline.graphics.lineStyle(4, 0xFF0000);
			outline.graphics.drawRect(20, 20, this._width, this._height);
			
			this.addChild(outline);
		}
		
		public function drawGrid(rows:int, columns:int):void {
			var i:int;			
			for (i = 0; i < rows; i++) {
				var row:Shape = new Shape();
				row.graphics.lineStyle(1, 0xFF0000, 0.6);
				row.graphics.moveTo(20, 20+(this._height/rows)*i);
				row.graphics.lineTo(120, 20+(this._height/rows)*i)
				this.addChild(row);
			}
			
			var j:int;
			for (j = 0; j < columns; j++) {
				var column:Shape = new Shape();
				column.graphics.lineStyle(1, 0xFF0000, 0.6);
				column.graphics.moveTo(20+(this._width/columns)*j, 20);
				column.graphics.lineTo(20+(this._width/columns)*j, 120)
				this.addChild(column);
			}
		}
		
		public function updateMarker(x:Number = 0, y:Number = 0):void {
			if (!this._marker) {
				var markerShape:Shape = new Shape();
				markerShape.graphics.beginFill(0x00FF00);
				markerShape.graphics.drawCircle(0, 0, 3);
				
				this._marker = new Sprite();
				this._marker.x = (x*100)+20;
				this._marker.y = (100-(y*100))+20;
				
				this._marker.addChild(markerShape);
			} else {
				this._marker.x = (x == 1) ? 120 : (x*100)+20;
				this._marker.y = (y == 1) ? 20 : (100-(y*100))+20;
			}
			
			if (!this.contains(this._marker))
				this.addChild(this._marker);
		}
		
		public function removeMarker():void {
			if (this._marker && this.contains(this._marker))
				this.removeChild(this._marker);
		}
	}
}