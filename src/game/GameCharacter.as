package game {
	import caurina.transitions.Tweener;
	
	public class GameCharacter {
		public var alive:Boolean = true;
		private var _container:GameCharacterObject;
		private var _moving:Boolean = false;
		private var _origin:Array;
		
		public function GameCharacter() {
			this._initCharacter3D();
		}
		
		private function _initCharacter3D():void {
			this._container = new GameCharacterObject();
		}
		
		public function moveToPoint(x:int, y:int):void {
			this._container.x = x;
			this._container.y = y;
		}
		
		public function animateToPoint(x:int, y:int, time:Number = 1):void {
			if (!this._moving) {
				this._moving = true;
				Tweener.addTween(this._container, {x: x, y: y, time: time, transition: "linear", onCompleteScope: this, onComplete: function():void { this._moving = false; }});
			}
		}
		
		public function animateForward(distance:int = 0):void {
			if (!this._moving) {
				this._moving = true;
				var x:int = this._container.x;
				var y:int = this._container.y;
				
				if (this._container.rotationZ === 0) { // Up
					y+=distance;
				} else if (this._container.rotationZ === 90) { // Left
					x-=distance;
				} else if (this._container.rotationZ === 180 || this._container.rotationZ === -180) { // Down
					y-=distance;
				} else if (this._container.rotationZ === -90) { // Right
					x+=distance;
				}
				Tweener.addTween(this._container, {x: x, y: y, time: 1, transition: "linear", onCompleteScope: this, onComplete: function():void { this._moving = false; }});
			}
		}
			
		public function animateDown(distance:int = 0):void {
			if (!this._moving) {
				this._moving = true;
				var z:int = this._container.z;
				z+=distance;
				
				Tweener.addTween(this._container, {z: z, time: 1, transition: "linear", onCompleteScope: this, onComplete: function():void { this._moving = false; }});
			}
		}
			
		public function animateUp(distance:int = 0):void {
			if (!this._moving) {
				this._moving = true;
				var z:int = this._container.z;
				z-=distance;
				
				Tweener.addTween(this._container, {z: z, time: 1, transition: "linear", onCompleteScope: this, onComplete: function():void { this._moving = false; }});
			}
		}
			
		public function reset():void {
			this.alive = true;
			this._moving = false;
			this._container.x = 0;
			this._container.y = 0;
			this._container.z = 0;
		}
			
		public function get container():GameCharacterObject {
			return this._container;
		}
		
		public function get moving():Boolean {
			return this._moving;
		}
	}
}