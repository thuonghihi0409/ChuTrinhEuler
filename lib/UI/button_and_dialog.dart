import 'dart:io';

import 'package:euler/Controller/graph_controller.dart';
import 'package:euler/UI/home_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Buttonicon extends StatelessWidget {
  const Buttonicon({super.key});

  @override
  Widget build(BuildContext context) {
    final graphController = context.watch<GraphController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // Nút Tạo mới
        buildIconButton(
          context: context,
          tooltip: "New",
          icon: Icons.file_open_outlined,
          onPressed: () {
            graphController.renew();
            graphController.isSave = 0;
            graphController.filepath = "";
          },
        ),
        // Nút Mở file
        buildIconButton(
          context: context,
          tooltip: "Open",
          icon: Icons.file_open,
          onPressed: () => showListDialog(context),
        ),
        // Nút Lưu file
        buildIconButton(
          context: context,
          tooltip: "Save",
          icon: Icons.save,
          onPressed: () => showSaveDialog(context),
        ),
        // Nút Đổi tên file
        buildIconButton(
          context: context,
          tooltip: "Rename",
          icon: Icons.drive_file_rename_outline,
          onPressed: () => showRenameDialog(context, graphController),
        ),
        // Nút Xuất file
        buildIconButton(
          context: context,
          tooltip: "Export",
          icon: Icons.fireplace,
          onPressed: () => showSaveDialog(context),
        ),
      ],
    );
  }

  // Hàm tiện ích để tạo IconButton với cải tiến giao diện
  Widget buildIconButton({
    required BuildContext context,
    required String tooltip,
    required IconData icon,
    required void Function() onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0), // Giảm khoảng cách giữa các nút
      child: InkWell(
        borderRadius: BorderRadius.circular(30), // Bo tròn viền nhẹ hơn
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48, // Kích thước nút nhỏ hơn
          width: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade50, // Màu nền nhẹ
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2), // Đổ bóng nhẹ
              ),
            ],
          ),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              color: Colors.blueGrey.shade700, // Màu biểu tượng tối hơn
              size: 24, // Kích thước biểu tượng nhỏ hơn
            ),
          ),
        ),
      ),
    );
  }
}


Future<void> showSaveDialog(BuildContext context) async {
  GraphController graphController =
      Provider.of<GraphController>(context, listen: false);
  TextEditingController fileNameController = TextEditingController();

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Cạnh bo tròn
        ),
        title: Text(
          'Nhập tên file',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent, // Màu sắc tiêu đề
          ),
        ),
        content: TextField(
          controller: fileNameController,
          decoration: InputDecoration(
            hintText: "Tên file",
            filled: true,
            fillColor: Colors.grey[200], // Màu nền TextField
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), // Bo tròn TextField
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Bo tròn nút bấm
              ),
              backgroundColor: Colors.grey[300], // Màu nền nút Hủy
            ),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.black), // Màu chữ nút Hủy
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Bo tròn nút bấm
              ), // Màu nền nút Lưu
            ),
            child: Text(
              'Lưu',
              style: TextStyle(color: Colors.white), // Màu chữ nút Lưu
            ),
            onPressed: () {
              String fileName = fileNameController.text;

              Navigator.of(context).pop(); // Đóng hộp thoại
              graphController.saveGraphToFile(fileName); // Gọi hàm lưu file
            },
          ),
        ],
      );
    },
  );
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;

  const CustomButton({required this.text, this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          // Màu nền
          foregroundColor: Colors.black,
          // Màu chữ
          side: BorderSide(color: Colors.black12, width: 1),
          // Đường viền nhẹ
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bo góc
          ),
          elevation: 4, // Hiệu ứng nổi nhẹ
        ),
        child: Text(text),
      ),
    );
  }
}

class ButtonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final graphController = context.watch<GraphController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
          text: 'Help',
          onPressed: () => _showHelpDialog(context),
          color: Colors.blueAccent[100]!, // Màu sáng dễ chịu
        ),
        CustomButton(
          text: 'Clear',
          onPressed: () => {graphController.renew()},
          color: Colors.blueAccent[100]!,
        ),
        CustomButton(
          text: 'Shift',
          onPressed: () =>
              {graphController.setShift(!graphController.isShiftPressed)},
          color: graphController.isShiftPressed == true
              ? Colors.greenAccent
              : Colors.blueAccent[100]!,
        ),
        CustomButton(
          text: 'Delete',
          onPressed: () => {
            graphController.removeVertex(graphController.selectedVertexIndex)
          },
          color: Colors.blueAccent[100]!,
        ),
        CustomButton(
          text: 'Find Euler',
          onPressed: () => {showResultDialog(context)},
          color: Colors.blueAccent[100]!,
        ),
        CustomButton(
          text: 'Undo',
          onPressed: () => _onButtonPressed('Undo'),
          color: Colors.blueAccent[100]!,
        ),
        CustomButton(
          text: 'Red',
          onPressed: () => {
            if (graphController.colorPaint != Colors.red)
              {graphController.setColorPaint(Colors.red)}
          },
          color: graphController.colorPaint==Colors.red ? Colors.red[200]! : Colors.blueAccent[100]!, // Màu đỏ nhẹ
        ),
        CustomButton(
          text: 'Black',
          onPressed: () => {
            if (graphController.colorPaint != Colors.black)
              {graphController.setColorPaint(Colors.black)}
          },
          color: graphController.colorPaint==Colors.black ? Colors.black45 : Colors.blueAccent[100]! , // Màu đen xám
        ),
      ],
    );
  }

  // Hàm xử lý sự kiện khi một nút được nhấn
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hướng dẫn'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    '- Double click at a blank space to create a new node/state.'),
                Text('- Double click an existing node to "mark" it.'),
                Text('- Click and drag to move a node.'),
                Text('- Alt click to move a (sub)graph.'),
                Text(
                    '- Shift click inside one node and drag to another to create a link.'),
                Text(
                    '- Shift click on a blank space, drag to a node to create a start link (FSMs only).'),
                Text('- Click and drag a link to alter its curve.'),
                Text('- Click on a link/node to edit its text.'),
                Text(
                    '- Typing _ followed by a digit makes that digit a subscript.'),
                Text('- Ctrl+Z to undo and Ctrl+Y or Ctrl+Shift+Z to redo.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onButtonPressed(String s) {}
}

Future<void> showListDialog(BuildContext context) async {
  final graphController = Provider.of<GraphController>(context, listen: false);
  final temp = await graphController.getJsonFiles();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Chọn một Đồ Thị",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent, // Đổi màu tiêu đề
          ),
        ),
        content: Container(
          width: 600,
          height: 400, // Giới hạn chiều cao để có thanh cuộn
          child: ListView.builder(
            itemCount: temp.length,
            itemBuilder: (context, index) {
              final file = temp[index];
              return ListTile(
                title: Text(
                  file.path.split('/').last, // Chỉ hiển thị tên file
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                leading: Icon(Icons.file_present, color: Colors.blueAccent),
                onTap: () {
                  graphController.readGraphFromFile(file.path);
                  graphController.isSave = 1;
                  Navigator.of(context).pop(); // Đóng dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeEuler(),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog khi nhấn nút Đóng
            },
            child: Text(
              "Đóng",
              style: TextStyle(fontSize: 18, color: Colors.redAccent),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Bo tròn góc của dialog
        ),
        backgroundColor: Colors.white, // Nền trắng cho hộp thoại
      );
    },
  );
}

void showResultDialog(BuildContext context) {
  final graphController = Provider.of<GraphController>(context, listen: false);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Cạnh bo tròn
        ),
        title: Text(
          "Kết quả",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent, // Màu tiêu đề
          ),
        ),
        content: ResultEuler(),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
            },
            child: Text(
              "Đóng",
              style:
                  TextStyle(fontSize: 18, color: Colors.redAccent), // Nút đóng
            ),
          ),
        ],
      );
    },
  );
}

class ResultEuler extends StatelessWidget {
  const ResultEuler({super.key});

  @override
  Widget build(BuildContext context) {
    final graphController = context.watch<GraphController>();
    return Container(
      width: 400,
      height: 400,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                graphController.graph.findEulerianCycle().isEmpty
                    ? "Không tồn tại chu trình Euler"
                    : "Chu Trình Euler: ${graphController.graph.findEulerianCycle().length}",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87, // Màu văn bản
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (graphController.graph.findEulerianCycle().isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Cho phép cuộn ngang
                    child: Text(
                      showEuler(graphController),
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
          if (graphController.graph.findEulerianCycle().isEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Đồ thị có ${graphController.graph.countConnectedComponents().length} miền liên thông:",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          if (graphController.graph.findEulerianCycle().isEmpty)
            Expanded(
              child: ListView(
                children: graphController.graph
                    .countConnectedComponents()
                    .map(
                      (toElement) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        // Khoảng cách giữa các phần tử
                        child: Row(
                          children: [
                            Text(
                              toText(graphController, toElement),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors
                                      .blueAccent), // Màu các thành phần liên thông
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
        ],
      ),
    );
  }

  String showEuler(GraphController graphController) {
    String s = "";
    if (graphController.graph.findEulerianCycle().isEmpty) return s;
    for (int i in graphController.graph.findEulerianCycle()) {
      s += "${graphController.graph.vertices[i].name} -> ";
    }
    s +=
        "${graphController.graph.vertices[graphController.graph.findEulerianCycle()[0]].name}";
    return s;
  }

  String toText(GraphController graphController, List<int> list) {
    String s = "[";
    for (int a in list) {
      s += graphController.graph.vertices[a].name + ",";
    }
    if (s.length > 1) {
      s = s.substring(0, s.length - 1); // Loại bỏ dấu phẩy cuối cùng
    }
    s += "]"; // Thêm dấu ngoặc vuông đóng
    return s;
  }
}

Future<void> showRenameDialog(BuildContext context, GraphController graphcontroller) async {
  final TextEditingController textController = TextEditingController();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Bo góc hộp thoại
        ),
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blueAccent), // Biểu tượng đổi tên
            SizedBox(width: 10), // Khoảng cách giữa biểu tượng và tiêu đề
            Text(
              'Đổi tên đồ thị',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent, // Màu sắc tiêu đề
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Giới hạn chiều cao của content
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: "Nhập tên mới cho file",
                border: OutlineInputBorder(), // Khung viền ô nhập
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent), // Màu viền khi focus
                ),
              ),
              autofocus: true, // Tự động focus vào ô nhập liệu khi hộp thoại xuất hiện
            ),
            SizedBox(height: 10), // Khoảng cách giữa ô nhập liệu và chú thích
            Text(
              '* Không thay đổi phần mở rộng .json',
              style: TextStyle(color: Colors.grey, fontSize: 12), // Chú thích nhỏ
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại khi nhấn Hủy
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // Màu chữ nút Hủy
            ),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                // Gọi hàm đổi tên file
                graphcontroller.renameGraphFile(textController.text);
              }
              Navigator.of(context).pop(); // Đóng hộp thoại sau khi đổi tên
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, // Màu nền nút Đổi tên
              foregroundColor: Colors.white, // Màu chữ nút Đổi tên
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Kích thước nút
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Bo góc nút
              ),
            ),
            child: Text('Đổi tên'),
          ),
        ],
      );
    },
  );
}

