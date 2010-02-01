package game {	
	import flash.geom.Point;
	
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;

	public class GameGrid {
		/* Dimensions */
		private var _width:int;
		private var _height:int;
		
		/* Segmentation */
		private var _rows:int;
		private var _columns:int;
		
		/* Papervision 3D object */
		private var _container:DisplayObject3D;
		private var _grid3DObject:DisplayObject3D;
		
		public function GameGrid(width:int = 100, height:int = 100, rows:int = 5, columns:int = 5) {
			this._width = width;
			this._height = height;
			this._rows = rows;
			this._columns = columns;
			
			this._initGrid3D();
		}
		
		private function _initGrid3D():void {
			var containerMaterial:ColorMaterial = new ColorMaterial(0xFFFFFF, 0, true);
			this._container = new Plane(containerMaterial, this._width, this._height, 4, 4);
			
			var material:BitmapFileMaterial = new BitmapFileMaterial("resources/Grid-Texture.png");
			material.baked = true;
			material.smooth = true;
			material.precise = true;
			
			this._grid3DObject = new Plane(material, this._width, this._height, 4, 4);
			
			this._container.addChild(this._grid3DObject);
		}
		
		private function _worldToGridCoord(x:int, y:int):Point {
			var coord:Point = new Point();
			coord.x = x+(this._width/2);
			coord.y = y+(this._height/2);
			
			return coord;
		}
		
		private function _gridToWorldCoord(x:int, y:int):Point {
			var coord:Point = new Point();
			coord.x = x-(this._width/2);
			coord.y = y-(this._height/2);
			
			return coord;
		}
		
		public function coordToGridReference(x:int, y:int):Point {
			var gridReference:Point = new Point();
			gridReference.x = Math.floor((x/(this._width/this._columns))+1);
			gridReference.y = Math.floor((y/(this._height/this._rows))+1);
			
			return gridReference;
		}
		
		public function worldCoordToGridReference(x:int, y:int):Point {
			var gridCoord:Point = this._worldToGridCoord(x, y);
			
			var gridReference:Point = new Point();
			gridReference.x = Math.floor((gridCoord.x/(this._width/this._columns))+1);
			gridReference.y = Math.floor((gridCoord.y/(this._height/this._rows))+1);
			
			return gridReference;
		}
		
		public function gridReferenceToWorldCoord(x:int, y:int):Point {
			var coord:Point = new Point();
			coord.x = ((x-0.5)*(this._width/this._columns));
			coord.y = ((y-0.5)*(this._height/this._rows));
			
			var worldCoord:Point = this._gridToWorldCoord(coord.x, coord.y);
			
			return worldCoord;
		}
		
		public function get width():int {
			return this._width;
		}
		
		public function get height():int {
			return this._height;
		}
		
		public function get container():DisplayObject3D {
			return this._container;
		}
	}
}