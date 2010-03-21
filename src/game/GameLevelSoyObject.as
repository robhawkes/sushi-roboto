package game {
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.primitives.Plane;
	
	public class GameLevelSoyObject extends GameLevelObject {
		private var _texture:String = "single";
		
		public function GameLevelSoyObject(texture:String = null) {
			super();
			
			if (texture)
				this._texture = texture;
			
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "soy";
			
			var attributes:Array = new Array();
			attributes["fluid"] = true;
			attributes["fatal"] = true;
			
			this._setAttributes(attributes);
			
			var material:BitmapFileMaterial;
			
			switch (this._texture) {
				default:
					material = new BitmapFileMaterial("resources/textures/objects/soy/soy_single.png");
					break;
			}
			
			var object:Plane = new Plane(material, 40, 40);
			
			this.addChild(object);
		}
	}
}