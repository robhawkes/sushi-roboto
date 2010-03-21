package game {
	import flash.net.URLRequest;
	
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;

	public class GameLevelWallObject extends GameLevelObject {
		public function GameLevelWallObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "wall";
			this._killSound = new GameSound(new URLRequest("resources/sounds/objects/wall/wall_kill.mp3"))
			
			var attributes:Array = new Array();
			attributes["solid"] = true;
			attributes["fatal"] = true;
			
			this._setAttributes(attributes);
			
			var material:ColorMaterial = new ColorMaterial(0x60C0FF);
			var materialsList:MaterialsList = new MaterialsList({all: material});
			
			var object:Cube = new Cube(materialsList, 40, 40, 40);
			object.z -= 0.5 * 40;
			
			this.addChild(object);
		}
	}
}