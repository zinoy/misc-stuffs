package zino.file
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    public class FileFormatBase
    {
        protected var _data:ByteArray;
        protected var _imgData:Vector.<ByteArray>;
        protected var _ifds:Vector.<IFDList>;
        protected var _exif:IFDList;
        protected var _exifPos:uint = 0;
        protected var _images:Array;

        public function FileFormatBase(endian:String = null)
        {
            _data = new ByteArray();
            _imgData = new Vector.<ByteArray>();
            _ifds = new Vector.<IFDList>();
            _images = [];

            if (endian)
            {
                _data.endian = endian;
            }
            if (_data.endian == Endian.LITTLE_ENDIAN)
            {
                _data.writeShort(0x4949);
            }
            else
            {
                _data.writeShort(0x4d4d);
            }
            _data.writeShort(0x002a);
            _data.writeUnsignedInt(0x8);
        }

        public function get exifPosition():uint
        {
            return _exifPos;
        }

        public function set exifPosition(value:uint):void
        {
            _exifPos = value;
        }

        public function get endian():String
        {
            return _data.endian;
        }

        public function get exif():IFDList
        {
            return _exif;
        }

        public function set exif(value:IFDList):void
        {
            _exif = value;
        }

        public function addIFD(ifd:IFDList):void
        {
            if (_ifds.length == 0 && _images.length > 0)
            {
                ifd.findTag(0x100).value = _images[0].width;
                ifd.findTag(0x101).value = _images[0].height;
                ifd.findTag(0x116).value = _images[0].height;
                var len:uint = 0;
                for each (var b:ByteArray in _imgData)
                {
                    len += b.length;
                }
                ifd.findTag(0x117).value = len;
            }

            _ifds.push(ifd);
        }

        public function getIFD(idx:uint):IFDList
        {
            return _ifds[idx];
        }

        public function writeImageData(bitmap:BitmapData):void
        {
            var d:ByteArray = new ByteArray();

            _images.push(bitmap);
            for (var i:uint; i < bitmap.height * bitmap.width; i++)
            {
                var x:uint = i % bitmap.width;
                var y:uint = Math.floor(i / bitmap.width);
                var c:uint = bitmap.getPixel(x, y);
                if (y == 1)
                {
                    trace(i);
                }
                d.writeByte(c >> 16);
                d.writeByte(c >> 8);
                d.writeByte(c);
            }
            _imgData.push(d);

            if (_ifds.length > 0)
            {
                _ifds[0].findTag(0x100).value = bitmap.width;
                _ifds[0].findTag(0x101).value = bitmap.height;
                _ifds[0].findTag(0x116).value = bitmap.height;
                var len:uint = _ifds[0].findTag(0x117).value;
                _ifds[0].findTag(0x117).value = len + d.length;
            }
        }

    }
}
