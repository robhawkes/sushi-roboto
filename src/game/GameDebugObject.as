package game {
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;

	public class GameDebugObject extends GameObject {
		public function GameDebugObject() {
			super();
			this.interactive = true;
			this.initObject();
		}
		
		private function initObject():void {
			var material:ColorMaterial = new ColorMaterial(0x0000FF);
			var materialsList:MaterialsList = new MaterialsList({all: material});
			var object:Cube = new Cube(materialsList, 20, 20, 20);
			object.z = 0.5*20;
			this.addChild(object);
		}
		
		public override function update():void {
			super.update();
		}
	}
}