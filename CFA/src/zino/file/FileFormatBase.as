package zino.file
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    public class FileFormatBase
    {
        protected var _data:ByteArray;
        protected var _images:Vector.<ByteArray>;
        protected var _ifds:Vector.<IFDList>;

        public function FileFormatBase(endian:String = null)
        {
            _data = new ByteArray();
            _images = new Vector.<ByteArray>();
            _ifds = new Vector.<IFDList>();

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

        public function get endian():String
        {
            return _data.endian;
        }

        public function addIFD(ifd:IFDList):void
        {
            _ifds.push(ifd);
        }

        public function getIFD(idx:uint):IFDList
        {
            return _ifds[idx];
        }

        public function addImageData(bytes:ByteArray):void
        {
            _images.push(bytes);
        }
    }
}
