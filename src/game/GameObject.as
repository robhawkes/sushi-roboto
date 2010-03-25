package game {
	import flash.media.SoundTransform;
	
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.Collada;
	import org.papervision3d.objects.parsers.DAE;

	public class GameObject extends DisplayObject3D {
		protected var _collada:DAE; 
		protected var _interactive:Boolean = false;
		protected var _interactiveObject:DisplayObject3D;
		protected var _ambientSound:GameSound;
		protected var _killSound:GameSound;
		protected var _type:String; 
		
		public function GameObject() {
			super();
		}
		
		public function update():void {
			
		}
		
		public function playAmbientSound():void {
			if (this._ambientSound)
				this._ambientSound.play(0, 999, new SoundTransform(0.1));
		}
		
		public function playKillSound():void {
			if (this._killSound)
				this._killSound.play(0, 1, new SoundTransform(1));
		}
		
		public function get collada():DAE {
			return this._collada;
		}
		
		public function get interactiveObject():DisplayObject3D {
			return this._interactiveObject;
		}
		
		public function get type():String {
			return this._type;
		}
	}
}