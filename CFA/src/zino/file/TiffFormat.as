package zino.file
{
    import com.hurlant.util.Hex;

    public final class TiffFormat extends FileFormatBase implements IFileFormat
    {
        public function TiffFormat(endian:String = null)
        {
            super(endian);
        }

        public function save():void
        {
            if (!validate())
            {
                throw new VerifyError("Invaild IFD data.");
            }
            for (var i:uint = 0; i < _ifds.length; i++)
            {
                var obj:IFDList = _ifds[i];
                var next:uint = 0;
                if (i < _ifds.length - 1)
                {
                    next = _data.length + obj.bytesLength;
                }
                _data.writeBytes(obj.toBytes(_data.endian, _data.length, next));
            }
            trace(Hex.fromArray(_data));
        }

        private function validate():Boolean
        {
            if (_ifds.length == 0)
            {
                return false;
            }
            var ifd:IFDList = _ifds[0];
            var required:Array = [0x100, 0x101, 0x102, 0x103, 0x106, 0x111, 0x115, 0x116, 0x117, 0x11a, 0x11b, 0x128];
            while (required.length > 0)
            {
                var tag:uint = required.shift();
                if (!ifd.findTag(tag))
                {
                    return false;
                }
            }
            return true;
        }
    }
}
