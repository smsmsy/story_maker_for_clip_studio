import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorSettingDialog extends StatefulWidget {
  const ColorSettingDialog(this.color, {Key? key}) : super(key: key);
  final Color color;
  @override
  // ignore: no_logic_in_create_state
  _ColorSettingDialogState createState() => _ColorSettingDialogState(color);
}

class _ColorSettingDialogState extends State<ColorSettingDialog>{
  bool _showDetailMode = false;

  Color selectedColor;
  _ColorSettingDialogState(this.selectedColor);

  void _handleColorPicker(bool? value) => setState(()  => _showDetailMode = value!);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      buttonPadding: const EdgeInsets.fromLTRB(0, 0, 30, 30),
      title: const Text("表示色を選択してください"),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Visibility(
              visible: !_showDetailMode,
              child: BlockPicker(
                pickerColor: selectedColor,
                onColorChanged: (Color color) => setState(() => selectedColor = color),
              ),
            ),
            Visibility(
              visible: _showDetailMode,
              child: ColorPicker(
                pickerColor: selectedColor,
                onColorChanged: (Color color) => setState(() => selectedColor = color),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Checkbox(
                    activeColor: Colors.green,
                    value: _showDetailMode,
                    onChanged: _handleColorPicker,
                  ),
                  const Text("：色詳細モード"),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: (){
            Navigator.of(context).pop(selectedColor);
          },
          child: const Text("設定"),
        ),
      ],
    );
  }
}
