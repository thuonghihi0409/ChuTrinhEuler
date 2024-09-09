import 'package:euler/Controller/euler_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DrawEuler extends StatefulWidget {
  @override
  _DrawEulerState createState() => _DrawEulerState();
}

class _DrawEulerState extends State<DrawEuler> {
  FocusNode _focusNode = FocusNode();
  bool _isShiftPressed = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final graphController = context.watch<GraphController>();

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
              event.logicalKey == LogicalKeyboardKey.shiftRight) {
            setState(() {
              _isShiftPressed = true;
            });
          }
        } else if (event is RawKeyUpEvent) {
          if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
              event.logicalKey == LogicalKeyboardKey.shiftRight) {
            setState(() {
              _isShiftPressed = false;
            });
          }
        }
      },
      child: Stack(
        children: [
          GestureDetector(
            onTapUp: (details) {
              final tappedVertexIndex = graphController.findTappedVertex(details.localPosition);
              if (tappedVertexIndex == null) {
                graphController.addVertex(details.localPosition);
              }
              graphController.startMoveVertex(details.localPosition);
              _focusNode.requestFocus();
            },
            onPanStart: (details) {
              if (_isShiftPressed) {
                graphController.startDrawing(details.localPosition);
              } else {
                graphController.startMoveVertex(details.localPosition);
              }
            },
            onPanUpdate: (details) {
              if (_isShiftPressed) {
                graphController.updateDrawing(details.localPosition);
              } else {
                graphController.updateMoveVertex(details.localPosition);
              }
            },
            onPanEnd: (details) {
              if (_isShiftPressed) {
                graphController.endDrawing();
              } else {
                graphController.endMoveVertex();
              }
            },
            child: CustomPaint(
              painter: DoThiPainter(
                vertices: graphController.graph.vertices,
                edges: graphController.graph.edges,
                vertexNames: graphController.graph.vertexNames,
                drawingStart: graphController.drawingStart,
                drawingEnd: graphController.drawingEnd,
              ),
              child: Container(),
            ),
          ),
          ..._buildVertexWidgets(graphController),
        ],
      ),
    );
  }

  List<Widget> _buildVertexWidgets(GraphController graphController) {
    List<Widget> vertexWidgets = [];
    int _temp = graphController.graph.vertices.length;
    for (int i = 0; i < _temp; i++) {
      vertexWidgets.add(
        Positioned(
          left: graphController.graph.vertices[i].dx - 20,
          top: graphController.graph.vertices[i].dy - 20,
          child: IgnorePointer(
            ignoring: _isShiftPressed,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
              ),
              child: TextField(
                textAlign: TextAlign.center,
                controller: graphController.vertexControllers[i],
                onSubmitted: (value) {
                  graphController.setVertexName(i, value);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return vertexWidgets;
  }
}

class DoThiPainter extends CustomPainter {
  final List<Offset> vertices;
  final List<List<int>> edges;
  final Map<int, String> vertexNames;
  final Offset? drawingStart;
  final Offset? drawingEnd;

  DoThiPainter({
    required this.vertices,
    required this.edges,
    required this.vertexNames,
    this.drawingStart,
    this.drawingEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final edgePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final vertexPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
    );

    // Vẽ các cạnh
    for (var edge in edges) {
      canvas.drawLine(vertices[edge[0]], vertices[edge[1]], edgePaint);
    }

    // Vẽ đường kẻ nối giữa các đỉnh đang được kéo
    if (drawingStart != null && drawingEnd != null) {
      canvas.drawLine(drawingStart!, drawingEnd!, edgePaint);
    }

    // Vẽ các đỉnh và tên của chúng
    for (int i = 0; i < vertices.length; i++) {
      canvas.drawCircle(vertices[i], 20.0, vertexPaint);
      canvas.drawCircle(vertices[i], 20.0, edgePaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: vertexNames[i],
          style: textStyle,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, vertices[i] - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant DoThiPainter oldDelegate) {
    return oldDelegate.vertices != vertices ||
        oldDelegate.edges != edges ||
        oldDelegate.vertexNames != vertexNames ||
        oldDelegate.drawingStart != drawingStart ||
        oldDelegate.drawingEnd != drawingEnd;
  }
}
