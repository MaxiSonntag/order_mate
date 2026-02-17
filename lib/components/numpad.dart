import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ordermate/utils/constants.dart';

class Numpad extends StatefulWidget {
  const Numpad({
    super.key,
    required this.onValueChanged,
    this.decimalPlaces = 2,
    this.currentValue,
  });

  final ValueChanged<double> onValueChanged;
  final int decimalPlaces;
  final double? currentValue;

  @override
  State<Numpad> createState() => _NumpadState();
}

class _NumpadState extends State<Numpad> {
  int _currentIntValue = 0;
  late double _powerOfTen;

  @override
  void initState() {
    super.initState();
    _powerOfTen = math.pow(10, widget.decimalPlaces).toDouble();
    _updateAndCallback();
  }

  @override
  void didUpdateWidget(covariant Numpad oldWidget) {
    if (oldWidget.currentValue != widget.currentValue) {
      final double internalValue = _currentIntValue / _powerOfTen;
      if (internalValue != widget.currentValue && widget.currentValue != null) {
        _currentIntValue = (widget.currentValue! * 100).toInt();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  void _inputDigit(String digit) {
    setState(() {
      final int newDigit = int.parse(digit);
      _currentIntValue = _currentIntValue * 10 + newDigit;
      _updateAndCallback();
    });
  }

  void _deleteDigit() {
    setState(() {
      _currentIntValue = _currentIntValue ~/ 10;
      _updateAndCallback();
    });
  }

  void _updateAndCallback() {
    final double value = _currentIntValue / _powerOfTen;

    // Call the external callback
    widget.onValueChanged(value);
  }

  Widget _buildButton(String text, {IconData? icon, VoidCallback? onPressed}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXS),
        child: AspectRatio(
          aspectRatio: 1,
          child: InkWell(
            onTap: onPressed ?? () => _inputDigit(text),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(color: Colors.grey),
                color: Colors.white,
              ),
              child: Center(
                child: icon != null
                    ? Icon(
                        icon,
                        size: AppConstants.iconSizeL,
                        color: Theme.of(context).colorScheme.onSurface,
                      )
                    : Text(
                        text,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [_buildButton('1'), _buildButton('2'), _buildButton('3')],
          ),
        ),
        Expanded(
          child: Row(
            children: [_buildButton('4'), _buildButton('5'), _buildButton('6')],
          ),
        ),
        Expanded(
          child: Row(
            children: [_buildButton('7'), _buildButton('8'), _buildButton('9')],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: const SizedBox.shrink(),
              ), // Empty button to take space
              _buildButton('0'),
              _buildButton(
                '',
                icon: Icons.backspace_outlined,
                onPressed: _deleteDigit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
