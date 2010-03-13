package game {
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.support.pv3d.FLARCamera3D;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.render.LazyRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;

	public class GamePapervision {
		/* Papervision Camera3D pointer */ 
		private var _camera:Camera3D;
		/* Papervision PointLight3D pointer */
		private var _pointLight:PointLight3D;
		/* Papervision render engine pointer */
		private var _renderer:LazyRenderEngine;
		/* Papervision Scene3D pointer */
		private var _scene:Scene3D;
		/* Papervision Viewport3D pointer */
		private var _viewport:Viewport3D;
		
		public function GamePapervision() {		
			/* Initialise a new Papervision scene */
			this._scene = new Scene3D();
			
			/* Initialise a new FLARCamera3D object to enable full AR goodness */
			this._camera = new Camera3D();
			
			/* Define a new Papervision viewport object */
			this._viewport = new Viewport3D(640, 480, true, true);
			
			/* Define a new Papervision point light */
			this._pointLight = new PointLight3D(true, false);
			/* Set light position */
			this._pointLight.x = 1000;
			this._pointLight.y = 1000;
			this._pointLight.z = -1000;
			/* Add light to the Papervision scene */
			this._scene.addChild(this._pointLight);
			
			/* Initialise the Papervision render engine */
			this._renderer = new LazyRenderEngine(this._scene, this._camera, this._viewport);
		}
		
		public function setFLARCamera(cameraParams:FLARParam):void {
			this._camera = new FLARCamera3D(cameraParams);
			this._renderer.camera = this._camera;
		}
		
		public function addChildToScene(displayObject:DisplayObject3D):void {
			this._scene.addChild(displayObject);
		}
		
		public function removeChildFromScene(displayObject:DisplayObject3D):void {
			this._scene.removeChild(displayObject);
		}
		
		public function render():void {
			this._renderer.render();
		}
		
		public function get viewport():Viewport3D {
			return this._viewport;
		}
		
		public function resetViewport():void {
			this._viewport = this._viewport = new Viewport3D(640, 480, true, true);
			this._renderer.viewport = this._viewport;
		}
	}
}