package zino.file
{

    public final class IFDObject
    {
        private var _tag:uint;
        private var _type:uint;
        private var _count:uint;
        private var _value:*;
        private var _offset:Boolean = false;

        public function IFDObject(tag:uint = 0, type:uint = 0, value:* = null, count:uint = 0)
        {
            _tag = tag;
            _type = type;
            _count = count;
            this.value = value;
            if (this.length > 4)
            {
                _offset = true;
            }
        }

        public function get tag():uint
        {
            return _tag;
        }

        public function set tag(value:uint):void
        {
            _tag = value;
        }

        public function get type():uint
        {
            return _type;
        }

        public function set type(value:uint):void
        {
            _type = value;
        }

        public function get count():uint
        {
            return _count;
        }

        public function set count(value:uint):void
        {
            _count = value;
        }

        public function get value():*
        {
            return _value;
        }

        public function set value(value:*):void
        {
            _value = value;
            if (_count == 0)
            {
                if (typeof(_value) == "string")
                {
                    if (_type == IFDType.ASCII)
                    {
                        _count = _value.length + 1;
                    }
                    else
                    {
                        _count = _value.length;
                    }
                }
            }
            if (this.length > 4)
            {
                _offset = true;
            }
        }

        public function get offset():Boolean
        {
            return _offset;
        }

        public function set offset(value:Boolean):void
        {
            _offset = value;
        }

        public function get length():uint
        {
            return IFDType.OFFSETS[_type] * _count;
        }
    }
}
