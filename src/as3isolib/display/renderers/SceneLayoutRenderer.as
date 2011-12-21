package as3isolib.display.renderers
{
	import as3isolib.core.IIsoDisplayObject;
	import as3isolib.display.renderers.ISceneLayoutRenderer;
	import as3isolib.display.scene.IIsoScene;
	
	/**
	 * SceneLayoutRenderer
	 * 
	 * The optimised renderer, constrains: no overlap, no z-value
	 * @example 
	 * <code>
	 * // iso object is an object need to be re-depthed.
	 * SceneLayoutRenderer(isoScene.layoutRenderer).sort(isoObject);
	 * </code>
	 * @author xu.li<AthenaLightenedMyPath@gmail.com>
	 */
	public class SceneLayoutRenderer implements ISceneLayoutRenderer, IDepthComparer 
	{
		// the depth comparer to use
		private var _depthComparer:IDepthComparer;
		
		// the scene using this renderer
		private var _scene:IIsoScene;
		
		public function SceneLayoutRenderer(depthComparer:IDepthComparer = null)
		{
			_depthComparer = depthComparer ? depthComparer : this;
		}
		
		////////////////////////////////////////////////////
		//	RENDER SCENE
		////////////////////////////////////////////////////
		
		/**
		 * @inheritDoc
		 */
		public function renderScene (scene:IIsoScene):void
		{
			_scene = scene;
			
			var children:Array = scene.displayListChildren;
			var total:int = children.length;
			var sorted:Array = [];
			var i:int = 0;
			for (; i < total; ++i)
			{
				var added:Boolean = false;
				for (var j:int = 0; j < sorted.length; ++j)
				{
					if (_depthComparer.compare(children[i], sorted[j]))
					{
						sorted.splice(j, 0, children[i]);
						added = true;
						break;
					}
				}
				
				if (!added)
				{
					sorted.push(children[i]);
				}
			}
			
			for (i = 0; i < total; ++i)
			{
				scene.setChildIndex(sorted[i], i);
			}
		}
		
		/**
		 * Sort the depth for one iso display object
		 * @param	iso
		 */
		public function sort(iso:IIsoDisplayObject):void
		{
			if (iso == null || iso.parent == null || _scene == null)
			{
				return ;
			}
			
			var children:Array = _scene.displayListChildren;
			var idx:int = children.indexOf(iso);
			if (idx == -1)
			{
				return ;
			}
			
			// remove this first
			children.splice(idx, 1);
			var len:int = children.length;
			for (var i:int = 0; i < len; ++i)
			{
				if (_depthComparer.compare(iso, children[i]))
				{
					_scene.setChildIndex(iso, i);
					return ;
				}
			}
			
			_scene.setChildIndex(iso, len);
		}
		
		////////////////////////////////////////////////////
		//	Sort Function
		////////////////////////////////////////////////////
		public function compare(isoA:IIsoDisplayObject, isoB:IIsoDisplayObject):Boolean
		{
			return isoA.x < isoB.x + isoB.width && isoA.y < isoB.y + isoB.length;
		}

		/////////////////////////////////////////////////////////////////
		//	COLLISION DETECTION
		/////////////////////////////////////////////////////////////////
		
		private var collisionDetectionFunc:Function = null;
		
		/**
		 * @inheritDoc
		 */
		public function get collisionDetection ():Function
		{
			return collisionDetectionFunc;
		}
		
		/**
		 * @private
		 */
		public function set collisionDetection (value:Function):void
		{
			collisionDetectionFunc = value;
		}		
	}

}