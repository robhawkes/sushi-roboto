package game {
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;

	public class GameCharacterObject extends GameObject {
		public function GameCharacterObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			var material:ColorMaterial = new ColorMaterial(0x00FF00);
			var materialsList:MaterialsList = new MaterialsList({all: material});
			
			var object:Cube = new Cube(materialsList, 10, 10, 10);
			object.z += 0.5 * 10;
			
			this.addChild(object);
		}
		
		public override function update():void {
			super.update();
		}
	}
}