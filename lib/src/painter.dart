import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:finger_painter/src/pencil.dart';
import 'package:flutter/material.dart';

import 'bmp_header.dart';
import 'paintbrush.dart';
import 'pen.dart';

/// Controller to access painter parameters
class PainterController {
  VoidCallback? _clearContent;
  Function? _setPenType;
  Function(Uint8List)? _setBackgroundImage;

  _setController(
    VoidCallback clearContent,
    Function(PenType type)? setPenType,
    Function(Uint8List)? setBackgroundImage,
  ) {
    _clearContent = clearContent;
    _setPenType = setPenType;
    _setBackgroundImage = setBackgroundImage;
  }

  PenState? getState() {
    return penState;
  }

  Uint8List? getImageBytes() {
    return imgBytesList;
  }

  List<Offset>? getPoints() {
    return drawing.points;
  }

  clearContent() {
    if (_clearContent != null) _clearContent!();
  }

  setPenType(PenType type) {
    if (_setPenType != null) _setPenType!(type);
  }

  setBlendMode(ui.BlendMode mode) {
    penState.blendMode = mode;
  }

  setStrokeColor(Color color) {
    penState.strokeColor = color;
  }

  setMinStrokeWidth(double width) {
    penState.strokeMinWidth = width;
  }

  setMaxStrokeWidth(double width) {
    penState.strokeMaxWidth = width;
  }

  setBlurSigma(double sigma) {
    penState.blurSigma = sigma;
  }

  setBackgroundImage(Uint8List image) {
    if (_setBackgroundImage != null) _setBackgroundImage!(image);
  }
}

class Painter extends StatefulWidget {
  final Widget? child;
  final Color backgroundColor;
  final Size? size;
  final Function(Uint8List? imgBytes)? onDrawingEnded;

  // painter controller
  final PainterController? controller;

  const Painter({
    Key? key,
    this.child,
    this.backgroundColor = Colors.transparent,
    this.size,
    this.controller,
    this.onDrawingEnded,
  }) : super(key: key);

  @override
  State<Painter> createState() => _PainterState();
}

class _PainterState extends State<Painter> {
  late Pen pen;
  late Completer<Size> _completer;
  Size? _size;
  final key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _size = widget.size;
    _completer = Completer<Size>();

    _setPenType(penState.penType);
    widget.controller
        ?._setController(_clearContent, _setPenType, _setBackgroundImage);
  }

  _clearContent() {
    if (imgBytesList != null) {
      imgBytesList = Bmp32Header.setBmp(imgBytesList!).clearBitmap();
      image = null;
      if (widget.onDrawingEnded != null) {
        widget.onDrawingEnded!(imgBytesList);
      }
    }
  }

  _setPenType(PenType type) {
    penState.penType = type;
    switch (penState.penType) {
      case PenType.paintbrush:
        pen = Paintbrush(velocityInverted: false);
        break;
      case PenType.paintbrush2:
        pen = Paintbrush(velocityInverted: true);
        break;
      case PenType.pencil:
        pen = Pencil();
        break;
      default:
        pen = Pencil();
    }
    pen.onImageSaved = (imgBytesList) {
      if (widget.onDrawingEnded != null) {
        widget.onDrawingEnded!(imgBytesList!);
      }
    };
    if (mounted) setState(() {});
  }

  _setBackgroundImage(Uint8List imageBytes) {
    ui.decodeImageFromList(imageBytes, (ui.Image img) async {
      image = img;
      ByteData? imgBytes =
          await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (imgBytes != null) {
        Bmp32Header header = Bmp32Header.setHeader(img.width, img.height);
        imgBytesList = header.storeBitmap(imgBytes.buffer.asUint8List());
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = ColoredBox(
      color: widget.backgroundColor,
      child: ClipRect(
        child: RepaintBoundary(
          child: FutureBuilder(
              future: _completer.future,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.hasError) return Container();
                _completer = Completer();
                return CustomPaint(
                  size: _size ?? Size.zero,
                  isComplex: true,
                  painter: BackgroundLayer(image),
                  foregroundPainter: pen.painter,
                );
              }),
        ),
      ),
    );

    if (widget.child != null) {
      final container = Container(key: key, child: widget.child!);
      _size = widget.size ?? getSize();
      _completer.complete(_size);
      _completer = Completer();
      child = Stack(
        children: [
          container,
          child,
        ],
      );
    } else {
      _completer.complete(_size ?? Size.zero);
      _completer = Completer();
    }

    return Listener(
      onPointerDown: (event) {
        pen.onPointerDown(event);
        setState(() {});
      },
      onPointerMove: (event) {
        pen.onPointerMove(event);
        setState(() {});
      },
      onPointerUp: (event) {
        pen.onPointerUp(event);
        setState(() {});
      },
      child: child,
    );
  }

  Size getSize() {
    if (key.currentContext != null) {
      final size = (key.currentContext?.findRenderObject() as RenderBox).size;
      return Size(size.width, size.height);
    }
    return Size.zero;
  }
}

/// Painter class to draw the last image
class BackgroundLayer extends CustomPainter {
  final ui.Image? image;

  BackgroundLayer(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;
    canvas.drawImage(image!, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(BackgroundLayer oldDelegate) {
    return image != oldDelegate.image;
  }
}
