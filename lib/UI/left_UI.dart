import 'package:euler/Controller/graph_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

import 'button_and_dialog.dart';

class Feature extends StatelessWidget {
  const Feature({super.key});

  @override
  Widget build(BuildContext context) {
    return ListEdges();
  }
}

class ListEdges extends StatelessWidget {
  const ListEdges({super.key});

  @override
  Widget build(BuildContext context) {
    final graphController = context.watch<GraphController>();
    return Container(
      width: 350, // Điều chỉnh độ rộng để tăng không gian hiển thị
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền trắng để tạo cảm giác nhẹ nhàng
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade300, // Viền màu xám nhạt
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400, // Đổ bóng nhẹ
            blurRadius: 5,
            offset: Offset(2, 2), // Tạo bóng góc dưới phải
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn giữa các thành phần
              children: [
                Text(
                  graphController.isSave == 0
                      ? "Chưa Có Tiêu Đề"
                      : "${p.basename(graphController.filepath)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent, // Màu tiêu đề nổi bật
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueAccent), // Thêm biểu tượng chỉnh sửa tên file
                  onPressed: () {
                    // Hiển thị hộp thoại đổi tên
                    showRenameDialog(context, graphController);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Số đỉnh: ${graphController.graph.vertices.length}",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Text(
                  "Số cung: ${graphController.graph.edges.length}",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Danh sách các cung:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Divider(thickness: 1.5, color: Colors.grey.shade300), // Đường kẻ ngăn cách
          Expanded(
            child: ListView.builder(
              itemCount: graphController.graph.edges.length,
              itemBuilder: (context, index) {
                final edge = graphController.graph.edges[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Bo góc cho từng cạnh
                    ),
                    elevation: 2, // Hiệu ứng đổ bóng cho cạnh
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      title: Text(
                        '${graphController.graph.vertices[edge.u].name} - ${graphController.graph.vertices[edge.v].name}',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.close, color: Colors.redAccent), // Dấu "x" màu đỏ
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Xác nhận'),
                                content: Text('Bạn có chắc muốn xóa cạnh này?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Hủy'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Xóa', style: TextStyle(color: Colors.redAccent)),
                                    onPressed: () {
                                      graphController.removeEdge(index);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class ResultEuler extends StatelessWidget {
  const ResultEuler({super.key});

  @override
  Widget build(BuildContext context) {
    final graphController = context.watch<GraphController>();
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white, // Nền màu trắng
        border: Border(
          right: BorderSide(
            color: Colors.black, // Viền bên phải màu đen
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(graphController.graph.findEulerianCycle().length == 0
                  ? "Khong ton tai chu trinh Euler"
                  : "Chu Trinh Euler : ${graphController.graph.findEulerianCycle().length}")
            ],
          ),
          if (graphController.graph.findEulerianCycle().isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Bọc Text trong SingleChildScrollView để có thể cuộn ngang
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Cho phép cuộn ngang
                    child: Text(
                      showEuler(graphController),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String showEuler(GraphController graphcontroller) {
    String s = "";
    if (graphcontroller.graph.findEulerianCycle().length < 1) return s;
    for (int i in graphcontroller.graph.findEulerianCycle()) {
      s = s + "${graphcontroller.graph.vertices[i].name} -> ";
    }
    s = s +
        "${graphcontroller.graph.vertices[graphcontroller.graph.findEulerianCycle()[0]].name}";
    return s;
  }
}
