package game {
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.primitives.Plane;
	
	public class GameLevelDoughObject extends GameLevelObject {
		private var _texture:String = "single";
		
		public function GameLevelDoughObject(texture:String = null) {
			super();
			
			if (texture)
				this._texture = texture;
			
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "dough";
			
			var attributes:Array = new Array();
			attributes["fluid"] = true;
			attributes["fatal"] = true;
			
			this._setAttributes(attributes);
			
			var material:BitmapFileMaterial;
			
			switch (this._texture) {
				case "top":
					material = new BitmapFileMaterial("resources/textures/objects/dough/dough_top.png");
					break;
				case "bottom":
					material = new BitmapFileMaterial("resources/textures/objects/dough/dough_bottom.png");
					break;
				case "middle":
					material = new BitmapFileMaterial("resources/textures/objects/dough/dough_middle.png");
					break;
				default:
					material = new BitmapFileMaterial("resources/textures/objects/dough/dough_single.png");
					break;
			}
			
			var object:Plane = new Plane(material, 40, 40);
			
			this.addChild(object);
		}
	}
}