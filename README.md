#Rollercoaster Game Tutorial

In this short tutorial we are going to create a simple game, with a rollercoaster cart going along a pathway(rail), implmenting the basics to draw the rail and the movement physics. This little tutorial can be used to create games similar to the ones published on [rollercoaster games]. The tutorial is based on [actionscript.org examples][1].

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
		
In the next part of this tutorial we are going to use [Bezier curves] to paint the track and determine the trajectory of the rollercoaster cart.

[rollercoaster games]:http://rollercoastergames.net
[1]::http://www.actionscript.org/forums/showthread.php3?t=242191
[Bezier curves]:http://en.wikipedia.org/wiki/B%C3%A9zier_curve