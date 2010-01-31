package game {
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.PaperPlane;

	public class GameCharacterObject extends GameObject {
		public function GameCharacterObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			var material:ColorMaterial = new ColorMaterial(0x00FF00);

			var object:PaperPlane = new PaperPlane(material, 0.1);
			object.z -= 5;
			
			// Rotate object so it faces forward in relation to the game board
			object.pitch(-90);
			
			this.addChild(object);
		}
		
		public override function update():void {
			super.update();
		}
	}
}