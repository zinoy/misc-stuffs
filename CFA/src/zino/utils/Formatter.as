package zino.utils
{

    public class Formatter
    {
        public static function formatDateTime(date:Date, format:String):String
        {
            var datetime:String = format;
			var y:Array = /Y+/.exec(datetime);
            if (y[0].length == 2)
            {
                datetime=datetime.replace(/Y+/, date.getFullYear().toString().substr(2));
            }
            else if (y[0].length == 4)
            {
				datetime=datetime.replace(/Y+/, date.getFullYear());
            }
            else if (y[0].length > 4)
            {
				datetime=datetime.replace(/Y+/, formatNumber(date.getFullYear(), y[0].length));
            }
			
            var m:Array = /M+/.exec(datetime);
            var marr:Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
            if (m[0].length == 1)
            {
				datetime=datetime.replace(/M+/, date.getMonth() + 1);
            }
            else if (m[0].length == 2)
            {
				datetime=datetime.replace(/M+/, formatNumber(date.getMonth() + 1, 2));
            }
            else if (m[0].length == 3)
            {
				datetime=datetime.replace(/M+/, marr[date.getMonth()].substr(0, 3));
            }
            else if (m[0].length == 4)
            {
				datetime=datetime.replace(/M+/, marr[date.getMonth()]);
            }
			
			var d:Array = /D+/.exec(datetime);
			if (d[0].length == 1)
			{
				datetime=datetime.replace(/D+/, date.getDate());
			}
			else if (d[0].length == 2)
			{
				datetime=datetime.replace(/D+/, formatNumber(date.getDate(), 2));
			}
			
			var j:Array = /J+/.exec(datetime);
			if (j[0].length == 1)
			{
				datetime=datetime.replace(/J+/, date.getHours());
			}
			else if (j[0].length == 2)
			{
				datetime=datetime.replace(/J+/, formatNumber(date.getHours(), 2));
			}

			var n:Array = /N+/.exec(datetime);
			if (n[0].length == 1)
			{
				datetime=datetime.replace(/N+/, date.getMinutes());
			}
			else if (n[0].length == 2)
			{
				datetime=datetime.replace(/N+/, formatNumber(date.getMinutes(), 2));
			}

			var s:Array = /S+/.exec(datetime);
			if (s[0].length == 2)
			{
				datetime=datetime.replace(/S+/, formatNumber(date.getSeconds(), 2));
			}
			return datetime;
        }

        public static function formatNumber(num:Number, format:*):String
        {
            var number:String;
            if ((typeof format) == "string")
            {
                number = format;
            }
            else if (typeof format == "number")
            {
                number = num.toString();
                while (number.length < format)
                {
                    number = "0" + number;
                }
            }
            else
            {
                return null;
            }
            return number;
        }
    }
}
