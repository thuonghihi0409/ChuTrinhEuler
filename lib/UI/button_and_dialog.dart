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
            graphController.redoStack = [];
            graphController.redoStack = [];
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
          onPressed: () => {
            if (graphController.isSave == 2)
              graphController.saveagain()
            else if (graphController.isSave == 0)
              showSaveDialog(context)
          },
        ),
        // Nút Đổi tên file
        buildIconButton(
          context: context,
          tooltip: "Rename",
          icon: Icons.drive_file_rename_outline,
          onPressed: () => showRenameDialog(context, graphController),
        ),
        buildIconButton(
          context: context,
          tooltip: "Clone",
          icon: Icons.copy,
          onPressed: () => confirmCloneGraph(context, graphController),
        ),
        buildIconButton(
          context: context,
          tooltip: "Delete",
          icon: Icons.delete_forever,
          onPressed: () => showDeleteDialog(context),
        ),
        // Nút Xuất file
        buildIconButton(
          context: context,
          tooltip: "Import",
          icon: Icons.fireplace,
          onPressed: () => graphController.importJsonFile(context),
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
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      // Giảm khoảng cách giữa các nút
      child: InkWell(
        borderRadius: BorderRadius.circular(30), // Bo tròn viền nhẹ hơn
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          // Kích thước nút nhỏ hơn
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

Future<void> confirmDeleteGraphFile(BuildContext context, String namefile,
    GraphController graphcontroller) async {
  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa file "$namefile.json"?'),
        actions: [
          TextButton(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.of(context).pop(false); // Trả về false
            },
          ),
          TextButton(
            child: Text('Xóa'),
            onPressed: () {
              Navigator.of(context).pop(true); // Trả về true
            },
          ),
        ],
      );
    },
  );
  if (confirm!) {
    // Gọi hàm xóa file nếu người dùng xác nhận
    int result = await graphcontroller.deleteGraphFile(namefile);
    if (result == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa file thành công!')),
      );
    } else if (result == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File không tồn tại!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa file thất bại!')),
      );
    }
  } else {
    print('Người dùng đã hủy xóa file');
  }
}

Future<void> showDeleteDialog(BuildContext context) async {
  final graphController = Provider.of<GraphController>(context, listen: false);
  final temp = await graphController.getJsonFiles();

  // Khởi tạo TextEditingController để quản lý input tìm kiếm
  TextEditingController searchController = TextEditingController();
  // Tạo một danh sách các file hiện tại để lọc
  List<FileSystemEntity> filteredFiles = List.from(temp);

  showDialog(
    context: context,
    builder: (BuildContext context1) {
      return StatefulBuilder(
        builder: (context1, setState) {
          return AlertDialog(
            title: Text(
              "Xóa đồ thị",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thêm TextField để nhập tên file tìm kiếm
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm theo tên file...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    // Lọc danh sách file dựa trên input tìm kiếm
                    setState(() {
                      filteredFiles = temp.where((file) {
                        final filename =
                            file.path.split('/').last.toLowerCase();
                        return filename.contains(value.toLowerCase());
                      }).toList();
                    });
                  },
                ),
                SizedBox(height: 10),
                // Giới hạn chiều cao và thêm ListView.builder
                Container(
                  width: 600,
                  height: 350,
                  child: filteredFiles.isEmpty
                      ? Center(child: Text("Không tìm thấy file nào"))
                      : ListView.builder(
                          itemCount: filteredFiles.length,
                          itemBuilder: (context1, index) {
                            final file = filteredFiles[index];
                            return ListTile(
                              title: Text(
                                file.path.split('/').last,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black87),
                              ),
                              leading: Icon(Icons.file_present,
                                  color: Colors.blueAccent),
                              onTap: () {
                                Navigator.of(context1).pop();
                                confirmDeleteGraphFile(
                                    context, file.path, graphController);
                              },
                              trailing: Icon(Icons.delete),
                            );
                          },
                        ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Đóng",
                  style: TextStyle(fontSize: 18, color: Colors.redAccent),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.white,
          );
        },
      );
    },
  );
}

Future<void> confirmCloneGraph(BuildContext context,
    GraphController graphcontroller) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Xác nhận clone'),
        content: Text(
            'Bạn có chắc chắn muốn clone đồ thị "${graphcontroller.filepath.split("/").last}"?'),
        actions: [
          TextButton(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.of(context).pop(false); // Trả về false
            },
          ),
          TextButton(
            child: Text('Clone'),
            onPressed: () {
              graphcontroller.cloneGraph();
              Navigator.of(context).pop(true); // Trả về true
            },
          ),
        ],
      );
    },
  );
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
            onPressed: () async {
              String fileName = fileNameController.text;

              // Đóng hộp thoại
              int t = await graphController.saveGraphToFile(fileName);

              print("$t");
              Navigator.of(context).pop();
              if (t == 2) _showdialogsamename(context, graphController);
              // Gọi hàm lưu file
            },
          ),
        ],
      );
    },
  );
}

Future<void> _showdialogsamename(
    BuildContext context, GraphController graphcontroller) async {
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
            Icon(Icons.warning, color: Colors.amber), // Biểu tượng đổi tên
            SizedBox(width: 10), // Khoảng cách giữa biểu tượng và tiêu đề
            Text(
              'Thông báo',
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
            Text(
              "Tên đồ thị đã tồn tại ! Vui lòng đặt tên khác.",
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
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
              Navigator.of(context).pop();
              showSaveDialog(context); // Đóng hộp thoại sau khi đổi tên
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              // Màu nền nút Đổi tên
              foregroundColor: Colors.white,
              // Màu chữ nút Đổi tên
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              // Kích thước nút
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
          onPressed: () => {graphController.undo()},
          color: Colors.blueAccent[100]!,
        ),
        CustomButton(
          text: 'Redo',
          onPressed: () => {graphController.redo()},
          color: Colors.blueAccent[100]!,
        ),
        CustomButton(
          text: 'Red',
          onPressed: () => {
            if (graphController.colorPaint != Colors.red)
              {graphController.setColorPaint(Colors.red)}
          },
          color: graphController.colorPaint == Colors.red
              ? Colors.red[200]!
              : Colors.blueAccent[100]!, // Màu đỏ nhẹ
        ),
        CustomButton(
          text: 'Black',
          onPressed: () => {
            if (graphController.colorPaint != Colors.black)
              {graphController.setColorPaint(Colors.black)}
          },
          color: graphController.colorPaint == Colors.black
              ? Colors.black45
              : Colors.blueAccent[100]!, // Màu đen xám
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

  // Tạo TextEditingController để quản lý input tìm kiếm
  TextEditingController searchController = TextEditingController();
  // Danh sách file hiện tại và danh sách sau khi tìm kiếm
  List<FileSystemEntity> filteredFiles = List.from(temp);

  showDialog(
    context: context,
    builder: (BuildContext context1) {
      return StatefulBuilder(
        builder: (context1, setState) {
          return AlertDialog(
            title: Text(
              "Chọn một Đồ Thị",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thêm TextField để nhập tên file tìm kiếm
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm theo tên file...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    // Lọc danh sách file theo input tìm kiếm
                    setState(() {
                      filteredFiles = temp.where((file) {
                        final filename =
                            file.path.split('/').last.toLowerCase();
                        return filename.contains(value.toLowerCase());
                      }).toList();
                    });
                  },
                ),
                SizedBox(height: 10),
                // Giới hạn chiều cao và thêm ListView.builder
                Container(
                  width: 600,
                  height: 350,
                  child: filteredFiles.isEmpty
                      ? Center(child: Text("Không tìm thấy file nào"))
                      : ListView.builder(
                          itemCount: filteredFiles.length,
                          itemBuilder: (context1, index) {
                            final file = filteredFiles[index];
                            return ListTile(
                              title: Text(
                                file.path.split('/').last,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black87),
                              ),
                              leading: Icon(Icons.file_present,
                                  color: Colors.blueAccent),
                              onTap: () {
                                graphController.readGraphFromFile(file.path);
                                graphController.isSave = 1;
                                Navigator.of(context1).pop(); // Đóng dialog
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
              ],
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
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.white,
          );
        },
      );
    },
  );
}

void showResultDialog(BuildContext context) {
  final graphController = Provider.of<GraphController>(context, listen: false);

  showDialog(
    context: context,
    builder: (BuildContext context1) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Cạnh bo tròn
        ),
        title: Text(
          "Kết quả",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        content: ResultEuler(), // Hiển thị kết quả Euler ở đây
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.of(context1).pop();
              await graphController.exportToFile(context); // Đóng dialog
            },
            child: Text(
              "Export",
              style: TextStyle(fontSize: 18, color: Colors.blueAccent),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context1).pop();
              // Đóng dialog
            },
            child: Text(
              "Đóng",
              style: TextStyle(fontSize: 18, color: Colors.redAccent),
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

Future<void> showRenameDialog(
    BuildContext context, GraphController graphcontroller) async {
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
                  borderSide: BorderSide(
                      color: Colors.blueAccent), // Màu viền khi focus
                ),
              ),
              autofocus:
                  true, // Tự động focus vào ô nhập liệu khi hộp thoại xuất hiện
            ),
            SizedBox(height: 10), // Khoảng cách giữa ô nhập liệu và chú thích
            Text(
              '* Không thay đổi phần mở rộng .json',
              style:
                  TextStyle(color: Colors.grey, fontSize: 12), // Chú thích nhỏ
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
              backgroundColor: Colors.blueAccent,
              // Màu nền nút Đổi tên
              foregroundColor: Colors.white,
              // Màu chữ nút Đổi tên
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              // Kích thước nút
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

Future showdialogimportfail(
  BuildContext context,
) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Bo góc hộp thoại
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.amber), // Biểu tượng đổi tên
            SizedBox(width: 10), // Khoảng cách giữa biểu tượng và tiêu đề
            Text(
              'Thông báo',
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
            Text(
              "Lỗi không thể Import file !!!.",
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              // Màu nền nút Đổi tên
              foregroundColor: Colors.white,
              // Màu chữ nút Đổi tên
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              // Kích thước nút
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Bo góc nút
              ),
            ),
            child: Text('Oke'),
          ),
        ],
      );
    },
  );
}
