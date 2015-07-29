#Rollercoaster Game Tutorial

![Alt text](/bin-release/rollercoaster-screenshot.png?raw=true "Rollercoaster Physics Screenshot")

In this short tutorial we are going to create a simple game, with a rollercoaster cart going along a pathway(rail), implmenting the basics to draw the rail and the movement physics. This little tutorial can be used to create games similar to the ones published on [rollercoaster games]. The tutorial is based on actionscript.org [examples][1].

1. Define Rollercoaster Track Drawing Segments
2. Build the Rail Using Bezier Curves
3. Add the Rollercoaster Cart

###Define Rollercoaster Track Drawing Segments

In the first part of the tutorial we are adding the code which allows us to draw the segments to define the rollercoaster rail. At this stage it doesn't look like a rollercoaster game, it's just an empy stage where the player can can draw segments. For the begining we are creating the main class and we add the listeners for MouseDown, MouseUp and MouseMove events and we create the functions to handle those events.

	public class RollercoasterTest1 extends Sprite
	{		
		public function RollercoasterTest1()
		{	
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);		
		}
		
		private function mouseDown(e:Event):void {
    	}
		
		private function mouseMove(e:Event):void {
		}
		
		
		private function mouseUp(e:Event):void {	
		}
	}
		
Now that we have the basic structure for the class we add the member variables we need to use for the drawing the rollercoaster track. The comments are self-explanatory:

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

Now we add the to mouseDown to initiate the drawing process:

		private function mouseDown(e:Event):void {

			// activate the drawing mode
			drawing = true;
			
			// clear the existing points
			segmentPoints = [];
			this.graphics.clear();
			
			// add the current mouse position as the initial point
			currentPoint = new Point(mouseX, mouseY);
			segmentPoints.push(currentPoint);
			
			// draw a horizontal line to show the starting height 
			this.graphics.lineStyle(1, 0xCCCCCC);
			this.graphics.moveTo(0, mouseY);
			this.graphics.lineTo(2000, mouseY);
		} 
		
Then when the mouse gets moved, if the drawing mode is active, we check to see if the distance from the new mouse position to the last segment point is longer than SEGMENT_LENGTH. If it it, it means we have to add a new segment point to the list:

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
				
				this.graphics.lineTo(currentPoint.x, currentPoint.y);
			}
		}

Now we have to take in consideration what happens when the mouse is up. We add the last point to the segmens and set the drawing flag as innactive:

		private function mouseUp(e:Event):void 
		{	
			segmentPoints.push(new Point(mouseX, mouseY));
			this.graphics.lineTo(mouseX, mouseY);
			
			drawing = false;
		}
		

###Build the Rail Using Bezier Curves

In this part of the tutorial we use [Bezier curves] to paint the track and determine the trajectory of the rollercoaster cart. Bezier curves are parametric curves(paths) which are used to smooth curves and segments. Along with the smoothness affine transformations such as translation and rotation can be applied on the curves which makes them extremely useful in animations.

For our case we create 2 new classes [BezierAssist] and [TrajectoryPoint](at this stage the trajectory point keeps only a point, in the next part it will handle the rotation and the acceleration information). The BezzierAssist contains the encapsulate the logic to generate a bezier curve for a group of points/segments. If we have 2 points it is called linear, for 3 quadratic and for 4 points it's cubic(we don't use the last one). The method above returns the coordinates of the bezier point at the "moment" t(we don't generate an actual curve but just a set of points and t represents the actual step to generate the respective point). The Bezier algorithm is implemented in linearBezierPoint and quadraticBezierPoint. Just take a look on the [BezierAssist] class to see it.

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

Now that we have the methods to generate an intermediate point on Bezier curve we need the method to give us all the points for a segment:

		static public function bezier(p:Array, segments:Number):Vector.<TrajectoryPoint> {
			if (segments < 1) null;
			
			if (p.length < 2 || p.length > 4) 
				return null;
			
			var points:Vector.<TrajectoryPoint> = new Vector.<TrajectoryPoint>();
			
			var dt:Number = 1/segments;
			var s:Point = BezierAssist.bezierPoint(p, 0);
			
			for (var i:Number=1; i<=segments; i++) 
			{
				s = BezierAssist.bezierPoint(p, i*dt);
				
				points.push( new TrajectoryPoint( s.x, s.y) );
			}
			
			return points;
		}		

The changes in the main class are not so complex. We just add a new vector member to keep all the intermediate bezier points of the curve:


		private var bezierLines:Vector.<TrajectoryPoint>;
		
... along with the method to generate the intermediate bezier points. This method might be latter on split in 2 or more methods but for the moment we keep it as it is:

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


		
[rollercoaster games]:http://rollercoastergames.net
[1]::http://www.actionscript.org/forums/showthread.php3?t=242191
[Bezier curves]:http://en.wikipedia.org/wiki/B%C3%A9zier_curve
[BezierAssist]:https://github.com/pinkraven/rollercoaster-game/blob/master/src/bezier/BezierAssist.as
[TrajectoryPoint]:https://github.com/pinkraven/rollercoaster-game/blob/master/src/bezier/TrajectoryPoint.as