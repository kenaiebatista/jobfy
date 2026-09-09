import 'package:flutter/material.dart';

/// A tappable, hover-aware piece of text — a click cursor plus a style
/// that can react to hover, in one place instead of a MouseRegion +
/// GestureDetector pair re-typed (and easy to forget the cursor on) at
/// every call site.
class HoverLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final TextStyle Function(bool hovered) style;

  const HoverLink({
    super.key,
    required this.label,
    required this.onTap,
    required this.style,
  });

  @override
  State<HoverLink> createState() => _HoverLinkState();
}

class _HoverLinkState extends State<HoverLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(widget.label, style: widget.style(_hovered)),
      ),
    );
  }
}
