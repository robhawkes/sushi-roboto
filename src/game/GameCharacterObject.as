package game {
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.primitives.PaperPlane;

	public class GameCharacterObject extends GameObject {
		public function GameCharacterObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			var material:ColorMaterial = new ColorMaterial(0x00FF00);

			/* Collada madel */
			/*
			var material1:BitmapFileMaterial = new BitmapFileMaterial("resources/texture.jpg");
			var material2:BitmapFileMaterial = new BitmapFileMaterial("resources/texture2.jpg");
			var objectMaterials:MaterialsList = new MaterialsList({Material1: material1, Material2: material2});
			var object:Collada = new Collada("resources/robot.dae", objectMaterials);
			object.scale = 0.001;
			object.rotationZ = 180;
			object.rotationX = -90;
			*/
			
			/* Debug model */
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