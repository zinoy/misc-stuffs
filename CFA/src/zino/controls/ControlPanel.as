import mx.events.CloseEvent;
import mx.managers.PopUpManager;

import zino.file.*;
import zino.utils.Formatter;

protected var _file:File, _loader:Loader;

protected function btnSave_clickHandler(event:MouseEvent):void
{
    var exif:IFDList = new IFDList();
    exif.push(new IFDObject(0x9000, IFDType.UNDEFINED, "0221"));
    var now:Date = new Date();
    exif.push(new IFDObject(0x9003, IFDType.ASCII, Formatter.formatDateTime(now, "YYYY:MM:DD JJ:NN:SS")));
    var tiff:TiffFormat = new TiffFormat(Endian.LITTLE_ENDIAN);
    tiff.exif = exif;
    tiff.writeImageData((_loader.content as Bitmap).bitmapData);
    tiff.exifPosition = ExifPosition.AFTER_IMAGE_DATA;
    tiff.save();
}

protected function titlewindow1_closeHandler(event:CloseEvent):void
{
    PopUpManager.removePopUp(this);
}


protected function btnOpen_clickHandler(event:MouseEvent):void
{
    _file = new File();
    _file.addEventListener(Event.SELECT, selectImg);
    _file.browse([new FileFilter("Images", "*.tif;*.tiff;*.bmp;*.jpg;*.jpeg;*.gif;*.png;")]);
}

protected function btnEncode_clickHandler(event:MouseEvent):void
{
    // TODO Auto-generated method stub
}

protected function btnDecode_clickHandler(event:MouseEvent):void
{
    // TODO Auto-generated method stub
}

private function selectImg(e:Event):void
{
    _file.addEventListener(Event.COMPLETE, loadImg);
    _file.load();
}

private function loadImg(e:Event):void
{
    _loader = new Loader();
    _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, showImg);
    _loader.loadBytes(_file.data);
    parent.addChildAt(_loader, 1);
}

private function showImg(e:Event):void
{
}
