package zino.file
{

    public final class IFDType
    {
        public static const BYTE:uint = 1;
        public static const ASCII:uint = 2;
        public static const SHORT:uint = 3;
        public static const LONG:uint = 4;
        public static const RATIONAL:uint = 5;
        public static const SBYTE:uint = 6;
        public static const UNDEFINED:uint = 7;
        public static const SSHORT:uint = 8;
        public static const SLONG:uint = 9;
        public static const SRATIONAL:uint = 10;
        public static const FLOAT:uint = 11;
        public static const DOUBLE:uint = 12;
        public static const OFFSETS:Array = [0, 1, 1, 2, 4, 8, 1, 1, 2, 4, 8, 4, 8];
    }
}
