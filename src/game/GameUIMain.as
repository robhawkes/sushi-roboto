package game {
	import caurina.transitions.Tweener;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	public class GameUIMain extends EventDispatcher {
		private var _mainMenu:MovieClip;
		private var _soundtrack:GameSound;
		private var _soundtrackChannel:SoundChannel;
		private var _soundtrackTransform:SoundTransform;
		private var _ui:MovieClip;
		
		public function GameUIMain() {
			this._ui = new MovieClip();
			
			this._mainMenu = new MainMenu();
			
			this._ui.addChild(this._mainMenu);
			this._ui.x -= this._ui.width;
			
			var logo:MovieClip = this._mainMenu.getChildByName("logo") as MovieClip;
			var logoImage:Bitmap = logo.getChildAt(0) as Bitmap;
			logoImage.smoothing = true;

			var level1Button:MovieClip = this._mainMenu.getChildByName("level1Button") as MovieClip;
			level1Button.addEventListener(MouseEvent.CLICK, this._onClickLevel1Button);
			
			var level2Button:MovieClip = this._mainMenu.getChildByName("level2Button") as MovieClip;
			level2Button.addEventListener(MouseEvent.CLICK, this._onClickLevel2Button);
			
			this._soundtrack = new GameSound(new URLRequest("resources/sounds/MainMenu.mp3"));
			this._soundtrackTransform = new SoundTransform(0.5);
		}
		
		private function _onClickLevel1Button(e:MouseEvent):void {
			dispatchEvent(new Event("GAME_LEVEL_1"));
		}
		
		private function _onClickLevel2Button(e:MouseEvent):void {
			dispatchEvent(new Event("GAME_LEVEL_2"));
		}
		
		public function hide():void {
			Tweener.addTween(this._ui, {x: -this._ui.width, time: 0.5, transition: "easeInOutExpo"});
			
			Tweener.addTween(this._soundtrackChannel, {_sound_volume: 0, time: 1, transition: "linear", onComplete: this._stopSoundtrack});
		}
		
		public function show():void {
			Tweener.addTween(this._ui, {x: 0, time: 0.5, transition: "easeInOutExpo"});

			this._playSoundtrack(0);
			Tweener.addTween(this._soundtrackChannel, {_sound_volume: 0.5, time: 4, transition: "linear"});
		}
		
		private function _playSoundtrack(volume:Number = 0.5):void {
			this._soundtrackChannel = this._soundtrack.play(0, 999, new SoundTransform(volume));
		}
		
		private function _stopSoundtrack():void {
			this._soundtrackChannel.stop();
		}
		
		public function get ui():MovieClip {
			return this._ui;
		}
	}
}