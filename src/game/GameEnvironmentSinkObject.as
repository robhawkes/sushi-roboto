package game {
	import flash.geom.Point;
	
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;

	public class GameEnvironmentSinkObject extends GameEnvironmentObject {
		private var _size:Point;
		
		public function GameEnvironmentSinkObject(size:Point) {
			super();
			this._size = size;
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "sink";
			
			var material:ColorMaterial = new ColorMaterial(0x60C0FF);
			var materialBottom:ColorMaterial = new ColorMaterial(0xFF0000);
			var materialsList:MaterialsList = new MaterialsList({all: material, front: materialBottom});
			
			var object:Cube = new Cube(materialsList, 40*this._size.x, 40, 40*this._size.y, 1, 1, 1, Cube.ALL, Cube.BACK);
			object.z += 0.5 * 40;
			
			/* Add green mask to create transparent walls around pit of water */
			var maskMaterial:ColorMaterial = new ColorMaterial(0x00FF00);
			var maskMaterialsList:MaterialsList = new MaterialsList({all: maskMaterial});
			
			var mask:Cube = new Cube(maskMaterialsList, 40*this._size.x, 40, 40*this._size.y, 1, 1, 1, 0, Cube.BACK);
			mask.z += 0.5 * 40;
			
			this.addChild(mask);
			this.addChild(object);
		}
	}
}