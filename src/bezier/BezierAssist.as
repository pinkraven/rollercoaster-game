package bezier
{
	import flash.geom.Point;

	public class BezierAssist
	{
		public static function linearBezierPoint(p:Array, t:Number):Point 
		{
			if ( t < 0 || t > 1 || p.length != 2 ) return null;
			
			return new Point(
				p[0].x + ( p[1].x - p[0].x ) * t,
				p[0].y + ( p[1].y - p[0].y ) * t
			);
		};
		
		public static function quadraticBezierPoint(p:Array, t:Number):Point 
		{
			if (t < 0 || t > 1 || p.length != 3) return null;
			
			var ax:Number, bx:Number;
			bx = 2*(p[1].x-p[0].x);
			ax = p[2].x - p[0].x - bx;
			
			var ay:Number, by:Number;
			by = 2*(p[1].y - p[0].y);
			ay = p[2].y - p[0].y - by;
			
			var t2:Number = t*t;
			
			return new Point(
				ax*t2 + bx*t + p[0].x,
				ay*t2 + by*t + p[0].y
			);
		};		
		
		public static function bezierPoint(p:Array, t:Number):Point 
		{
			if (p.length == 2) 
				return linearBezierPoint(p, t);		
			if (p.length == 3) 
				return quadraticBezierPoint(p, t);
			if (p.length == 4) 
				return quadraticBezierPoint(p,t);//cubicBezierPoint(p, t);
			
			return null;
		}
		
		
	}
}