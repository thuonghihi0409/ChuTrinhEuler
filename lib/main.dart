import 'package:euler/Controller/graph_controller.dart';
import 'package:euler/UI/home_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'UI/button_and_dialog.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.setPreventClose(true); // Ngăn việc đóng cửa sổ tự động
  //windowManager.addListener(MyAppWindowListener()); // Thêm listener để bắt sự kiện
  runApp(
    ChangeNotifierProvider(
        create: (context) => GraphController(),
      child: MyApp(),
    )

  );
}





