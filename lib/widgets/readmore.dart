import 'package:flutter/material.dart';

class ExpandableContent extends StatefulWidget {
  final String text;
  final String? imageUrl;
  final int maxLines;

  const ExpandableContent({
    Key? key,
    required this.text,
    this.imageUrl,
    this.maxLines = 3,
  }) : super(key: key);

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
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: Text(
            widget.text,
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.text,
          ),
        ),
        if (widget.imageUrl != null)
          Image.asset(
            widget.imageUrl!,
            fit: BoxFit.cover,
          ),
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            isExpanded ? "إخفاء" : "اقرأ المزيد",
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
