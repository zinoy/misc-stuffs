package zino
{

    public class Utility
    {
        public static function sum(arr:Array):Number
        {
            if (arr.length == 0)
            {
                return 0;
            }
            var s:Number = 0;
            for (var i in arr)
            {
                var n:Number = Number(arr[i]);
                if (!isNaN(n))
                {
                    s += n;
                }
            }
            return s;
        }
    }
}
