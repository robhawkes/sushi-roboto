package game {
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.parsers.DAE;

	public class GameCharacterObject extends GameObject {
		public function GameCharacterObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			var material:ColorMaterial = new ColorMaterial(0x0000FF);

			/* Collada madel */
			var material1:BitmapFileMaterial = new BitmapFileMaterial("resources/objects/roboto/body.jpg");
			var objectMaterials:MaterialsList = new MaterialsList({body_jpg_img: material1});
			var object:DAE = new DAE(true, "", true);
			object.load("resources/objects/roboto/roboto.dae", objectMaterials);
			this._collada = object;
			
			object.scale = 0.4;
			object.rotationZ = 180;
			object.rotationX = -90;
			
			/* Debug model */
			/*var object:PaperPlane = new PaperPlane(material, 0.1);
			object.z -= 5;
			// Rotate object so it faces forward in relation to the game board
			object.pitch(-90);*/
			
			this.addChild(object);
		}
		
		public override function update():void {
			super.update();
		}
	}
}