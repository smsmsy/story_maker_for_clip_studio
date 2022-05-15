import 'package:flutter/material.dart';

import '../color_setting_dialog.dart';
import '../classes/person_class.dart';

class EditPersonPage extends StatefulWidget {
  const EditPersonPage({Key? key}) : super(key: key);

  @override
  _EditPersonPageState createState() => _EditPersonPageState();
}

class _EditPersonPageState extends State<EditPersonPage> {
  late Person person;
  late bool _isSelected;

  void _handlePersonName(String name) => setState(() => person.name = name);
  void _changeColor(Color color) => setState(() => person.color = color);

  void _handleCheckBox(bool? value) => setState(() {
    _isSelected = value!;
    person.hasMood = _isSelected;
  });

  @override
  void didChangeDependencies() {
    person = ModalRoute.of(context)?.settings.arguments as Person;
    _isSelected = person.hasMood;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('登場人物編集')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500.0,
            ),
            child: Column(
              children: [
                /// 名前と表示色設定
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("名前："),
                      const SizedBox(width: 10.0,),
                      Expanded(
                        child: TextFormField(
                          initialValue: person.name,
                          enabled: true,
                          maxLines: 1,
                          onChanged: _handlePersonName,
                          // onEditingComplete: _editPerson,
                        ),
                      ),
                      const SizedBox(width: 10.0,),
                      const Text("表示色："),
                      const SizedBox(width: 10.0,),
                      SizedBox(
                        child: TextButton(
                          onPressed: () async {
                            final color = await openColorSettingDialog(context);
                            _changeColor(color!);
                          },
                          child: Text("■", style: TextStyle(color: person.color, fontSize: 30.0,),),
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(color: Color(0x33000000), width: 2.0,),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        activeColor: Colors.lightGreen,
                        value: _isSelected,
                        onChanged: _handleCheckBox,
                      ),
                      const Text("：セリフと心情を分けて作成する",),
                    ],
                  ),
                ),
                /// ----- 作成ボタン -----
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: const Text('適用'),
                    onPressed: () {
                      _editPerson();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<Color?> openColorSettingDialog(BuildContext context) {
    return showDialog<Color>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ColorSettingDialog(person.color);
        }
    );
  }

  void _editPerson() {
    if(person.name.isEmpty) return;
    if(person.name == "メモ") {
      _showErrorDialog(context);
      return;
    }
    return Navigator.pop(context, person);
  }

  Future<void> _showErrorDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("エラー"),
              content: const Text("「メモ」という名前の人物は作成できません。"),
              actions: <Widget>[
                TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }
                )
              ]
          );
        }
    );
  }
}
