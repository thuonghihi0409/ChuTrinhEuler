import 'dart:convert';
import 'dart:io';


import 'package:euler/Modal/edge.dart';
import 'package:euler/Modal/graph.dart';
import 'package:euler/Modal/vertex.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class GraphController with ChangeNotifier {
  int isSave =0;
  int state =1;
  Color colorPaint = Colors.black;
  var filepath="";
  Graph graph = Graph();
  int? startVertexIndex;
  Offset? _drawingStart;
  Offset? _drawingEnd;
  bool isShiftPressed = false;
  int? selectedVertexIndex;
  List<TextEditingController> vertexControllers = [];
  List<FocusNode> vertexFocusNodes = [];

  GraphController() {
    // Khởi tạo các TextEditingController khi tạo controller
    vertexControllers =
        List.generate(graph.vertices.length, (_) => TextEditingController());
  }
void setColorPaint (Color color){
    colorPaint = color;
    notifyListeners();
}
  void setFilePath (String s){
    filepath=s;
    notifyListeners();
  }

  void setShift ( bool shift){
    isShiftPressed=shift;
    notifyListeners();
  }
void setState (int n){
    state=n;
    notifyListeners();
}
  void setVertexName(int index, String name) {

    vertexControllers[index].addListener((){
      graph.vertices[selectedVertexIndex!].name= vertexControllers[index].text;
    });// Cập nhật TextEditingController
    graph.vertices[index].name = name;
    vertexControllers[index].text = name;
    notifyListeners();
  }

  void renew() {
    graph = Graph();
    vertexControllers.map((toElement) => {toElement.dispose()});
    vertexControllers.clear();
    vertexFocusNodes.clear();// Xóa danh sách các controller khi làm mới
    state=1;
    selectedVertexIndex=null;
    notifyListeners();
  }

  void addVertex(Offset position) {

    // Tạo TextEditingController và đồng bộ name với TextField
    TextEditingController controller = TextEditingController();
    graph.vertices.add(Vertex(position: position, name: ""));
    vertexControllers.add(controller);
    vertexFocusNodes.add(FocusNode());
    //selectedVertexIndex=graph.vertices.length;
    // Lắng nghe sự thay đổi của TextField và đồng bộ với name của đỉnh
    controller.addListener(() {
      if (selectedVertexIndex != null && selectedVertexIndex! < graph.vertices.length) {
        graph.vertices[selectedVertexIndex!].name = controller.text;
      }
    });

    notifyListeners(); // Thông báo thay đổi nếu cần
  }


  void addEdge(int startIndex, int endIndex) {
    graph.edges.add(Edge(u: startIndex, v: endIndex));
    notifyListeners();
  }

  void startDrawing(Offset position) {
    for (int i = 0; i < graph.vertices.length; i++) {
      if ((graph.vertices[i].position - position).distance < 20.0) {
        startVertexIndex = i;
        _drawingStart = graph.vertices[i].position;
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
    selectedVertexIndex=null;
    if (startVertexIndex != null && _drawingEnd != null) {
      int startIndex = startVertexIndex!;
      for (int i = 0; i < graph.vertices.length; i++) {
        if ((graph.vertices[i].position - _drawingEnd!).distance < 50.0 &&
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
      if ((graph.vertices[i].position - position).distance < 50) {
        return i;
      }
    }
    return null;
  }

  void removeVertex(int? index) {
    if(index!=null){
      graph.vertices.removeAt(index);
      vertexControllers[index].dispose();
      vertexFocusNodes[index].dispose();
      vertexFocusNodes.removeAt(index);// Giải phóng controller khi xóa đỉnh
      vertexControllers.removeAt(index);
      graph.edges.removeWhere((edge) => (edge.v==index || edge.u==index));
      for (int i=0;i<graph.edges.length;i++){
        if(graph.edges[i].u>index) graph.edges[i].u--;
        if(graph.edges[i].v>index) graph.edges[i].v--;
      }
      selectedVertexIndex=null;
      notifyListeners();
    }

  }
  void removeEdge (int index){
    graph.edges.removeAt(index);
    notifyListeners();
  }

  void startMoveVertex(Offset position) {
    selectedVertexIndex = findTappedVertex(position);
  }

  void updateMoveVertex(Offset position) {
    if (selectedVertexIndex != null) {
      graph.vertices[selectedVertexIndex!].position = position;
      notifyListeners();
    }
  }

  void endMoveVertex() {
    selectedVertexIndex = null;
  }

  Future<void> readGraphFromFile(String namefile) async {
    try {
      final path = namefile;
      final file = File(path);
      String jsonString = await file.readAsString();

      // Giải mã nội dung JSON
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      // Tạo đối tượng Graph từ JSON
      graph = await Graph.fromJson(jsonMap);
      print("Da mo file");
       vertexControllers = [];
       for(int i=0; i< graph.vertices.length;i++){
         vertexControllers.add(TextEditingController(text: "${graph.vertices[i].name}"));
         vertexFocusNodes.add(FocusNode());
         vertexControllers[i].addListener(() {
           graph.vertices[i].name= vertexControllers[i].text; // Cập nhật tên đỉnh mỗi khi TextField thay đổi
         });

       }
       isSave=1;
      setFilePath(path);
     notifyListeners();
    } catch (e) {
      print('Lỗi khi đọc file: $e');
      rethrow;
    }
  }

  Future<void> saveGraphToFile(String namefile) async {
    try {
      // Lấy thư mục Documents của hệ thống
      final directory = await getApplicationDocumentsDirectory();
      final graphDataDirectory = Directory('${directory.path}/GraphData');

      // Tạo thư mục 'GraphData' nếu chưa tồn tại
      if (!(await graphDataDirectory.exists())) {
        await graphDataDirectory.create(recursive: true);
      }

      // Đường dẫn tới file JSON
      final path = '${graphDataDirectory.path}/$namefile.json';

      // Tạo dữ liệu đồ thị dưới dạng JSON
      String graphData = jsonEncode(graph.toJson());

      // Tạo file JSON trong thư mục Documents
      File file = File(path);
      await file.writeAsString(graphData, flush: true);
      setFilePath(path);
      isSave=1;
      print('Đã lưu đồ thị vào file: $path');
    } catch (e) {
      print('Lỗi khi lưu đồ thị: $e');
    }
  }
  Future<void> renameGraphFile(String newName) async {
    try {
      // Lấy đường dẫn thư mục lưu trữ file
      final directory = await getApplicationDocumentsDirectory();
      final graphDataDirectory = Directory('${directory.path}/GraphData');


      final newPath = '${graphDataDirectory.path}/$newName.json';

      // Kiểm tra xem file cũ có tồn tại không
      final oldFile = File(filepath);
      if (await oldFile.exists()) {
        // Đổi tên file
        await oldFile.rename(newPath);
        setFilePath(newPath);
        print('Đã đổi tên file thành: $newName');
      } else {
        print('File không tồn tại');
      }
      notifyListeners();
    } catch (e) {
      print('Lỗi khi đổi tên file: $e');
    }
  }


  Future<List<FileSystemEntity>> getJsonFiles() async {
    try {
      // Lấy thư mục Documents của hệ thống
      final directory = await getApplicationDocumentsDirectory();
      final graphDataDirectory = Directory('${directory.path}/GraphData');

      // Kiểm tra nếu thư mục tồn tại
      if (await graphDataDirectory.exists()) {
        // Lấy danh sách các file trong thư mục
        List<FileSystemEntity> files = graphDataDirectory.listSync();

        // Lọc các file có phần mở rộng là .json
        List<FileSystemEntity> jsonFiles = files.where((file) {
          return file.path.endsWith('.json');
        }).toList();
        String fileName = path.basename(jsonFiles[0].path);
        return jsonFiles; // Trả về danh sách các file JSON
      } else {
        print('Thư mục GraphData không tồn tại');
        return [];
      }
    } catch (e) {
      print('Lỗi khi lấy danh sách file: $e');
      return [];
    }
  }

  // Getter cho điểm bắt đầu và điểm kết thúc khi vẽ
  Offset? get drawingStart => _drawingStart;

  Offset? get drawingEnd => _drawingEnd;
}
