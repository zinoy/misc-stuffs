package zino.file
{
    import flash.utils.ByteArray;

    import zino.*;

    public class IFDList
    {
        private var _list:Vector.<IFDObject>;

        public function IFDList()
        {
            _list = new Vector.<IFDObject>();
        }

        /**
         * Get the byte(8-bit) length of binary format;
         * @return
         *
         */
        public function get bytesLength():uint
        {
            var len:uint = 0;
            for each (var it:IFDObject in _list)
            {
                len += 12;
                if (it.length > 4)
                {
                    len += it.length;
                }
            }
            return len + 6;
        }

        /**
         * Add an item to list.
         * @param item Item to be added.
         * @return The new length of the list.
         *
         */
        public function push(item:IFDObject):uint
        {
            return _list.push(item);
        }

        /**
         * Create an IFDObject and add it to list.
         * @param tag Tag ID.
         * @param type Tag's type.
         * @param args Count(optional) and Value.
         * @return The new length of the list.
         *
         */
        public function addTag(tag:uint = 0, type:uint = 0, ... args):uint
        {
            var obj:IFDObject;
            if (args.length == 1)
            {
                obj = new IFDObject(tag, type, args[0]);
            }
            else
            {
                obj = new IFDObject(tag, type, args[0], args[1]);
            }
            return _list.push(obj);
        }

        public function findTag(tag:uint):IFDObject
        {
            for each (var it:IFDObject in _list)
            {
                if (it.tag == tag)
                {
                    return it;
                }
            }
            return null;
        }

        /**
         * Get binary format to write to file.
         * @param endian Changes or reads the byte order for the data; either Endian.BIG_ENDIAN or Endian.LITTLE_ENDIAN.
         * @param offset Offset before this IFD block.
         * @param next Offset of the next IFD block (if exist).
         * @return
         *
         */
        public function toBytes(endian:String = null, offset:uint = 0, next:uint = 0):ByteArray
        {
            var bytes:ByteArray = new ByteArray();
            if (endian)
            {
                bytes.endian = endian;
            }
            var values:Vector.<IFDObject> = new Vector.<IFDObject>();
            var lens:Array = [];
            var len:uint = _list.length * 12;
            var vl:uint = len + offset + 6;
            var it:IFDObject;
            bytes.writeShort(_list.length); //Number of Interoperability

            for each (it in _list)
            {
                bytes.writeShort(it.tag)
                bytes.writeShort(it.type);
                bytes.writeUnsignedInt(it.count);
                if (it.offset)
                {
                    values.push(it);
                    bytes.writeUnsignedInt(vl);
                    vl += it.length;
                }
                else
                {
                    switch (typeof(it.value))
                    {
                        case "string":
                            var bt:ByteArray = new ByteArray();
                            bt.endian = bytes.endian;
                            bt.writeUTFBytes(it.value);
                            fillWithBlank(bt, it.length, 0x20);
                            bytes.writeBytes(bt);
                            break;
                        default:
                            bytes.writeUnsignedInt(it.value);
                            break;
                    }
                }
            }
            bytes.writeUnsignedInt(next);

            for each (it in values)
            {
                var bv:ByteArray = new ByteArray();
                bv.endian = bytes.endian;
                var i:int, off:uint;
                switch (it.type)
                {
                    case IFDType.ASCII:
                        bv.writeUTFBytes(it.value);
                        fillWithBlank(bv, it.length);
                        break;
                    case IFDType.SHORT:
                        for (i = it.count - 1; i >= 0; i--)
                        {
                            off = IFDType.OFFSETS[it.type] * i * 8;
                            bv.writeShort(it.value >> off);
                        }
                        break;
                    case IFDType.LONG:
                        for (i = it.count - 1; i >= 0; i--)
                        {
                            off = IFDType.OFFSETS[it.type] * i * 8;
                            bv.writeUnsignedInt(it.value >> off);
                        }
                        break;
                    case IFDType.RATIONAL:
                        bv.writeUnsignedInt(it.value[0]);
                        bv.writeUnsignedInt(it.value[1]);
                        break;
                    case IFDType.UNDEFINED:
                        if (typeof(it.value) == "string")
                        {
                            bv.writeUTFBytes(it.value);
                            fillWithBlank(bv, it.length - 1, 0x20);
                            bv.writeByte(0);
                        }
                        break;
                    default:
                        for (i = it.count - 1; i >= 0; i--)
                        {
                            off = IFDType.OFFSETS[it.type] * i * 8;
                            bv.writeByte(it.value >> off);
                        }
                        break;
                }
                bytes.writeBytes(bv);
            }

            return bytes;
        }

        private function fillWithBlank(bytes:ByteArray, length:uint, blank:int = 0):void
        {
            length -= bytes.length;
            while (length > 0)
            {
                bytes.writeByte(blank);
                length--;
            }
        }
    }
}
