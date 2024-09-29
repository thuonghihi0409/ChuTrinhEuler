import 'package:euler/Controller/euler_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Feature extends StatelessWidget {
  const Feature({super.key});

  @override
  Widget build(BuildContext context) {
    final graphController = context.watch<GraphController>();
    return graphController.state==1 ? ListEdges() : ResultEuler();
  }
}

class ListEdges extends StatelessWidget {
  const ListEdges({super.key});

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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Danh sach cac cung :"),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: graphController.graph.edges.length,
              itemBuilder: (context, index) {
                final edge = graphController.graph.edges[index];
                return ListTile(
                  title: Text(
                      '${graphController.graph.vertices[edge.u].name} - ${graphController.graph.vertices[edge.v].name}'),
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
              Text(graphController.graph.findEulerianCycle().length==0 ?"Khong ton tai chu trinh Euler":"Chu Trinh Euler : ${graphController.graph.findEulerianCycle().length}")
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

  String showEuler (GraphController graphcontroller){
    String s="";
    if( graphcontroller.graph.findEulerianCycle().length<1)
      return s;
    for (int i in graphcontroller.graph.findEulerianCycle() ){
      s = s + "${graphcontroller.graph.vertices[i].name} -> ";
    }
    s=s + "${graphcontroller.graph.vertices[graphcontroller.graph.findEulerianCycle()[0]].name}";
    return s;
  }
}
