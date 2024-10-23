import 'dart:io';

import 'package:euler/Controller/graph_controller.dart';
import 'package:euler/Modal/edge.dart';
import 'package:euler/Modal/vertex.dart';
import 'package:euler/UI/button_and_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DrawEuler extends StatefulWidget {
  @override
  _DrawEulerState createState() => _DrawEulerState();
}

class _DrawEulerState extends State<DrawEuler> {
  FocusNode _focusNode = FocusNode();

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
            graphController.setShift(true);

          }
        } else if (event is RawKeyUpEvent) {
          if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
              event.logicalKey == LogicalKeyboardKey.shiftRight) {
            graphController.setShift(false);
          }
        }
      },
      child: Stack(
        children: [
          GestureDetector(
            onTapUp: (details) {
              final tappedVertexIndex = graphController.findTappedVertex(details.localPosition);
              graphController.selectedVertexIndex=graphController.findTappedVertex(details.localPosition);
              if (tappedVertexIndex == null) {
                graphController.addVertex(details.localPosition);
              }
              graphController.startMoveVertex(details.localPosition);
              _focusNode.requestFocus();
              if(graphController.isSave==1) graphController.isSave=2;
            },
            onPanStart: (details) {
              if (graphController.isShiftPressed) {
                graphController.startDrawing(details.localPosition);
              } else {
                graphController.startMoveVertex(details.localPosition);
              }
            },
            onPanUpdate: (details) {
              if (graphController.isShiftPressed) {
                graphController.updateDrawing(details.localPosition);
              } else {
                graphController.updateMoveVertex(details.localPosition);
              }
            },
            onPanEnd: (details) {
              if (graphController.isShiftPressed) {
                graphController.endDrawing();
              } else {
                graphController.endMoveVertex();
              }
            },
            child: CustomPaint(
              painter: DoThiPainter(
                vertices: graphController.graph.vertices,
                edges: graphController.graph.edges,
                colorPaint: graphController.colorPaint,
                drawingStart: graphController.drawingStart,
                drawingEnd: graphController.drawingEnd,
              ),
              child: Container(
               // color: Colors.white,
              ),
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
      graphController.vertexFocusNodes[i].addListener(() {
        graphController.selectedVertexIndex=i;
        // graphController.vertexControllers[i].addListener(() {
        //   graphController.graph.vertices[i].name= graphController.vertexControllers[i].text; // Cập nhật tên đỉnh mỗi khi TextField thay đổi
        // });
      });

      vertexWidgets.add(
        Positioned(
          left: graphController.graph.vertices[i].position.dx - 20,
          top: graphController.graph.vertices[i].position.dy - 20,
          child: IgnorePointer(
            ignoring: graphController.isShiftPressed,
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
                focusNode: graphController.vertexFocusNodes[i],
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
    vertexWidgets.add(
      Positioned(child: ButtonRow(),right: 0,top: 0,)
    );

    return vertexWidgets;
  }
}

class DoThiPainter extends CustomPainter {
  final List<Vertex> vertices;
  final List<Edge> edges;
  final Offset? drawingStart;
  final Offset? drawingEnd;
  final Color colorPaint;

  DoThiPainter({
    required this.vertices,
    required this.edges,
    required this.colorPaint,
    this.drawingStart,
    this.drawingEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final edgePaint = Paint()
      ..color = colorPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final vertexPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Vẽ các cạnh
    for (var edge in edges) {
      canvas.drawLine(vertices[edge.u].position, vertices[edge.v].position, edgePaint);
    }

    // Vẽ đường kẻ nối giữa các đỉnh đang được kéo
    if (drawingStart != null && drawingEnd != null) {
      canvas.drawLine(drawingStart!, drawingEnd!, edgePaint);
    }

    // Vẽ các đỉnh và tên của chúng
    for (int i = 0; i < vertices.length; i++) {
      canvas.drawCircle(vertices[i].position, 20.0, vertexPaint);
      canvas.drawCircle(vertices[i].position, 20.0, edgePaint);

      // final textPainter = TextPainter(
      //   text: TextSpan(
      //     text: vertices[i].name,
      //     style: textStyle,
      //   ),
      //   textAlign: TextAlign.center,
      //   textDirection: TextDirection.ltr,
      // );
      // textPainter.layout();
      // textPainter.paint(canvas, vertices[i].position - Offset(textPainter.width / 2, textPainter.height / 2));
     }
  }

  @override
  bool shouldRepaint(covariant DoThiPainter oldDelegate) {
    return oldDelegate.vertices != vertices ||
        oldDelegate.edges != edges ||
        oldDelegate.drawingStart != drawingStart ||
        oldDelegate.drawingEnd != drawingEnd;
  }
}
