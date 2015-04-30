package bezier
{
	public class TrajectoryPoint
	{
		public function TrajectoryPoint(xx:Number, yy:Number)
		{
			this.x = xx;
			this.y = yy;
		}
		
		public var x:Number;
		public var y:Number;
		public var dx:Number;
		public var dy:Number;
		public var a:Number;
		
		
	}
}