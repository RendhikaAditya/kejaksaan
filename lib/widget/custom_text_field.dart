import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final IconData? icon;

  CustomTextField({
    required this.hintText,
    required this.controller,
    this.icon,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white10, width: 0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Menambahkan ikon dengan padding
          if (widget.icon != null)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(widget.icon, color: Colors.grey,),
            ),
          Expanded(
            // Menggunakan Expanded agar teks dapat mengambil sisa ruang
            child: TextFormField(
              controller: widget.controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                // Menengahkan teks secara horizontal
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '${widget.hintText} tidak boleh kosong';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
