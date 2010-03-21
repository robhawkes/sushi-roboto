package game {
	import flash.net.URLRequest;
	
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.primitives.Plane;
	
	public class GameLevelConveyorObject extends GameLevelObject {
		[Embed(source="resources/textures/objects/conveyor/conveyor.swf")]
		private var _texture:Class;
		
		public function GameLevelConveyorObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "conveyor";
			this._ambientSound = new GameSound(new URLRequest("resources/sounds/objects/conveyor/conveyor_ambient.mp3"))
			
			var attributes:Array = new Array();
			attributes["direction"] = "up";

			this._setAttributes(attributes);
			
			var material:MovieMaterial = new MovieMaterial(new this._texture(), false, true);
			var object:Plane = new Plane(material, 40, 40);
			
			this.addChild(object);
		}
	}
}