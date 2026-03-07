import 'package:flutter/material.dart';
import 'package:paintroid/core/models/image_meta_data.dart';
import 'package:paintroid/ui/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ImageMetaData?> showAdvancedOptionsDialog(BuildContext context) =>
    showGeneralDialog<ImageMetaData?>(
        context: context,
        pageBuilder: (_, __, ___) => AdvancedOptionsDialog(),
        barrierDismissible: true,
        barrierLabel: 'Dismiss advanced options dialog box');

class AdvancedOptionsDialog extends StatefulWidget {
  const AdvancedOptionsDialog({super.key});

  @override
  State<AdvancedOptionsDialog> createState() => _AdvancedOptionsDialogState();
}

class _AdvancedOptionsDialogState extends State<AdvancedOptionsDialog> {
  bool antialiasing = false;
  bool smoothing = false;

  final antialiasingKey = 'antialiasing_enabled';
  final smoothingKey = 'smoothing_enabled';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
   setState(() {
     antialiasing = prefs.getBool(antialiasingKey) ?? false;
     smoothing = prefs.getBool(smoothingKey) ?? false;
   });
  }

  Future<void> _setPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(antialiasingKey, antialiasing);
    prefs.setBool(smoothingKey, smoothing);
  }

  @override
  Widget build(BuildContext context) {
    var dialogTitle = 'Advanced Options';
    return AlertDialog(
      backgroundColor: PaintroidTheme.of(context).onSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      title: Text(
        dialogTitle,
        style: PaintroidTheme.of(context)
            .titleTheme
            .titleSmall
            ?.copyWith(
          fontSize: FontSize.mediumLarge,
          fontWeight: FontWeight.w600,
          color: PaintroidTheme.of(context).primaryColor,
        ),
      ),
      actions: [_cancelButton, _saveButton],
      contentTextStyle: PaintroidTheme.of(context).textTheme.bodyMedium,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ToggleOptionRow(
            title: 'Antialiasing',
            value: antialiasing,
            onChanged: (val) {
              setState(() => antialiasing = val);
            },
          ),

          ToggleOptionRow(
            title: 'Smoothing',
            value: smoothing,
            onChanged: (val) {
              setState(() => smoothing = val);
            },
          ),
        ],
      ),
    );
  }

  TextButton get _cancelButton {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(
        'CANCEL',
        style: TextStyle(color: PaintroidTheme.of(context).primaryColor),
      ),
    );
  }

  TextButton get _saveButton {
    return TextButton(
      onPressed: () async{
        await _setPreferences();
        if(mounted){
          Navigator.of(context).pop();
        }
      },
      child: Text(
        'OK',
        style: TextStyle(color: PaintroidTheme.of(context).primaryColor),
      ),
    );
  }
}

class ToggleOptionRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleOptionRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: PaintroidTheme.of(context).textTheme.titleSmall
            ),
          ),
          Transform.scale(
            scale: 0.80,
            child: Switch(
              value: value,
              onChanged: onChanged,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: const Color(0xFF1E88A8),
              activeTrackColor: const Color(0xFFB7DDE6),
            ),
          ),
        ],
      ),
    );
  }
}
