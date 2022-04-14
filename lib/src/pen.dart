import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// used to store the last state of drawing as ui.Image
ui.Image? image;

/// used to store the last state of drawing as Uint8List
Uint8List? imgBytesList;

/// current paint parameters
Drawing drawing = Drawing();

/// current pen state parameters
PenState penState = PenState();

/// Pen kinds
enum PenType {
  pencil,
  paintbrush,
  paintbrush2,
}

/// class to store drawing parameters while painting and then
/// used in the CustomPainter subclasses
class Drawing {
  List<Offset> points = [];
  Path path = Path();
  List<double> strokeWidths = [];
  List<double> distances = [];
}

/// class to store the current pen parameters.
///
/// [penType] store the enum with , ,  :
/// [PenType.pencil] constant stroke width using [strokeMinWidth]
/// [PenType.paintbrush] variable stroke width. Near [strokeMinWidth]
/// when moving slowly, near *strokeMaxWidth* when moving fast.
/// [PenType.paintbrush2] variable stroke width. Near [strokeMaxWidth]
/// when moving slowly, near *strokeMinWidth* when moving fast.|
/// [strokeColor] pen color, default [Colors.black]
/// [strokeMinWidth] Pen width when moving slowing, default 3
/// [strokeMaxWidth] Pen width when moving fast, default 10
/// [blurSigma] Blur stroke, default 0
/// [blendMode]	Painting blending mode.
/// See [BlendMode], default [BlendMode.srcOver]
class PenState {
  PenType penType = PenType.paintbrush;
  Color strokeColor = Colors.black;
  double strokeMinWidth = 3;
  double strokeMaxWidth = 10;
  BlendMode blendMode = ui.BlendMode.srcOver;
  double blurSigma = 0.0;
}

/// all brushes pen classes are declared with this mixin
mixin Pen {
  // takes the last N points distances to calculate the stroke width
  int get averageStrokes;

  set averageStrokes(int average);

  // CustomPainter sub-class to use
  CustomPainter get painter;

  set painter(CustomPainter painter);

  // functions to call while painting
  onPointerDown(PointerDownEvent event);

  onPointerMove(PointerMoveEvent event);

  onPointerUp(PointerUpEvent event);

  // callback that return the last available drawing
  Function(Uint8List? imgBytes)? onImageSaved;
}
