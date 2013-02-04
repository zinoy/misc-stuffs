package zino.file
{
    import flash.utils.ByteArray;

    import zino.*;

    public class IFDList
    {
        private var _list:Vector.<IFDObject>;
        private var _endian:String;

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

        public function findTag(tag:uint, create:Boolean = false, type:uint = 7, count:uint = 1):IFDObject
        {
            for each (var it:IFDObject in _list)
            {
                if (it.tag == tag)
                {
                    return it;
                }
            }
            if (create)
            {
                var obj:IFDObject = new IFDObject(tag, type, count, 0);
                _list.push(obj);
                return obj;
            }
            return null;
        }

        /**
         * Get binary data.
         * @param endian Changes or reads the byte order for the data; either Endian.BIG_ENDIAN or Endian.LITTLE_ENDIAN.
         * @param offset Offset before this IFD block.
         * @param next Offset of the next IFD block (if exist).
         * @return ByteArray data.
         *
         */
        public function toBytes(endian:String = null, offset:uint = 0, next:uint = 0):ByteArray
        {
            var bytes:ByteArray = new ByteArray();
            if (endian)
            {
                bytes.endian = _endian = endian;
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
                    if (typeof(it.value) == "string")
                    {

                        var bt:ByteArray = new ByteArray();
                        bt.endian = bytes.endian;
                        bt.writeUTFBytes(it.value);
                        fillWithBlank(bt, it.length, 0x20);
                        bytes.writeBytes(bt);
                    }
                    else
                    {
                        if (it.count > 1)
                        {
                            bytes.writeBytes(getBinaryValue(it));
                        }
                        else
                        {
                            bytes.writeUnsignedInt(it.value);
                        }
                    }
                }
            }
            bytes.writeUnsignedInt(next);

            for each (it in values)
            {
                bytes.writeBytes(getBinaryValue(it));
            }

            return bytes;
        }

        private function getBinaryValue(obj:IFDObject):ByteArray
        {
            var bv:ByteArray = new ByteArray();
            bv.endian = _endian;
            var i:int, off:uint;
            switch (obj.type)
            {
                case IFDType.ASCII:
                    bv.writeUTFBytes(obj.value);
                    fillWithBlank(bv, obj.length);
                    break;
                case IFDType.SHORT:
                    for (i = 0; i < obj.count; i++)
                    {
                        //off = IFDType.OFFSETS[obj.type] * i * 8;
                        bv.writeShort(obj.value[i]);
                    }
                    break;
                case IFDType.LONG:
                    for (i = 0; i < obj.count; i++)
                    {
                        bv.writeUnsignedInt(obj.value[i]);
                    }
                    break;
                case IFDType.RATIONAL:
                    bv.writeUnsignedInt(obj.value[0]);
                    bv.writeUnsignedInt(obj.value[1]);
                    break;
                case IFDType.UNDEFINED:
                    if (typeof(obj.value) == "string")
                    {
                        bv.writeUTFBytes(obj.value);
                        fillWithBlank(bv, obj.length - 1, 0x20);
                        bv.writeByte(0);
                    }
                    break;
                default:
                    for (i = 0; i < obj.count; i++)
                    {
                        bv.writeByte(obj.value[i]);
                    }
                    break;
            }
            return bv;
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
