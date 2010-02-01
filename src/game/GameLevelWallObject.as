package game {
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;

	public class GameLevelWallObject extends GameLevelObject {
		public function GameLevelWallObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			var attributes:Array = new Array();
			attributes["solid"] = true;
			
			this._setAttributes(attributes);
			
			var material:ColorMaterial = new ColorMaterial(0x60C0FF);
			var materialsList:MaterialsList = new MaterialsList({all: material});
			
			var object:Cube = new Cube(materialsList, 40, 40, 40);
			object.z -= 0.5 * 40;
			
			this.addChild(object);
		}
	}
}