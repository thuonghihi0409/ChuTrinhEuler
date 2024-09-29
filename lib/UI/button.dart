import 'package:euler/Controller/euler_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const CustomButton(
      {required this.text, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // Màu nền
          foregroundColor: Colors.black, // Màu chữ
          side: BorderSide(color: Colors.black), // Đường viền đen
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(text),
      ),
    );
  }
}

class ButtonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final graphController = context.watch<GraphController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
          text: 'Help',
          onPressed: () => _onButtonPressed('Help'),
          color: Colors.grey[300]!,
        ),
        CustomButton(
          text: 'Clear',
          onPressed: () => {graphController.renew()},
          color: Colors.grey[300]!,
        ),
        CustomButton(
          text: 'Shift',
          onPressed: () =>
              {graphController.setShift(!graphController.isShiftPressed)},
          color: graphController.isShiftPressed == true
              ? Colors.greenAccent
              : Colors.grey[300]!,
        ),
        CustomButton(
          text: 'Delete',
          onPressed: () => {
            graphController.removeVertex(graphController.selectedVertexIndex)
          },
          color: Colors.grey[300]!,
        ),
        CustomButton(
          text: 'Edit',
          onPressed: () => {
            graphController.setState(2)
          },
          color: Colors.grey[300]!,
        ),
        CustomButton(
          text: 'Undo',
          onPressed: () => _onButtonPressed('Undo'),
          color: Colors.grey[300]!,
        ),
        CustomButton(
          text: 'Red',
          onPressed: () => _onButtonPressed('Red'),
          color: Colors.grey[300]!,
        ),
        CustomButton(
          text: 'Black',
          onPressed: () => _onButtonPressed('Black'),
          color: Colors.grey[300]!,
        ),
      ],
    );
  }

  // Hàm xử lý sự kiện khi một nút được nhấn

  void _onButtonPressed(String s) {}
}
