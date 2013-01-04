package zino
{
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import flash.net.*;
	import flash.events.Event;
	
	public class MainStage extends Sprite
	{
		private var _pattern:Array = [[0x0000ff,0x00ff00], [0x00ff00,0xff0000]];
		private var _bits:Array = [[0,8], [8,16]];
		private var _rect:Rectangle = new Rectangle(0,0,512,384);
		private var _file:FileReference;
		private var _pt:Bitmap;
		private var _bt:Bitmap;

		public function MainStage()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			init();
		}

		private function init():void
		{
			_file = new FileReference();
			_file.addEventListener(Event.SELECT,getimg);
			_file.browse([new FileFilter("图片文件 (*.jpg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif*.png")]);
			
			/*var pt:BitmapData = new BitmapData(_rect.width,_rect.height);
			var len:int = _pattern.length;
			for (var i:int=0; i<_rect.height; i++)
			{
				for (var j:int=0; j<_rect.width; j++)
				{
					var a:uint = Math.floor(Math.random()*0xff)<<24;
					pt.setPixel32(j,i,a+_pattern[i%len][j%len]);
				}
			}
			//pt.scaleX = pt.scaleY = 4;
			addChild(new Bitmap(pt));*/
			
			var btn:Sprite = new Sprite();
			btn.graphics.beginFill(0x0099cc);
			btn.graphics.drawRoundRect(0,0,20,20,5,5);
			btn.graphics.endFill();
			addChild(btn);
			btn.x = 520;
			btn.y = 370;
			btn.buttonMode = true;
			btn.addEventListener(MouseEvent.CLICK, demosicing);
		}
		
		private function getimg(e:Event):void
		{
			//var file:FileReference = FileReference(e.target);
			_file.addEventListener(Event.COMPLETE,loadimg);
			_file.load();
		}
		
		private function loadimg(e:Event):void
		{
			//var file:FileReference = FileReference(e.target);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,showimg);
			loader.loadBytes(_file.data);
		}
		
		private function showimg(e:Event):void
		{
			var loader:LoaderInfo = LoaderInfo(e.target);
			var bp:Bitmap = loader.content as Bitmap;
			var bd:BitmapData = bp.bitmapData;
			var pt:BitmapData = new BitmapData(_rect.width,_rect.height,false);
			_pt = new Bitmap(pt);
			var bt:BitmapData = new BitmapData(_rect.width,_rect.height,false);
			_bt = new Bitmap(bt);
			var len:int = _pattern.length;
			for (var i:int=0; i<_rect.height; i++)
			{
				for (var j:int=0; j<_rect.width; j++)
				{
					var c:uint = _pattern[i%len][j%len];
					var a:uint = bd.getPixel(j,i)&c;
					_pt.bitmapData.setPixel(j,i,a);
				}
			}
			addChild(_pt);
		}
		
		private function demosicing(e:MouseEvent):void
		{
			for (var i:int=0; i<_rect.height; i++)
			{
				for (var j:int=0; j<_rect.width; j++)
				{
					var c:uint = _pt.bitmapData.getPixel(j,i);
					var o:uint = calculate(j,i);
					_bt.bitmapData.setPixel(j,i,c+o);
				}
			}
			removeChild(_pt);
			addChild(_bt);
		}
		
		private function calculate(x:Number,y:Number):uint
		{
			var len:int = _pattern.length;
			var up:uint = getColor(x,y-1);
			var down:uint = getColor(x,y+1);
			var left:uint = getColor(x-1,y);
			var right:uint = getColor(x+1,y);
			if (_pattern[y%len][x%len] == 0x00ff00)
			{
				return (average(up,down)&getBits(x,y-1))+(average(left,right)&getBits(x-1,y));
			}
			else
			{
				var tl:uint = getColor(x-1,y-1);
				var tr:uint = getColor(x+1,y-1);
				var bl:uint = getColor(x-1,y+1);
				var br:uint = getColor(x+1,y+1);
				return (average(up,down,left,right)&getBits(x,y-1))+(average(tl,tr,bl,br)&getBits(x-1,y-1));
			}
		}
		
		private function getColor(x:Number,y:Number):uint
		{
			if (x < 0 || x >= _rect.width || y < 0 || y >= _rect.height)
			{
				return 0xffffff;
			}
			else
			{
				return _pt.bitmapData.getPixel(x,y);
			}
		}
		
		private function getBits(x:Number,y:Number):uint
		{
			var len:int = _pattern.length;
			x = Math.abs(x%len);
			y = Math.abs(y%len);
			return _pattern[y][x];
		}
		
		private function average(... args):uint{
			//trace(args);
			var sum:uint = 0;
			var len:int = 0;
			for (var i:uint = 0; i < args.length; i++) {
				if (args[i] < 0xffffff)
				{
					sum += args[i];
					len++;
				}
			}
			return uint(sum / len);
		}
		
	}

}