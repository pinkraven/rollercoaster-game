package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import bezier.BezierAssist;
	import bezier.TrajectoryPoint;
	
	public class RollercoasterGame extends Sprite
	{
		
		// a separate movieclip where we can draw the track:
		private var track:MovieClip = new MovieClip();
		
		// a parameter which indicates the lengths of a segment;
		private var SEGMENT_LENGTH:Number = 60;
		
		// the points defining the segments
		private var segmentPoints:Array;
		
		// the last point added when moving the mouse
		private var currentPoint:Point;
		
		// when true it mean the mouse button is down and the player draws segments
		private var drawing:Boolean = false;
		
		// keeps the intermediate bezier points from the bezier curve
		private var bezierLines:Vector.<TrajectoryPoint>;
		
		public function RollercoasterGame()
		{	
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);		
		}
		
		private function mouseDown(e:Event):void {
			segmentPoints = [];
			
			
			drawing = true;
			
			this.graphics.clear();
			
			
			currentPoint = new Point(mouseX, mouseY);
			segmentPoints.push(currentPoint);
			
			this.graphics.lineStyle(1, 0xCCCCCC);
			this.graphics.moveTo(0, mouseY);
			this.graphics.lineTo(2000, mouseY);
		}
		
		private function mouseMove(e:Event):void {
			if (!drawing) return;
			
			var dx:Number = mouseX - currentPoint.x;
			var dy:Number = mouseY - currentPoint.y;
			var d:Number = Math.sqrt( dx * dx + dy * dy );
			
			if (d >= SEGMENT_LENGTH) 
			{
				var a:Number = Math.atan2(dy, dx);
				currentPoint = new Point(currentPoint.x + SEGMENT_LENGTH * Math.cos(a), currentPoint.y+ SEGMENT_LENGTH * Math.sin(a));
				segmentPoints.push(currentPoint);
				
				this.graphics.lineTo(segmentPoints[segmentPoints.length-2].x, segmentPoints[segmentPoints.length-2].y);
				this.graphics.lineTo(currentPoint.x, currentPoint.y);
			}
		}
		
		
		private function mouseUp(e:Event):void 
		{	
			segmentPoints.push(new Point(mouseX, mouseY));
			this.graphics.lineTo(mouseX, mouseY);
			
			drawing = false;
			
			generateBezier();
		}
		
		private function generateBezier():void
		{
			bezierLines = new Vector.<TrajectoryPoint>();
			
			var p1:Point, p2:Point, p3:Point, mid1:Point, mid2:Point;
			
			p1 = BezierAssist.linearBezierPoint([segmentPoints[0], segmentPoints[1]], 0.5);
						
			bezierLines.push( new TrajectoryPoint(segmentPoints[0].x, segmentPoints[0].y));// {x: segmentPoints[0].x, y: segmentPoints[0].y});
			
			for (var i:Number=0; i < segmentPoints.length-2; i++) 
			{
				p1 = segmentPoints[i];
				p2 = segmentPoints[i+1];
				p3 = segmentPoints[i+2];
				mid1 = BezierAssist.linearBezierPoint([p1, p2], 0.5);
				mid2 = BezierAssist.linearBezierPoint([p2, p3], 0.5);
				
				bezierLines = bezierLines.concat(BezierAssist.bezier([mid1, p2, mid2], 20));
				
				track.graphics.lineTo(p3.x, p3.y);
			}
			
			bezierLines.push(new TrajectoryPoint(p3.x, p3.y) );

			// draw bezier curve
			this.graphics.lineStyle(1,0x000000);
			this.graphics.moveTo(bezierLines[0].x, bezierLines[0].y);
			for each (var p:TrajectoryPoint in bezierLines)
				this.graphics.lineTo(p.x, p.y);

			track.graphics.lineTo(p3.x, p3.y);
			
			for (i=0; i < bezierLines.length-1; i++) {
				var a:TrajectoryPoint = bezierLines[i];
				var b:TrajectoryPoint = bezierLines[i+1];
				a.dx = b.x - a.x;
				a.dy = b.y - a.y;
				a.a = Math.atan2(a.dy, a.dx);
			}
			
			bezierLines.pop();

		}
		
		

		
	}
	
}