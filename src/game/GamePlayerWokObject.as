package game {
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Sphere;
	
	public class GamePlayerWokObject extends GamePlayerObject {
		public function GamePlayerWokObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "wok";
			
			var attributes:Array = new Array();
			
			this._setAttributes(attributes);
			
			var material:ColorMaterial = new ColorMaterial(0xFF0000);
			material.interactive = true;
			
			var materials:MaterialsList = new MaterialsList({all: new ColorMaterial(0xFF0000)});
			var object:Cube = new Cube(materials, 20, 20, 20);
			object.z -= 0.5 * 20;
			
			this.addChild(object);
			
			this._interactiveObject = object;
		}
	}
}