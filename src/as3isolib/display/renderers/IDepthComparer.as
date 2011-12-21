package as3isolib.display.renderers
{
	import as3isolib.core.IIsoDisplayObject;
	
	/**
	 * Interface for a depth comparer
	 * @author xu.li<AthenaLightenedMyPath@gmail.com>
	 */
	public interface IDepthComparer 
	{
		/**
		 * Compare the depth of two iso display objects
		 * @param	isoA
		 * @param	isoB
		 * @return true if iso A is behind iso B, false otherwise
		 */
		function compare(isoA:IIsoDisplayObject, isoB:IIsoDisplayObject):Boolean;
	}
	
}