import 'package:euler/Modal/euler.dart';
import 'package:flutter/material.dart';

class GraphController with ChangeNotifier {
  Graph graph = Graph();
  int? startVertexIndex;
  Offset? _drawingStart;
  Offset? _drawingEnd;

  int? selectedVertexIndex;
  List<TextEditingController> vertexControllers = [];

  GraphController() {
    // Khởi tạo các TextEditingController khi tạo controller
    vertexControllers =
        List.generate(graph.vertices.length, (_) => TextEditingController());
  }

  void setVertexName(int index, String name) {
    graph.vertexNames[index] = name;
    vertexControllers[index].text = name; // Cập nhật TextEditingController
    notifyListeners();
  }

  void renew() {
    graph = Graph();
    vertexControllers.map((toElement) => {toElement.dispose()});
    vertexControllers.clear(); // Xóa danh sách các controller khi làm mới
    notifyListeners();
  }

  void addVertex(Offset position) {
    graph.vertices.add(position);
    vertexControllers
        .add(TextEditingController()); // Thêm controller mới cho đỉnh
    notifyListeners();
  }

  void addEdge(int startIndex, int endIndex) {
    graph.edges.add([startIndex, endIndex]);
    notifyListeners();
  }

  void startDrawing(Offset position) {
    for (int i = 0; i < graph.vertices.length; i++) {
      if ((graph.vertices[i] - position).distance < 20.0) {
        startVertexIndex = i;
        _drawingStart = graph.vertices[i];
        print("Bắt đầu vẽ từ đỉnh: $i tại vị trí ${graph.vertices[i]}");
        return;
      }
    }
    startVertexIndex = null;
    _drawingStart = null;
    print("Không tìm thấy đỉnh bắt đầu.");
  }

  void updateDrawing(Offset position) {
    if (_drawingStart != null) {
      _drawingEnd = position;
      notifyListeners();
    }
  }

  void endDrawing() {
    if (startVertexIndex != null && _drawingEnd != null) {
      int startIndex = startVertexIndex!;
      for (int i = 0; i < graph.vertices.length; i++) {
        if ((graph.vertices[i] - _drawingEnd!).distance < 50.0 &&
            i != startIndex) {
          print("Vẽ cạnh từ đỉnh $startIndex đến đỉnh $i");
          addEdge(startIndex, i);
          _drawingStart = null;
          _drawingEnd = null;
          startVertexIndex = null;
          return;
        }
      }
    }
    _drawingStart = null;
    _drawingEnd = null;
    print("Không tìm thấy đỉnh kết thúc.");
    notifyListeners();
  }

  int? findTappedVertex(Offset position) {
    for (int i = 0; i < graph.vertices.length; i++) {
      if ((graph.vertices[i] - position).distance < 50) {
        return i;
      }
    }
    return null;
  }

  void removeVertex(int index) {
    graph.vertices.removeAt(index);
    graph.vertexNames.remove(index);
    vertexControllers[index].dispose(); // Giải phóng controller khi xóa đỉnh
    vertexControllers.removeAt(index);
    graph.edges.removeWhere((edge) => edge.contains(index));
    notifyListeners();
  }

  void startMoveVertex(Offset position) {
    selectedVertexIndex = findTappedVertex(position);
  }

  void updateMoveVertex(Offset position) {
    if (selectedVertexIndex != null) {
      graph.vertices[selectedVertexIndex!] = position;
      notifyListeners();
    }
  }

  void endMoveVertex() {
    selectedVertexIndex = null;
  }

  // Getter cho điểm bắt đầu và điểm kết thúc khi vẽ
  Offset? get drawingStart => _drawingStart;

  Offset? get drawingEnd => _drawingEnd;
}
