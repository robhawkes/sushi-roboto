package game {
	/*
	* TODO: Perhaps introduce a more rigid system for attributes, where all attributes are individually defined
	*/
	public class GamePlayerObject extends GameObject {
		/* Physical attributes */
		private var _attributes:Array;
		
		public function GamePlayerObject() {
			super();
			this._interactive = true;
		}
		
		protected function _setAttributes(attributes:Array):void {
			this._attributes = attributes;
		}
		
		protected function _setAttribute(key:String, value:*):void {
			this._attributes[key] = value;
		}
		
		protected function _isAttribute(key:String):Boolean {
			if (this._attributes[key])
				return true;
			
			return false;
		}
		
		public function getAttribute(key:String):* {
			if (this._isAttribute(key))
				return this._attributes[key];
			
			return false;
		}
		
		public override function update():void {
			super.update();
		}
	}
}