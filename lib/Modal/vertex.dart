
import 'dart:ui';

class Vertex {
Offset position;
String name="";
Vertex( {required this.position, required this.name});
factory Vertex.from(Vertex other) {
  return Vertex(
    position: Offset(other.position.dx, other.position.dy),
    name: other.name,
  );
}
Map<String, dynamic> toJson() {
  return {
    'name': name,
    'position': {'dx': position.dx, 'dy': position.dy}
    };
  }

factory Vertex.fromJson(Map<String, dynamic> json) {
  return Vertex(
    name: json['name'],
    position: Offset(json['position']['dx'], json['position']['dy']),
  );
}
}