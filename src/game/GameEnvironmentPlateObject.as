package game {
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.parsers.DAE;
	
	public class GameEnvironmentPlateObject extends GameEnvironmentObject {
		public function GameEnvironmentPlateObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "plate";
			
			var materials:MaterialsList = new MaterialsList({all: new BitmapFileMaterial("resources/objects/plate/plate.gif")});
			var object:DAE = new DAE();
			object.load("resources/objects/plate/plate.dae", materials);
			this._collada = object;
			
			object.scale = 20;
			object.rotationX = -90;
			
			this.addChild(object);
		}
	}
}