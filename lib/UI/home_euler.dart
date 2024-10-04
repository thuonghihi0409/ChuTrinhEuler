import 'dart:math';

import 'package:euler/Controller/graph_controller.dart';
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
          Container(
            color: Colors.greenAccent,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Buttonicon(),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Feature(),
                Expanded(child: DrawEuler())
              ],
            ),
          ),
        ],
      ),
    );
  }
}
