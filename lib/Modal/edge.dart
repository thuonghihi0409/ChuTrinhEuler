
import 'package:euler/Modal/vertex.dart';

class Edge {
  int u,v;
  bool visited=false;
  Edge({required this.u,required this.v});

  Map<String, dynamic> toJson() {
    return {
      'u': u,
      'v': v,
    };
  }
  factory Edge.fromJson(Map<String, dynamic> json) {
    return Edge(
      u: json['u'],
      v: json['v'],
    );
  }
}
