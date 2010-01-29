package game {
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public class GameMap extends Sprite {
		/* Marker to be displayed on map */
		private var marker:Sprite;
		
		public function GameMap() {
			
		}
		
		private function draw():void {
			var outline:Shape = new Shape();
			outline.graphics.lineStyle(4, 0xFF0000);
			outline.graphics.drawRect(20, 20, 100, 100);
			
			this.addChild(outline);
		}
		
		private function updateMarker(x:int = 0, y:int = 0):void {
			if (!this.marker) {
				var markerShape:Shape = new Shape();
				markerShape.graphics.beginFill(0x00FF00);
				markerShape.graphics.drawCircle(0, 0, 3);
				
				this.marker = new Sprite();
				this.marker.x = (x*100)+20;
				this.marker.y = (100-(y*100))+20;
				
				this.marker.addChild(markerShape);
				this.addChild(marker);
			} else {
				this.marker.x = (x == 1) ? 120 : (x*100)+20;
				this.marker.y = (y == 1) ? 20 : (100-(y*100))+20;
			}
		}
	}
}