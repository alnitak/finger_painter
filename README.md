Painting package that let you finger paint with different brushes and 
different blend modes. The result can be read as a bitmap or list of Points to be 
used ie on a Map.

## Features

![Pub Publisher](https://img.shields.io/pub/publisher/flutter_painter)![Pub Version](https://img.shields.io/pub/v/!%5BPub%20Publisher%5D(https://img.shields.io/pub/publisher/flutter_painter))![YouTube Channel Views](https://img.shields.io/youtube/channel/views/UCQgZ0yw1xroMNjWYDGcOYKQ?style=social) ![Twitter Follow](https://img.shields.io/twitter/follow/lildeimos?style=social)![GitHub followers](https://img.shields.io/github/followers/alnitak?style=social)

![Image](https://github.com/alnitak/finger_painter/blob/main/images/painter.gif)

## Getting started

The usage is simple: put the Painter() widget into your widget tree then use PainterController()
to control its parameters and to get current painting image and/or drawn points.

[Try online](https://marcobavagnoli.com/finger_painter/) 

## Features

- 3 kinds of pens
- min and max stroke width for paintbrush strokes
- get the last drawing image and drawing points
- set a background widget (like Google Map)
- set background color
- uses image blending modes while painting

## Usage

initialize the painter controller ie in the initState():
```dart
@override
void initState() {
  super.initState();
  painterController = PainterController()
    ..setPenType(PenType.pencil)
    ..setStrokeColor(Colors.black)
    ..setMinStrokeWidth(3)
    ..setMaxStrokeWidth(10)
    ..setBlurSigma(0.0)
    ..setBlendMode(ui.BlendMode.srcOver);
}
```

insert Painter() widget somewhere in your widget tree:
```dart
Painter(
  controller: painterController,
  backgroundColor: Colors.green.withOpacity(0.4),
  size: const Size(300, 300),
  child: Image.asset(...),
  onDrawingEnded: (Uint8List bytes) async{
    ...
  },
  // the child could be ie a Google Map
  // PS: the [backgroundColor] and child are not rendered in the resulting image 
  child: Image.asset('assets/...'),
),
```
[**Full example**](https://github.com/aissat/finger_painter/blob/master/example/lib/main.dart)

### 📜 Painter widget properties

| Properties              | Required | Default                   | Description |
| ----------------------- | -------- | ------------------------- | ----------- |
| key				| false	|					| Widget key. |
|controller			| false	|					| Get and set Painter parameters (see *PainterController* below).|
|backgroundColor	|false	| Colors.transparent| Color of the active painting area. |
|size				|false	|					| Size of painting area. If not set it takes the *child* area. If also the *child* is not set, it will take the available size from the parent.|
|child				|false	|					| Child Widget to put as the background of the painting area|
|onDrawingEnded	|false	|					| Callbackd that returns the last drawing as Uint8List filled with uncompressed BMP 32 bpp format.|

### 📜  PainterController
|Method								| return type | Description |
| -------------------------------------------------------------| --------------------| ----------------- |
| getState() 								|PenState?		| Get the *penType, strokeColor, strokeMinWidth, strokeMaxWidth, blendMode*. |
| getImageBytes()						| Uint8List?		| Get current drawing image  as uncompressed 32bit BMP *Uint8List*. |
| getPoints() 							| List<Offset\>?	| Get the point list drawn. |
| clearContent()							|				| Clear current drawings.|
| setPenType(PenType type)				|				| Set pen type: *pencil, paintbrush, paintbrush2*.|
| setBlendMode(ui.BlendMode mode)	|				| Set the painting [blending mode](https://api.flutter.dev/flutter/dart-ui/BlendMode.html). ***ui.BlendMode.dstOut*** can be used as an eraser pen.|
| setStrokeColor(Color color)			|				| Set stroke color.|
| setMinStrokeWidth(double width)		|				| Set the minimum stroke width.|
| setMaxStrokeWidth(double width)		|				| Set the maximum stroke width.|
| setBlurSigma(double sigma)			|				| Set the blur. 0 means no blur.|
| setBackgroundImage(Uint8List image)	|				| Set the background image. The painting will modify this image. 

### 📜  PenState
|Method				| Default	| Description |
| -----------------------------------	| ----------------| ----------------- |
|penType				|PenType.paintbrush|enum with *pencil, paintbrush, paintbrush2*.<br/>*pencil*: constant stroke width using *strokeMinWidth* <br/>*paintBrush*: variable stroke width. Near *strokeMinWidth* when moving slowly, near *strokeMaxWidth* when moving fast. <br/>*paintBrush2*: variable stroke width. Near *strokeMaxWidth* when moving slowly, near *strokeMinWidth* when moving fast.|
|strokeColor			|Colors.black	|pen color|
|strokeMinWidth		|3				|Pen width when moving slowing.|
|strokeMaxWidth		|10			|Pen width when moving fast.|
|blurSigma				|0				|Blur stroke.|
|blendMode			|ui.BlendMode.srcOver|Painting blending mode. See ***[ui.BlendMode](https://api.flutter.dev/flutter/dart-ui/BlendMode.html) ***|

### ⚠️ Note on **web**

The html renderer running on Web is not supported and using it will not save the drawing.
https://github.com/flutter/flutter/issues/42767

Hence when using this package on web, the canvaskit renderer must be used, ie:
*flutter run -d chrome --web-renderer canvaskit*
