import 'package:euler/Controller/euler_controller.dart';
import 'package:euler/UI/button.dart';
import 'package:euler/UI/draw_euler.dart';
import 'package:euler/UI/left_UI.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đồ Thị Euler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeEuler(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeEuler extends StatelessWidget {
  const HomeEuler({super.key});

  @override
  Widget build(BuildContext context) {
    final graphController = context.watch<GraphController>();
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [ButtonRow()],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [Feature(), Expanded(child: DrawEuler())],
            ),
          ),
        ],
      ),
    );
  }
}
