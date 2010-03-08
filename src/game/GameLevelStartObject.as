package game {	
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Plane;
	
	public class GameLevelStartObject extends GameLevelObject {
		public function GameLevelStartObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			var attributes:Array = new Array();
			attributes["finish"] = true;
			
			this._setAttributes(attributes);
			
			var material:BitmapFileMaterial = new BitmapFileMaterial("resources/textures/objects/start/start.png");
			var object:Plane = new Plane(material, 40, 40);
			
			this.addChild(object);
		}
	}
}