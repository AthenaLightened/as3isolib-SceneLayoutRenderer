package 
{
	import as3isolib.core.IsoDisplayObject;
	import as3isolib.display.IsoSprite;
	import as3isolib.display.IsoView;
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.primitive.IsoRectangle;
	import as3isolib.display.renderers.SceneLayoutRenderer;
	import as3isolib.display.scene.IIsoScene;
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.display.scene.IsoScene;
	import as3isolib.geom.Pt;
	import as3isolib.graphics.SolidColorFill;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author lixu <athenalightenedmypath@gmail.com>
	 */
	public class Demo extends Sprite 
	{
		public static const CELL_SIZE:int = 25;
		
		private var _isoView:IsoView;
		private var _isoScene:IsoScene;
		private var _isoBox:IsoBox;
		
		public function Demo():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			
			_isoView = new IsoView();
			_isoView.setSize(stage.stageWidth, stage.stageHeight);
			_isoView.panBy(0, 200);
			_isoView.addScene(new IsoScene());
			_isoView.scenes[0].addChild(new IsoGrid());
			IsoGrid(_isoView.scenes[0].getChildAt(0)).setGridSize(30, 30);
			
			_isoScene = new IsoScene();
			_isoScene.layoutRenderer = new SceneLayoutRenderer();
			_isoView.addScene(_isoScene);
			
			_isoBox = addBox(_isoScene, 'hero', new SolidColorFill(0xff0000, 0.6), 0, 0, 1, 1);
			
			var fill:SolidColorFill = new SolidColorFill(0xff9876, 1);
			for (var i:int = 0; i < 15;++i)
			{
				for (var j:int = 0; j < 15; ++j)
				{
					addBox(_isoScene, "box_" + j + "_" + i, fill, j * 2, i * 2, 1, 1);
				}
			}
			
			
			//addBox(_isoScene, 'yellow', new SolidColorFill(0xffff00, 1), 5, 2, 1, 2);
			//addBox(_isoScene, 'purple', new SolidColorFill(0xff00ff, 1), 3, 6, 1, 1);
			//addBox(_isoScene, 'green', new SolidColorFill(0x00ff00, 1), 4, 3, 1, 4);
			
			addChild(_isoView);
			_isoView.render(true);
			_isoView.addEventListener(MouseEvent.MOUSE_MOVE, onIsoViewMouseMove);
		}
		
		private function onIsoViewMouseMove(e:MouseEvent):void 
		{
			var point:Pt = _isoView.localToIso(_isoView.globalToLocal(new Point(e.stageX, e.stageY)));
			_isoBox.x = point.x;
			_isoBox.y = point.y;
			_isoBox.render(false);
			
			SceneLayoutRenderer(_isoScene.layoutRenderer).redepth(_isoBox);
			
			//_isoScene.render(false);
		}
		
		
		private function addBox(container:IIsoScene, name:String, color:SolidColorFill, x:Number, y:Number, width:int, length:int):IsoBox
		{
			var box:IsoBox = new IsoBox( { id: name, x: x * CELL_SIZE, y: y * CELL_SIZE, z: 0, width: width * CELL_SIZE, height: CELL_SIZE, length: length * CELL_SIZE } );
			box.fill = color;
			box.container.cacheAsBitmap = true;
			container.addChild(box);
			return box;
		}
	}
	
}