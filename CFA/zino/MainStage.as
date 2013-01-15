package zino
{
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import flash.net.*;
	import flash.events.Event;
	import flash.utils.*;
	
	public class MainStage extends Sprite
	{
		//private var _pattern:Array = [[0x0000ff,0x00ff00], [0x00ff00,0xff0000]];
		private var _pattern:Array = [[0xff0000,0x00ff00], [0x00ff00,0x0000ff]];//for Cannon EOS
		private var _bits:Array = [[0,8], [8,16]];
		private var _rect:Rectangle = new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
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
			
			var btn1:Sprite = new Sprite();
			btn1.graphics.beginFill(0xff66cc);
			btn1.graphics.drawRoundRect(0,0,20,20,5,5);
			btn1.graphics.endFill();
			addChild(btn1);
			btn1.x = 520;
			btn1.y = 340;
			btn1.buttonMode = true;
			btn1.addEventListener(MouseEvent.CLICK, mosicing);

			var btn2:Sprite = new Sprite();
			btn2.graphics.beginFill(0x0099cc);
			btn2.graphics.drawRoundRect(0,0,20,20,5,5);
			btn2.graphics.endFill();
			addChild(btn2);
			btn2.x = 520;
			btn2.y = 370;
			btn2.buttonMode = true;
			btn2.addEventListener(MouseEvent.CLICK, demosicing);
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
			_rect.width = bp.width;
			_rect.height = bp.height;
			
			var pt:BitmapData = bp.bitmapData.clone();
			_pt = new Bitmap(pt);
			var bt:BitmapData = new BitmapData(_rect.width,_rect.height,false,0);
			_bt = new Bitmap(bt);
			addChildAt(_pt,0);
		}
		
		private function mosicing(e:MouseEvent):void
		{
			var len:int = _pattern.length;
			var d:ByteArray = new ByteArray();
			d.endian = Endian.LITTLE_ENDIAN;
			d.writeShort(0x4949)
			d.writeShort(0x002a);
			d.writeUnsignedInt(0x8);
			d.writeShort(0xe);//Number of Interoperability
			
			d.writeShort(0xfe);
			d.writeShort(0x4);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0);
			
			d.writeShort(0x100);
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(uint(_rect.width));
			
			d.writeShort(0x101)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(uint(_rect.height));
			
			d.writeShort(0x102)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x3);
			d.writeUnsignedInt(0xb6);//BitsPerSample

			d.writeShort(0x103)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0x1);

			d.writeShort(0x106)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0x2);

			d.writeShort(0x111)
			d.writeShort(0x4);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0xcc);//StripOffsets

			d.writeShort(0x115)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0x3);

			d.writeShort(0x116)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(uint(_rect.height));//RowsPerStrip

			d.writeShort(0x117)
			d.writeShort(0x4);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(uint(_rect.width * _rect.height * 3));

			d.writeShort(0x11a)
			d.writeShort(0x5);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0xbc);//XResolution

			d.writeShort(0x11b)
			d.writeShort(0x5);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0xc4);//YResolution

			d.writeShort(0x128)
			d.writeShort(0x3);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0x2);
			
			d.writeShort(0x8769)
			d.writeShort(0x4);
			d.writeUnsignedInt(0x1);
			d.writeUnsignedInt(0x5eeccc);//Exif IFD Pointer

			d.writeUnsignedInt(0);
			
			d.writeShort(0x8);
			d.writeShort(0x8);
			d.writeShort(0x8);
			
			d.writeUnsignedInt(72);
			d.writeUnsignedInt(1);

			d.writeUnsignedInt(72);
			d.writeUnsignedInt(1);
			
			for (var i:int=0; i<_rect.height; i++)
			{
				for (var j:int=0; j<_rect.width; j++)
				{
					var c:uint = _pattern[i%len][j%len];
					var a:uint = _pt.bitmapData.getPixel(j,i)&c;
					_pt.bitmapData.setPixel(j,i,a);
					d.writeByte(a>>16);
					d.writeByte(a>>8);
					d.writeByte(a);
				}
			}
			removeChild(e.currentTarget as DisplayObject);
			
			d.writeShort(0x1)
			
			d.writeShort(0x9000)
			d.writeShort(0x7);
			d.writeUnsignedInt(0x4);
			d.writeMultiByte("0221","gb2312");
			
			d.writeUnsignedInt(0);
			
			trace((d.length-1).toString(16));
			
			var fs:FileReference = new FileReference();
			fs.addEventListener(Event.COMPLETE,saved);
			fs.save(d,".tif");
		}
		
		private function saved(e:Event):void
		{
			trace("Saved!");
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
			removeChild(e.currentTarget as DisplayObject);
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