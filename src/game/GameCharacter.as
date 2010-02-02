package game {
	import caurina.transitions.Tweener;
	
	public class GameCharacter {
		private var _animated:Boolean = false;
		private var _container:GameCharacterObject;
		
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
		
		public function animateToPoint(x:int, y:int, time:Number = 0.5):void {
			Tweener.addTween(this._container, {x: x, y: y, time: time, transition: "linear"});
		}
		
		public function animateForward(distance:int = 0):void {
			if (!this._animated) {
				this._animated = true;
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
				Tweener.addTween(this._container, {x: x, y: y, time: 0.5, transition: "linear", onCompleteScope: this, onComplete: function():void { this._animated = false; }});
			}
		}
		
		public function animateBackward(distance:int = 0):void {
			if (!this._animated) {
				this._animated = true;
				Tweener.addTween(this._container, {y: this._container.y-distance, time: 0.5, transition: "linear", onCompleteScope: this, onComplete: function():void { this._animated = false; }});
			}
		}
		
		public function animateLeft(distance:int = 0):void {
			if (!this._animated) {
				this._animated = true;
				Tweener.addTween(this._container, {x: this._container.x-distance, time: 0.5, transition: "linear", onCompleteScope: this, onComplete: function():void { this._animated = false; }});
			}
		}
		
		public function animateRight(distance:int = 0):void {
			if (!this._animated) {
				this._animated = true;
				Tweener.addTween(this._container, {x: this._container.x+distance, time: 0.5, transition: "linear", onCompleteScope: this, onComplete: function():void { this._animated = false; }});
			}
		}
		
		public function get container():GameCharacterObject {
			return this._container;
		}
	}
}