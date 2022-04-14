import 'dart:typed_data';

/// Class to construct an uncompressed 32bit BMP image from raw data
class Bmp32Header {
  late int width;
  late int height;
  late Uint8List bmp;
  late int contentSize;
  int rgba32HeaderSize = 122;
  int bytesPerPixel = 4;

  // set BMP
  Bmp32Header.setBmp(Uint8List imgBytes) {
    ByteData bd = imgBytes.buffer.asByteData();
    width = bd.getInt32(0x12, Endian.little);
    height = -bd.getInt32(0x16, Endian.little);
    contentSize = bd.getInt32(0x02, Endian.little) - rgba32HeaderSize;
    bmp = imgBytes;
  }

  // set BMP header and memory to use
  Bmp32Header.setHeader(this.width, this.height) {
    contentSize = width * height;
    bmp = Uint8List(rgba32HeaderSize + contentSize * bytesPerPixel);

    ByteData bd = bmp.buffer.asByteData();
    bd.setUint8(0x00, 0x42); // 'B'
    bd.setUint8(0x01, 0x4d); // 'M'

    bd.setInt32(0x02, rgba32HeaderSize + contentSize, Endian.little);

    bd.setInt32(0x0A, rgba32HeaderSize, Endian.little);

    bd.setUint32(0x0E, 108, Endian.little);

    bd.setUint32(0x12, width, Endian.little);
    bd.setUint32(0x16, -height, Endian.little);

    bd.setUint8(0x1A, 1);
    bd.setUint8(0x1B, 0);

    bd.setUint8(0x1C, 32);
    bd.setUint8(0x1D, 32 >> 8);

    bd.setUint32(0x1E, 3, Endian.little);

    bd.setUint32(0x22, contentSize, Endian.little);

    bd.setUint32(0x36, 0x000000ff, Endian.little);
    bd.setUint32(0x3A, 0x0000ff00, Endian.little);
    bd.setUint32(0x3E, 0x00ff0000, Endian.little);
    bd.setUint32(0x42, 0xff000000, Endian.little);
  }

  // Insert the [bitmap] after the header and return the BMP
  Uint8List storeBitmap(Uint8List bitmap) {
    bmp.setRange(rgba32HeaderSize, contentSize * bytesPerPixel, bitmap);
    return bmp;
  }

  // clear BMP pixels leaving the header untouched
  Uint8List clearBitmap() {
    bmp.fillRange(rgba32HeaderSize, bmp.length, 0);
    return bmp;
  }

  // set BMP pixels color
  Uint8List setBitmapBackgroundColor(int r, int g, int b, int a) {
    int value = (((r & 0xff) << 24) |
            ((g & 0xff) << 16) |
            ((b & 0xff) << 8) |
            ((a & 0xff) << 0)) &
        0xFFFFFFFF;
    (bmp.sublist(rgba32HeaderSize) as Uint32List)
        .fillRange(0, bmp.length, value);
    return bmp;
  }
}
