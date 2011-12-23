package as3isolib.display.renderers
{
	import as3isolib.core.IIsoDisplayObject;
	import as3isolib.core.IsoDisplayObject;
	import as3isolib.display.renderers.ISceneLayoutRenderer;
	import as3isolib.display.scene.IIsoScene;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
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
		
		// It's faster to make class variables & a method, rather than to do a local function closure
		private var _depth:uint;
		private var _visited:Dictionary;
		private var _scene:IIsoScene;
		private var _dependency:Dictionary;
		
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
			
			// Rewrite #2 by David Holz, dependency version (naive for now)
			// TODO - cache dependencies between frames, only adjust invalidated objects, keeping old ordering as best as possible
			// IIsoDisplayObject -> [obj that should be behind the key]
			_dependency = new Dictionary(true);
			
			// For now, use the non-rearranging display list so that the dependency sort will tend to create similar output each pass
			var children:Array = scene.displayListChildren;
			
			// Full naive cartesian scan, see what objects are behind child[i]
			// TODO - screen space subdivision to limit dependency scan
			var max:uint = children.length;
			var i:uint = 0;
			for (; i < max; ++i)
			{
				_dependency[children[i]] = new Dictionary(true);
			}
			
			for (i = 0; i < max; ++i)
			{
				var objA:IsoDisplayObject = children[i];
				
				for (var j:uint = i + 1; j < max; ++j)
				{
					var objB:IsoDisplayObject = children[j];
					if (_depthComparer.compare(objB, objA) < 0)
					{
						_dependency[objA][objB] = true;
					}
					else if (_depthComparer.compare(objA, objB) < 0)
					{
						_dependency[objB][objA] = true;
					}
				}
			}
			
			// Set the childrens' depth, using dependency ordering
			_depth = 0;
			_visited = new Dictionary(true);
			for each(var obj:IsoDisplayObject in children)
			{
				place(obj);
			}
			
			// clear out
			_dependency = null;
			
			//trace("After scene render: ");
			//for each (var isoB:IIsoDisplayObject in children)
			//{
				//trace(isoB.id + ": " + isoB.depth);
			//}
		}
		
		/**
		 * Dependency-ordered depth placement of the given objects and its dependencies.
		 */
		private function place(obj:IsoDisplayObject):void
		{
			if (obj in _visited)
			{
				return ;
			}
			
			_visited[obj] = true;
			
			for (var inner:Object in _dependency[obj])
			{
				place(inner as IsoDisplayObject);
			}
			
			if (_depth != obj.depth)
			{
				_scene.setChildIndex(obj, _depth);
			}
			
			++_depth;
		};
		
		/**
		 * 
		 * @param	iso
		 */
		public function redepth(iso:IIsoDisplayObject):void
		{
			var children:Array = _scene.displayListChildren;
			
			var i:int = children.indexOf(iso);
			if (i == -1)
			{
				return ;
			}
			
			children.splice(i, 1);
			var len:int = children.length;
			for (i = 0; i < len; ++i)
			{
				if (_depthComparer.compare(iso, children[i]) < 0)
				{
					//TODO we have to check the dependency of this object
					_scene.setChildIndex(iso, i);
					return ;
				}
			}
			_scene.setChildIndex(iso, i);
		}
		
		////////////////////////////////////////////////////
		//	Sort Function
		////////////////////////////////////////////////////
		public function compare(isoA:IIsoDisplayObject, isoB:IIsoDisplayObject):int
		{
			return (isoA.x < isoB.x + isoB.width && isoA.y < isoB.y + isoB.length) ? - 1 : 1;
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