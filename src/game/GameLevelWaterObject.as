package game {
	import flash.net.URLRequest;
	
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.primitives.Plane;
	
	public class GameLevelWaterObject extends GameLevelObject {
		public function GameLevelWaterObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "water";
			//this._ambientSound = new GameSound(new URLRequest("resources/sounds/objects/water/water_ambient.mp3"))
			this._killSound = new GameSound(new URLRequest("resources/sounds/objects/water/water_kill.mp3"));
			
			var attributes:Array = new Array();
			attributes["fluid"] = true;
			attributes["fatal"] = true;
			
			this._setAttributes(attributes);
			
			var material:ColorMaterial = new ColorMaterial(0x0000FF);
			material.fillAlpha = 0.5;
			var object:Plane = new Plane(material, 40, 40);
			
			this.addChild(object);
		}
	}
}