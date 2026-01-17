import 'package:flutter/material.dart';

class CharacterCounterField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final int maxLines;
  final String? Function(String?)? validator;

  const CharacterCounterField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.maxLength,
    this.maxLines = 1,
    this.validator,
  }) : super(key: key);

  @override
  State<CharacterCounterField> createState() => _CharacterCounterFieldState();
}

class _CharacterCounterFieldState extends State<CharacterCounterField> {
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _currentLength = widget.controller.text.length;
    widget.controller.addListener(_updateLength);
  }

  void _updateLength() {
    setState(() {
      _currentLength = widget.controller.text.length;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateLength);
    super.dispose();
  }

  Color _getCounterColor() {
    final percentage = _currentLength / widget.maxLength;
    if (percentage >= 0.9) return Colors.red;
    if (percentage >= 0.75) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: widget.controller,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) {
            return null; // Hide default counter
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDDB8E4), width: 2),
            ),
          ),
          validator: widget.validator,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 4),
          child: Text(
            '$_currentLength / ${widget.maxLength}',
            style: TextStyle(
              fontSize: 12,
              color: _getCounterColor(),
              fontWeight: _currentLength >= widget.maxLength * 0.9
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}