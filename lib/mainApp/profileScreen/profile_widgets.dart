import 'package:flutter/material.dart';

import '../../reusable/colors.dart';

class NonEditableTextItem extends StatefulWidget {
  final TextEditingController? controller;
  final String title;
  final bool? isLogout;
  final String initialValue;
  final IconData leadingIcon;

  const NonEditableTextItem({
    super.key,
    this.isLogout,
    this.controller,
    required this.title,
    required this.leadingIcon,
    required this.initialValue,
  });

  @override
  State<NonEditableTextItem> createState() => _NonEditableTextItemState();
}

class _NonEditableTextItemState extends State<NonEditableTextItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ListTile(
        title: Text(widget.initialValue),
        leading: Icon(
          widget.leadingIcon,
          color: widget.isLogout == true ? red : bgColor,
        ),
      ),
    );
  }
}
