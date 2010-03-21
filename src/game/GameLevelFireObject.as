package game {
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cylinder;
	
	public class GameLevelFireObject extends GameLevelObject {
		public function GameLevelFireObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "fire";
			//this._ambientSound = new GameSound(new URLRequest("resources/sounds/objects/fire/fire_ambient.mp3"))
			
			var attributes:Array = new Array();
			attributes["fatal"] = true;
			
			this._setAttributes(attributes);
			
			var material:ColorMaterial = new ColorMaterial(0xFF0000);
			var materialsList:MaterialsList = new MaterialsList({all: material});
			
			//var object:Cube = new Cube(materialsList, 40, 40, 40);
			//object.z -= 0.5 * 40;
			
			var object:Cylinder = new Cylinder(material, 20, 1);
			object.pitch(-90);
			
			this.addChild(object);
		}
	}
}