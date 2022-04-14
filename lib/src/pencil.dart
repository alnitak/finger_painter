import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'pen.dart';
import 'utils.dart';

/// pen to simulate a pencil:
/// the stroke is fixed to [PenState.strokeMinWidth]
class Pencil with Pen {
  @override
  int averageStrokes = 10; // not used

  @override
  CustomPainter painter = _Painter();

  @override
  onPointerDown(PointerDownEvent event) {
    drawing.points.add(event.localPosition);
    drawing.path.moveTo(event.localPosition.dx, event.localPosition.dy);
    painter = _Painter();
  }

  @override
  onPointerMove(PointerMoveEvent event) {
    drawing.points.add(event.localPosition);
    drawing.path.lineTo(event.localPosition.dx, event.localPosition.dy);

    painter = _Painter();
  }

  @override
  onPointerUp(PointerUpEvent event) {
    painter = _Painter(
      andSaveImage: true,
      onImageSaved: onImageSaved != null
          ? (imgBytesList) => onImageSaved!(imgBytesList)
          : null,
    );
  }
}

/// Painter class to draw current painted strokes.
/// When [andSaveImage] is true the canvas is
/// saved into [imgBytesList] and [image]
class _Painter extends CustomPainter {
  final bool andSaveImage;
  final Function(Uint8List? imgBytes)? onImageSaved;

  _Painter({
    this.andSaveImage = false,
    this.onImageSaved,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (drawing.points.isEmpty) return;
    final recorder = ui.PictureRecorder();
    Canvas? canvas2;
    if (andSaveImage) {
      canvas2 = Canvas(recorder,
          Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
    }

    var recorderPaint = Paint();
    var paint = Paint()
      ..blendMode = penState.blendMode
      ..strokeWidth = penState.strokeMinWidth
      ..color = penState.strokeColor
      ..imageFilter = ui.ImageFilter.blur(
          sigmaX: penState.blurSigma, sigmaY: penState.blurSigma)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    paint.isAntiAlias = true;
    if (penState.blurSigma > 0) {
      paint.imageFilter = ui.ImageFilter.blur(
          sigmaX: penState.blurSigma, sigmaY: penState.blurSigma);
    }

    if (andSaveImage) {
      recorderPaint.color = penState.strokeColor;
      recorderPaint.style = PaintingStyle.stroke;
      recorderPaint.strokeCap = StrokeCap.round;
      recorderPaint.isAntiAlias = true;
      if (penState.blurSigma > 0) {
        recorderPaint.imageFilter = ui.ImageFilter.blur(
            sigmaX: penState.blurSigma, sigmaY: penState.blurSigma);
      }
    }

    canvas.drawPath(drawing.path, paint);

    if (andSaveImage) {
      recorderPaint.strokeWidth = penState.strokeMinWidth;
      canvas2?.drawPath(drawing.path, recorderPaint);

      drawing.points.clear();
      drawing.path.reset();
      ui.Picture picture = recorder.endRecording();
      blendPictures(size, penState.blendMode, picture, onImageSaved);
    }
  }

  @override
  bool shouldRepaint(covariant _Painter oldDelegate) {
    return true;
  }
}
