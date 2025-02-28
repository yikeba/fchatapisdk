import 'package:flutter/material.dart';

class CheckTextWidget extends StatefulWidget {
  final String label;
  final Widget child;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const CheckTextWidget({
    Key? key,
    required this.label,
    required this.child,
    this.initialValue = false,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CheckTextWidgetState createState() => _CheckTextWidgetState();
}

class _CheckTextWidgetState extends State<CheckTextWidget> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = widget.initialValue;
  }

  void _toggleSelection() {
    setState(() {
      isSelected = !isSelected;
    });
    widget.onChanged(isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 6, top: 6, bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  shape: const CircleBorder(),
                  onChanged: (value) {
                    if (value != null) {
                      _toggleSelection();
                    }
                  },
                ),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            widget.child,
          ],
        ),
      ),
    );
  }

}
