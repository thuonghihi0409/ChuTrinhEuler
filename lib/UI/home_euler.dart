import 'package:euler/Controller/euler_controller.dart';
import 'package:euler/UI/draw_euler.dart';
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
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.grey,
        actions: [
          IconButton(
            onPressed: () {
              graphController.renew();
            },
            icon: Icon(Icons.refresh), // Cải thiện icon cho rõ nghĩa
          ),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 100,
            color: Colors.grey,
          ),
          Expanded(child: DrawEuler())
        ],
      ),
    );
  }
}

