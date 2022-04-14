import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

import 'bmp_header.dart';
import 'pen.dart';

/// blends [image] with the last drawn path [picture]
Future blendPictures(Size size, BlendMode mode, ui.Picture picture,
    Function(Uint8List? imgBytes)? onImageSaved) async {
  final recorder = ui.PictureRecorder();
  Canvas? canvas;
  Paint paint = Paint();

  canvas = Canvas(
      recorder, Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));

  // draw current image
  if (image != null) {
    canvas.drawImage(image!, Offset.zero, paint);
  }

  paint.blendMode = mode;
  // canvas.drawPicture(picture);
  ui.Image src = await picture.toImage(size.width.toInt(), size.height.toInt());
  paint.isAntiAlias = true;
  canvas.drawImage(src, Offset.zero, paint);

  picture = recorder.endRecording();

  ui.Image img = await picture.toImage(size.width.toInt(), size.height.toInt());

  ByteData? imgBytes =
      await img.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
  if (imgBytes != null) {
    Bmp32Header header =
        Bmp32Header.setHeader(size.width.toInt(), size.height.toInt());
    imgBytesList = header.storeBitmap(imgBytes.buffer.asUint8List());

    // on web with html renderer, this throws an error:
    // Error: ImageCodecException: Failed to decode image data.
    // Hence when using this package on web, the canvaskit renderer must be used, ie:
    // flutter run -d chrome --web-renderer canvaskit
    ui.decodeImageFromList(imgBytesList!, (ui.Image img) {
      image = img;
      if (onImageSaved != null) {
        onImageSaved(imgBytesList);
      }
    });
  }
}
