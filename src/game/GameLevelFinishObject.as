package game {	
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;

	public class GameLevelFinishObject extends GameLevelObject {
		public function GameLevelFinishObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			var attributes:Array = new Array();
			attributes["finish"] = true;
			
			this._setAttributes(attributes);
			
			var material:ColorMaterial = new ColorMaterial(0xffae00);
			var materialsList:MaterialsList = new MaterialsList({all: material});
			
			var object:Cube = new Cube(materialsList, 40, 2, 40);
			object.z -= 0.5 * 2;
			
			this.addChild(object);
		}
	}
}