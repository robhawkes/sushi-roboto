package game {
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.parsers.DAE;
	
	public class GameEnvironmentChopsticksObject extends GameEnvironmentObject {
		private var _orientation:String;
		
		public function GameEnvironmentChopsticksObject(orientation:String = "top") {
			super();
			this._orientation = orientation;
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "chopsticks";
			
			var materials:MaterialsList = new MaterialsList({all: new BitmapFileMaterial("resources/objects/chopsticks/chopsticks.gif")});
			var object:DAE = new DAE();
			object.load("resources/objects/chopsticks/chopsticks.dae", materials);
			this._collada = object;
			
			object.scale = 1.5;
			object.rotationX = -90;
			object.y -= 20;
			object.x -= 20;
			
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