package game {
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.support.pv3d.FLARCamera3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.render.LazyRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;

	public class GamePapervision {
		/* Papervision Scene3D pointer */
		public var scene:Scene3D;
		/* Papervision Viewport3D pointer */
		public var viewport:Viewport3D;
		/* FLARToolkit FLARCamera3D pointer */ 
		public var camera:FLARCamera3D;
		/* Papervision render engine pointer */
		private var renderer:LazyRenderEngine;
		/* Papervision PointLight3D pointer */
		private var pointLight:PointLight3D;
		
		public function GamePapervision(cameraParams:FLARParam) {
			/* Initialise a new Papervision scene */
			this.scene = new Scene3D();
			
			/* Initialise a new FLARCamera3D object to enable full AR goodness */
			this.camera = new FLARCamera3D(cameraParams);
			
			/* Define a new Papervision viewport object */
			this.viewport = new Viewport3D(640, 480, true, true);
			
			/* Define a new Papervision point light */
			this.pointLight = new PointLight3D(true, false);
			/* Set light position */
			this.pointLight.x = 1000;
			this.pointLight.y = 1000;
			this.pointLight.z = -1000;
			/* Add light to the Papervision scene */
			this.scene.addChild(pointLight);
			
			/* Initialise the Papervision render engine */
			this.renderer = new LazyRenderEngine(this.scene, this.camera, this.viewport);
		}
		
		public function render():void {
			this.renderer.render();
		}
	}
}