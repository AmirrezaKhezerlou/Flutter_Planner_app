import 'package:flutter/material.dart';

class RoundedInput extends StatelessWidget {
  final String label;
  final int max_len;
  final TextEditingController controller;
  final bool is_active;
  RoundedInput(
      {required this.label, required this.max_len, required this.controller, required this.is_active});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.lightGreen[100],
          ),
          child: TextFormField(
            enabled: is_active,
            maxLines: max_len<50?1:3,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            controller: controller,
            maxLength: max_len,
            decoration: InputDecoration(
              counter: SizedBox.shrink(),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              // filled: true,
              // fillColor: Colors.lightGreen[100],
            ),
          ),
        ),
      ],
    );
  }
}
