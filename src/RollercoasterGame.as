package part1
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
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
		}
	}
		
	}