package game {
	public class GameRegistry {
		private static var _instance:GameRegistry;
		private var _register:Array;
		
		public function GameRegistry(se:SingletonEnforcer) {
			if (!se)
				throw(new Error("Use GameRegistry.getInstance() instead"));
			
			_register = new Array();
		}
		
		public function setEntry(key:String, item:*):void {
			this._register[key] = item;
		}
		
		public function getEntry(key:String):* {
			return this._register[key];
		}

		
		public function isEntry(key:String):Boolean {
			return (this._register[key] !== null);
		}
		
		public static function getInstance():GameRegistry {
			if (!_instance)
				_instance = new GameRegistry(new SingletonEnforcer());
			
			return _instance;
		}
	}
}
class SingletonEnforcer {}