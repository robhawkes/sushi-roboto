package game {
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Sphere;
	
	public class GamePlayerWaterObject extends GamePlayerObject {
		public function GamePlayerWaterObject() {
			super();
			this._initObject();
		}
		
		private function _initObject():void {
			this._type = "water";
			
			var attributes:Array = new Array();
			
			this._setAttributes(attributes);
			
			var material:ColorMaterial = new ColorMaterial(0x0000FF);
			
			var object:Sphere = new Sphere(material, 10);
			object.z -= 0.5 * 40 + 20;
			
			this.addChild(object);
		}
	}
}