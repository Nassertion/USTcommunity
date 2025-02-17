import 'dart:ffi';

import 'package:flutter/material.dart';

class ExpandableContent extends StatefulWidget {
  final String text;
  final String? imageUrl;
  final int maxLines;

  const ExpandableContent(
      {Key? key, required this.text, this.imageUrl, this.maxLines = 3})
      : super(key: key);

  @override
  _ExpandableContentState createState() => _ExpandableContentState();
}

class _ExpandableContentState extends State<ExpandableContent> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: isExpanded ? null : widget.maxLines,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        // SizedBox(height: 5),
        if (widget.imageUrl != null)
          Image.asset(
            widget.imageUrl!,
            fit: BoxFit.cover,
          ),
        // SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            isExpanded ? "إخفاء" : "اقرأ المزيد",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
