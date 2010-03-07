package game {
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.primitives.Plane;
	
	public class GameLevelWasabiObject extends GameLevelObject {
		private var _texture:String = "single";
		
		public function GameLevelWasabiObject(texture:String = null) {
			super();
			
			if (texture)
				this._texture = texture;
			
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "wasabi";
			
			var attributes:Array = new Array();
			attributes["fluid"] = true;
			attributes["fatal"] = true;
			
			this._setAttributes(attributes);
			
			var material:BitmapFileMaterial;
			
			switch (this._texture) {
				case "top":
					material = new BitmapFileMaterial("resources/textures/objects/wasabi/wasabi_top.png");
					break;
				case "bottom":
					material = new BitmapFileMaterial("resources/textures/objects/wasabi/wasabi_bottom.png");
					break;
				default:
					material = new BitmapFileMaterial("resources/textures/objects/wasabi/wasabi_single.png");
					break;
			}
			
			var object:Plane = new Plane(material, 40, 40);
			
			this.addChild(object);
		}
	}
}