import 'package:euler/Controller/graph_controller.dart';
import 'package:euler/UI/home_euler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => GraphController(),
      child: MyApp(),
    )

  );
}



