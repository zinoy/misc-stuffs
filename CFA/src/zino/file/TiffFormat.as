package zino.file
{
    import com.hurlant.util.Hex;

    import flash.events.Event;
    import flash.filesystem.*;
    import flash.utils.ByteArray;

    public final class TiffFormat extends FileFormatBase implements IFileFormat
    {
        private var data:ByteArray;

        public function TiffFormat(endian:String = null)
        {
            super(endian);
            var ifdl:IFDList = new IFDList();
            ifdl.addTag(0xfe, IFDType.LONG, 1, 0);
            ifdl.addTag(0x100, IFDType.SHORT, 1, 120);
            ifdl.addTag(0x101, IFDType.SHORT, 1, 100);
            ifdl.addTag(0x102, IFDType.SHORT, 3, [8, 8, 8]);
            ifdl.addTag(0x103, IFDType.SHORT, 1, 1);
            ifdl.addTag(0x106, IFDType.SHORT, 1, 2);
            ifdl.addTag(0x10f, IFDType.ASCII, "Canon");
            ifdl.addTag(0x110, IFDType.ASCII, "Canon EOS 7D");
            ifdl.addTag(0x111, IFDType.SHORT, 1, 0);
            ifdl.addTag(0x115, IFDType.SHORT, 1, 3);
            ifdl.addTag(0x116, IFDType.SHORT, 1, 100);
            ifdl.addTag(0x117, IFDType.SHORT, 1, 0);
            ifdl.addTag(0x11a, IFDType.RATIONAL, 1, [72, 1]);
            ifdl.addTag(0x11b, IFDType.RATIONAL, 1, [72, 1]);
            ifdl.addTag(0x128, IFDType.SHORT, 1, 2);
            ifdl.addTag(0x8769, IFDType.SHORT, 1, 2);
            _ifds.push(ifdl);
            data = new ByteArray();
            data.endian = endian;
        }

        public function save():void
        {
            if (_images.length == 0)
            {
                trace("Invaild image data.");
                    //throw new VerifyError("Invaild image data.");
            }
            if (!validate())
            {
                throw new VerifyError("Invaild IFD data.");
            }
            //calculate offsets
            var tl:uint = 0;
            for each (var list:IFDList in _ifds)
            {
                tl += list.bytesLength;
            }
            var il:uint = 0;
            for each (var imgdata:ByteArray in _imgData)
            {
                il += imgdata.length;
            }
            if (_exif)
            {
                if (_exifPos == ExifPosition.AFTER_IMAGE_DATA)
                {
                    _ifds[0].findTag(0x8769, true, IFDType.LONG).value = _data.length + tl + il;
                    _ifds[0].findTag(0x111).value = _data.length + tl;
                }
                else
                {
                    _ifds[0].findTag(0x8769, true, IFDType.LONG).value = _data.length + tl;
                    _ifds[0].findTag(0x111).value = _data.length + tl + _exif.bytesLength;
                }
            }
            data.writeBytes(_data);

            for (var i:uint = 0; i < _ifds.length; i++)
            {
                var obj:IFDList = _ifds[i];
                var next:uint = 0;
                if (i < _ifds.length - 1)
                {
                    next = data.length + obj.bytesLength;
                }
                data.writeBytes(obj.toBytes(data.endian, data.length, next));
            }
            //write EXIF data
            if (_exif && _exifPos != ExifPosition.AFTER_IMAGE_DATA)
            {
                data.writeBytes(_exif.toBytes(data.endian, data.length));
            }

            for each (var img:ByteArray in _imgData)
            {
                data.writeBytes(img);
            }
            //write EXIF data
            if (_exif && _exifPos == ExifPosition.AFTER_IMAGE_DATA)
            {
                data.writeBytes(_exif.toBytes(data.endian, data.length));
            }

            var file:File = new File();
            file.addEventListener(Event.SELECT, writeFile);
            file.browseForSave("Save to");
        }

        private function writeFile(e:Event):void
        {
            var file:File = File(e.target);
            var stm:FileStream = new FileStream();
            stm.open(file, FileMode.WRITE);
            stm.writeBytes(data);
            stm.close();
            data.clear();
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
