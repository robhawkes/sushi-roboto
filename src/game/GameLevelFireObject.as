package game {
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;
	
	public class GameLevelFireObject extends GameLevelObject {
		public function GameLevelFireObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "fire";
			
			var attributes:Array = new Array();
			attributes["fatal"] = true;
			
			this._setAttributes(attributes);
			
			var material:ColorMaterial = new ColorMaterial(0xFF0000);
			var materialsList:MaterialsList = new MaterialsList({all: material});
			
			var object:Cube = new Cube(materialsList, 40, 40, 40);
			object.z -= 0.5 * 40;
			
			this.addChild(object);
		}
	}
}