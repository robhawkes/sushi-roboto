package game {
	

	public class GameCharacter {
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
		
		public function moveUp():void {
			this._container.moveDown(10);
		}
		
		public function moveDown():void {
			this._container.moveUp(10);
		}
		
		public function moveLeft():void {
			this._container.moveLeft(10);
		}
		
		public function moveRight():void {
			this._container.moveRight(10);
		}
		
		public function get container():GameCharacterObject {
			return this._container;
		}
	}
}