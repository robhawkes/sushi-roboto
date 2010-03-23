package game {
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.parsers.Collada;
	import org.papervision3d.objects.parsers.DAE;
	
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
			
			/*var materials:MaterialsList = new MaterialsList({all: new ColorMaterial(0xFF0000)});
			var object:Cube = new Cube(materials, 20, 20, 20);
			object.z -= 0.5 * 20;*/
			
			var materials:MaterialsList = new MaterialsList({Material1: new BitmapFileMaterial("resources/objects/wok/wokhand.jpg"), Material2: new BitmapFileMaterial("resources/objects/wok/wokbase.jpg")});
			var object:DAE = new DAE();
			object.load("resources/objects/wok/wok.dae", materials);
			this._collada = object;
			
			object.scale = 0.7;
			object.rotationZ = 180;
			object.rotationX = -90;
			
			this.addChild(object);
			
			this._interactiveObject = object;
		}
	}
}