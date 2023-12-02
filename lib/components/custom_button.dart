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
        height: 55,
        width: 55,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: RawMaterialButton(
            elevation: 6,
            onPressed: widget.onTap,
            fillColor: Color.fromARGB(255, 220, 204, 242),
            shape: CircleBorder(),
            child: widget.child));
  }
}
