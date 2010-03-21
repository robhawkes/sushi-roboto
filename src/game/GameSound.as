package game {
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	
	public class GameSound extends Sound {
		public function GameSound(stream:URLRequest=null, context:SoundLoaderContext=null){
			super(stream, context);
			
		}
	}
}