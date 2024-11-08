import 'dart:math';

import 'package:euler/Controller/graph_controller.dart';
import 'package:euler/UI/button_and_dialog.dart';
import 'package:euler/UI/draw_graph.dart';
import 'package:euler/UI/left_UI.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đồ Thị Euler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GraphScreenOpen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeEuler extends StatefulWidget {
  const HomeEuler({super.key});

  @override
  _HomeEulerState createState() => _HomeEulerState();
}

class _HomeEulerState extends State<HomeEuler> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this); // Thêm listener trong initState
  }

  @override
  void dispose() {
    windowManager.removeListener(this); // Gỡ bỏ listener khi không cần
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final graphController = context.watch<GraphController>();
    return WillPopScope(
      onWillPop: () async {
        if (graphController.isSave != 1) {
          _showSaveDialog(context, graphController);
          if (graphController.isSave == 1) {
            return true;
          } else {
            return false;
          }
        } else {
          return true; // Nếu đồ thị đã được lưu, cho phép thoát ứng dụng
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[300],
          title: Buttonicon(),
        ),
        body: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [Feature(), Expanded(child: DrawEuler())],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onWindowClose() async {
    final graphController =
    Provider.of<GraphController>(context, listen: false);
    if (graphController.isSave != 1) {
      if(graphController.isSave==0 && graphController.graph.vertices.length<=0 )
        windowManager.destroy();
      _showSaveDialog(context, graphController);
      if(graphController.isSave==2){
        graphController.saveagain();
      }
      if (graphController.isSave == 1) {
        windowManager.destroy(); // Cho phép đóng cửa sổ
      }
    } else {
      windowManager.destroy(); // Đồ thị đã lưu, cho phép đóng cửa sổ
    }
  }
}

//   class MyAppWindowListener extends WindowListener {
//     final BuildContext context;
//
//     MyAppWindowListener(this.context);
//
//     // @override
//     // void onWindowClose() async {
//     //   final graphController = Provider.of<GraphController>(
//     //       context, listen: false);
//     //   if (graphController.isSave != 1) {
//     //     _showSaveDialog(context, graphController);
//     //     if (graphController.isSave == 1) {
//     //       windowManager.destroy(); // Cho phép đóng cửa sổ
//     //     }
//     //   } else {
//     //     windowManager.destroy(); // Đồ thị đã lưu, cho phép đóng cửa sổ
//     //   }
//     // }
// }

void _showSaveDialog(BuildContext context, GraphController graphcontroller) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Lưu đồ thị',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent, // Đổi màu tiêu đề
          ),
        ),
        content: Text(
          graphcontroller.isSave==0 ?'Bạn có muốn lưu đồ thị trước khi thoát không?' :'Bạn có muốn lưu những thay đổi trước khi thoát không?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87, // Màu chữ của nội dung
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: Colors.redAccent, // Màu chữ của nút
            ),
            onPressed: () {
              Navigator.of(context).pop();
              windowManager.destroy();
            },
            child: Text(
              'Không',
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: Colors.green, // Màu chữ của nút
            ),
            onPressed: () async {
              if (graphcontroller.isSave == 2) {
                graphcontroller.saveGraphToFile(
                    p.basename(graphcontroller.filepath));
              } else if (graphcontroller.isSave == 0) {
                await showSaveDialog(context);
              }
              Navigator.of(context).pop();
            },
            child: Text(
              'Có',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Bo tròn góc hộp thoại
        ),
        backgroundColor: Colors.white, // Nền trắng cho hộp thoại
      );
    },
  );
}


class GraphScreenOpen extends StatefulWidget {
  @override
  State<GraphScreenOpen> createState() => _GraphScreenOpenState();
}

class _GraphScreenOpenState extends State<GraphScreenOpen> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this); // Thêm listener trong initState
  }

  @override
  void dispose() {
    windowManager.removeListener(this); // Gỡ bỏ listener khi không cần
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Đặt hình nền phía sau
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background2.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.9), // Tạo màu phủ lên hình nền
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),
          // Đặt các nút lên trên hình nền
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeEuler()));
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 15, // Tăng hiệu ứng bóng đổ
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    backgroundColor: Colors.blueAccent, // Đổi màu nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Bo tròn góc
                    ),
                    shadowColor: Colors.black45, // Màu bóng đổ
                  ),
                  child: Text(
                    'Tạo đồ thị mới',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 30), // Tăng khoảng cách giữa hai nút
                ElevatedButton(
                  onPressed: () {
                    showListDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 15,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    backgroundColor: Colors.green, // Màu khác cho nút thứ hai
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadowColor: Colors.black45,
                  ),
                  child: Text(
                    'Mở đồ thị',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onWindowClose() async {
    windowManager.destroy(); // Đồ thị đã lưu, cho phép đóng cửa sổ
  }
}
