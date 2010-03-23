package game {
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.parsers.DAE;
	
	public class GameEnvironmentTapObject extends GameEnvironmentObject {
		private var _orientation:String;
		
		public function GameEnvironmentTapObject(orientation:String = "top") {
			super();
			this._orientation = orientation;
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "tap";
			
			var materials:MaterialsList = new MaterialsList({all: new BitmapFileMaterial("resources/objects/tap/tap.jpg")});
			var object:DAE = new DAE();
			object.load("resources/objects/tap/tap.dae", materials);
			this._collada = object;
			//var object:Collada = new Collada("resources/objects/tap/tap.dae", materials);
			
			object.scale = 20;
			object.rotationX = -90;
			
			switch (this._orientation) {
				case "top":
					object.y += 5;
					object.rotationZ = 90;
					break;
				case "bottom":
					object.y -= 5;
					object.rotationZ = -90;
					break;
				case "left":
					object.x -= 5;
					object.rotationZ = 180;
					break;
				case "right":
					object.x += 5;
					object.rotationZ = 0;
					break;
			}
			
			this.addChild(object);
		}
	}
}