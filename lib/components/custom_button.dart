import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({super.key, this.child, required this.onTap});
  final Widget? child;
  final Function() onTap;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: RawMaterialButton(
            fillColor: Colors.deepPurpleAccent,
            onPressed: widget.onTap,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: widget.child));
  }
}
