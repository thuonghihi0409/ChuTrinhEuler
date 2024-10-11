import 'dart:convert';
import 'dart:io';

import 'package:euler/Modal/vertex.dart';
import 'package:euler/Modal/edge.dart';
import 'package:flutter/material.dart';

class Graph  {
  List<Vertex> vertices = [];
  List<Edge> edges = [];
  List<int> cycle = [];

  Graph();
  List<int> getNeighbors(int v) {
    List<int> list= [];
    for(int i=0;i< edges.length; i++){
      if(edges[i].u==v || edges[i].v==v){
        list.add(i);
      }
    }

    return list;
  }

  // Kiem tra co thoa man dieu kien ton tai chu trinh euler khong
  bool hasEulerianCycle() {
    for (int v=0 ; v<vertices.length;v++) {
      int degree = edges.where((e) => e.u == v || e.v == v).length;
      if (degree % 2 != 0) {
        return false; // Nếu bậc của bất kỳ đỉnh nào lẻ, không có chu trình Euler
      }
    }
    return true;
  }

 // tim chu trinh
  void _findCycle(int current, List<Edge> unusedEdges) {
    // Nếu tất cả các cạnh đã được duyệt, ta đã hoàn thành việc tìm chu trình
    if (unusedEdges.every((edge) => edge.visited)) {
      return;
    }

    // Thêm đỉnh hiện tại vào chu trình nếu chưa có trong chu trình
    if (!cycle.contains(current)) {
      cycle.add(current);
      print("++ ${cycle[cycle.length - 1]}");
    }

    // Duyệt qua các cạnh
    for (Edge edge in unusedEdges) {
      // Nếu cạnh chưa được duyệt và đỉnh `u` là đỉnh hiện tại
      if (edge.u == current && !edge.visited) {
        edge.visited = true;  // Đánh dấu cạnh là đã duyệt
        _findCycle(edge.v, unusedEdges); // Đệ quy đến đỉnh kề `v`
        return; // Kết thúc sau khi tìm thấy chu trình tại nhánh này
      }
      // Nếu cạnh chưa được duyệt và đỉnh `v` là đỉnh hiện tại
      else if (edge.v == current && !edge.visited) {
        edge.visited = true;  // Đánh dấu cạnh là đã duyệt
        _findCycle(edge.u, unusedEdges); // Đệ quy đến đỉnh kề `u`
        return; // Kết thúc sau khi tìm thấy chu trình tại nhánh này
      }
    }
  }


// giai thuat hierholzer
  List<int> findEulerianCycle() {
    if(vertices.isEmpty ||edges.isEmpty){
      return [];
    }
    // Kiểm tra điều kiện Euler: Mỗi đỉnh phải có bậc chẵn
    if (!hasEulerianCycle() || countConnectedComponents()>1) {
      print("Đồ thị không có chu trình Euler");
      return [];
    }


    List<Edge> unusedEdges = List.from(edges);

    // Bắt đầu từ đỉnh đầu tiên

    _findCycle(0, unusedEdges);

    return cycle;
  }

  int countConnectedComponents() {
    Set<int> visited = {};
    int connectedComponents = 0;

    // Duyệt qua tất cả các đỉnh
    for (int v=0; v< vertices.length;v++) {
      if (!visited.contains(v)) {
        // Nếu đỉnh chưa được thăm, nó thuộc một miền liên thông mới
        connectedComponents++;
        // Duyệt DFS để thăm tất cả các đỉnh thuộc miền liên thông này
        _dfs(v, visited);
      }
    }

    return connectedComponents;
  }

  // Hàm DFS duyệt qua các đỉnh liên thông với đỉnh hiện tại
  void _dfs(int current, Set<int> visited) {
    visited.add(current);

    for (int neighbor in getNeighbors(current)) {
      if (!visited.contains(neighbor)) {
        _dfs(neighbor, visited);
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'vertices': vertices.map((v) => v.toJson()).toList(),
      'edges': edges.map((e) => e.toJson()).toList(),
    };
  }



  factory Graph.fromJson(Map<String, dynamic> json) {
    return Graph()
      ..vertices = (json['vertices'] as List)
          .map((vertexJson) => Vertex.fromJson(vertexJson))
          .toList()
      ..edges = (json['edges'] as List)
          .map((edgeJson) => Edge.fromJson(edgeJson))
          .toList();
  }

}
