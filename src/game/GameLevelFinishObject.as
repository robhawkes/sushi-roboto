package game {	
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Plane;

	public class GameLevelFinishObject extends GameLevelObject {
		public function GameLevelFinishObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			var attributes:Array = new Array();
			attributes["finish"] = true;
			
			this._setAttributes(attributes);
			
			var material:BitmapFileMaterial = new BitmapFileMaterial("resources/textures/objects/finish/finish.png");
			material.doubleSided = true;
			
			var object:Plane = new Plane(material, 40, 40);
			object.y += 20;
			object.z -= 20;
			object.pitch(-90);
			
			this.addChild(object);
		}
	}
}