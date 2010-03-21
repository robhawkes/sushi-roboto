package game {	
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.objects.primitives.Plane;

	public class GameLevelFinishObject extends GameLevelObject {
		private var _orientation:String;
		
		public function GameLevelFinishObject(orientation:String = "top") {
			super();
			this._orientation = orientation;
			this._initObject();
		}
		
		private function _initObject():void {
			var attributes:Array = new Array();
			attributes["finish"] = true;
			
			this._setAttributes(attributes);
			
			var material:BitmapFileMaterial = new BitmapFileMaterial("resources/textures/objects/finish/finish.png");
			material.doubleSided = true;
			
			var object:Plane = new Plane(material, 40, 40);
			object.z -= 20;
			object.pitch(-90);
			
			switch (this._orientation as String) {
				case "top":
					object.y += 20;
					break;
				case "bottom":
					object.y -= 20;
					break;
				case "left":
					object.y += 20;
					object.rotationZ = -90;
					break;
				case "right":
					object.y += 20;
					object.rotationZ = 90;
					break;
				default:
					trace("Finish default");
					break;
			}
			
			
			this.addChild(object);
		}
	}
}