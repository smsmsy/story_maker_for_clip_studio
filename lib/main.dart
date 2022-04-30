import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'add_person_page.dart';
import 'color_setting_dialog.dart';
import 'content_class.dart';
import 'edit_person_page.dart';
import 'person_class.dart';

enum ResultAlertDialog {
  ok, cancel,
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light, fontFamily: "源柔ゴシックＰ",),
      darkTheme: ThemeData(brightness: Brightness.dark, fontFamily: "源柔ゴシックＰ",),
      home: const MyHomePage(title: 'まんが用プロット作成ツール',),
      routes: <String, WidgetBuilder>{
        '/top-page': (BuildContext context) => const MyHomePage(title: 'My Tool',),
        '/add-person-page': (BuildContext context) => AddPersonPage(),
        '/edit-person-page': (BuildContext context) => const EditPersonPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  static const double _radiusValue = 5.0;
  static const double _edgeValueLarge = 15.0;
  static const double _edgeValueMedium = 8.0;
  static const double _edgeValueSmall = 3.0;

  List<Person> personList = [];
  List<Content> contentList = [];
  List<TextEditingController> controllers = [];
  final Person memo = Person("メモ", Colors.grey);

  @override
  void initState() {
    super.initState();

    personList.add(Person("サンプル 太郎", Colors.blue));
    personList.add(Person("サンプル 222", Colors.red));
    personList.add(Person("サンプル 333", Colors.green));

    contentList.add(Content(memo, "ここにセリフや心情を追加し、プロットを作成することができます。"));
    contentList.add(Content(personList[0], "22222222222"));
    contentList.add(Content(personList[1], "33333333333333333333"));
    contentList.add(Content(personList[2], "444444444444444"));

    for(int i = 0; i < contentList.length; i++){
      controllers.add(TextEditingController(text: contentList[i].line));
      controllers[i].addListener(_reflectTextValueForContentsView);
    }
  }

  void _reflectTextValueForContentsView() {
    for(int i = 0; i < controllers.length; i++){
      contentList[i].line = controllers[i].text;
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {controller.dispose();}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title),),
      body: Scrollbar(
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(_edgeValueLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 登場人物設定
                Container(
                  margin: EdgeInsets.zero,
                  width: double.infinity,
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 1,))),
                  child: ListTile(
                    title: const Text('■ 登場人物設定', style: TextStyle(fontSize: 20),),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(context, '/add-person-page');
                        if(result is Person) { setState(() => personList.add(result)); }
                      },
                      child: const Icon(Icons.add),
                    ), //,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1.0),
                      borderRadius: const BorderRadius.all(Radius.circular(_radiusValue))
                  ),
                  margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                  height: 120.0,
                  child: ListView.builder(
                    itemCount: personList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(width: 0.5)),
                        ),
                        child: ListTile(
                          onTap: () async{
                            final newPerson = await Navigator.pushNamed(
                                context, '/edit-person-page',
                                arguments: personList[index]
                            );
                            if (newPerson is Person) {
                              setState((){
                                personList[index] = newPerson;
                              });
                            }
                          },
                          title: Row(
                            children: <Widget>[
                              ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 10.0,),
                                child: Text(personList[index].name),
                              ),
                              const SizedBox(width: 10.0,),
                              ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 100.0,),
                                child: Text("■", style: TextStyle(color: personList[index].color),),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (context) {
                              return [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('編集'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('削除'),
                                )
                              ];
                            },
                            onSelected: (String value) async {
                              if(value == 'delete'){
                                _showAlertDialog(index);
                              } else if(value == 'edit'){
                                _showEditPersonPage(personList[index]);
                              }
                            },
                            // },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                /// メモ設定
                Container(
                  margin: const EdgeInsets.all(0),
                  width: double.infinity,
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 1))),
                  child: const ListTile(
                    title: Text('■ メモ設定', style: TextStyle(fontSize: 20),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(_edgeValueMedium),
                  child: Row(
                    children: [
                      const Flexible(child: Text("色設定：")),
                      const SizedBox(width: 10.0,),
                      SizedBox(
                        child: TextButton(
                          onPressed: () async {
                            final color = await openColorSettingDialog(context);
                            _changeMemoColor(color!);
                          },
                          child: Text("■", style: TextStyle(color: memo.color, fontSize: 30.0,),),
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(color: Color(0x33000000), width: 2.0,),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// コンテンツ画面
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  width: double.infinity,
                  child: const ListTile(
                    title: Text('■ コンテンツビュー', style: TextStyle(fontSize: 20),),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(border: Border.all(width: 2),),
                  padding: const EdgeInsets.all(_edgeValueMedium),
                  height: 600.0,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.all(_edgeValueSmall),
                                decoration: BoxDecoration(
                                    border: Border.all(width: 1.0),
                                    borderRadius: const BorderRadius.all(Radius.circular(_radiusValue))
                                ),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      contentList.add(Content(memo, ""));
                                    });
                                    controllers.add(TextEditingController());
                                    controllers[controllers.length-1].addListener(_reflectTextValueForContentsView);
                                  },
                                  title: Text(memo.name),
                                  trailing: Text("■", style: TextStyle(color: memo.color),),
                                ),
                              ),
                            ),
                            Flexible(
                              child: ListView.builder(
                                itemCount: personList.length,
                                itemBuilder: (context, index) {
                                  return personListViewOfContentsView(index);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                          flex: 2,
                          child: Container(
                            margin: const EdgeInsets.all(_edgeValueSmall),
                            decoration: BoxDecoration(
                                border: Border.all(width: 1.0),
                                borderRadius: const BorderRadius.all(Radius.circular(_radiusValue))
                            ),
                            child: ReorderableListView.builder(
                              itemCount: contentList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return contentListViewOfContentsView(index);
                              },
                              onReorder: (int oldIndex, int newIndex) {
                                _updateContentListForReorder(oldIndex, newIndex);
                              },
                            ),
                          )
                      )
                    ],
                  ),
                ),

                /// 出力
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  width: double.infinity,
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 1))),
                  child: const ListTile(title: Text('■ 出力', style: TextStyle(fontSize: 20),)),
                ),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 50.0, minHeight: 30.0),
                          child: ElevatedButton(
                            onPressed: () => _outputForReading(context),
                            child: const Text("見る用に出力", style: TextStyle(fontSize: 20),),
                          )
                      ),
                      const SizedBox(width: 30.0,),
                      ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 50.0, minHeight: 30.0),
                          child: ElevatedButton(
                              onPressed: () async {
                                bool hasEmpty = false;
                                for (var content in contentList) {
                                  if(content.line.isEmpty)  {
                                    hasEmpty = true;
                                  }
                                }
                                if(hasEmpty) {
                                  ResultAlertDialog selection = await _showWarningLineEmpty() as ResultAlertDialog;
                                  if(selection == ResultAlertDialog.ok){
                                    _outputForNameChanger(context);
                                  }
                                } else {
                                  _outputForNameChanger(context);
                                }
                              },
                              child: const Text("ネームチェンジャー用に出力", style: TextStyle(fontSize: 20),)
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container personListViewOfContentsView(int index) {
    return Container(
      margin: const EdgeInsets.all(_edgeValueSmall),
      decoration: BoxDecoration(
          border: Border.all(width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(_radiusValue))
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            contentList.add(Content(personList[index], ""));
          });
          controllers.add(TextEditingController());
          controllers[controllers.length-1].addListener(_reflectTextValueForContentsView);
        },
        title: Text(personList[index].name),
        trailing: Text("■", style: TextStyle(color: personList[index].color),),
      ),
    );
  }

  Widget contentListViewOfContentsView(int index) {
    return ListTile(
      key: Key('$index'),
      contentPadding: const EdgeInsets.fromLTRB(_edgeValueLarge, _edgeValueMedium, 30, 0),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No." + (index+1).toString(),
            style: TextStyle(color: contentList[index].person.color),
          ),
        ],
      ),
      title: TextFormField(
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radiusValue),
            borderSide: BorderSide(
              color: contentList[index].person.color,
              width: 2.0,
            ),
          ),
          labelStyle: TextStyle(
            fontSize: 12,
            color: contentList[index].person.color,
          ),
          labelText: contentList[index].person.name,
          floatingLabelStyle: TextStyle(
            fontSize: 16,
            color: contentList[index].person.color,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radiusValue),
            borderSide: BorderSide(
              color: contentList[index].person.color,
              width: 1.0,
            ),
          ),
        ),
        keyboardType: TextInputType.multiline,
        maxLines: null,
        controller: controllers[index],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                controllers[index].removeListener(_reflectTextValueForContentsView);
                controllers.removeAt(index);
                contentList.removeAt(index);
              });
            },
            child: Icon(
              Icons.remove_circle_outline_rounded,
              color: Colors.red[400],
            ),
          )
        ],
      ),
    );
  }

  Future<Color?> openColorSettingDialog(BuildContext context) {
    return showDialog<Color>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ColorSettingDialog(memo.color);
        }
    );
  }

  Future<void> _showEditPersonPage(Person person) async {
    final newPerson = await Navigator.pushNamed(context, '/edit-person-page', arguments: person);
    if (newPerson is Person) {
      setState(()=> personList[personList.indexOf(person)] = newPerson);
    }
  }

  Future<void> _showAlertDialog(int index) async{
    late ResultAlertDialog ans;
    ans = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("注意"),
            content: const Text("人物を削除しても作成済みのコンテンツは削除されません"),
            actions: <Widget>[
              SimpleDialogOption(
                child: const Text('OK'),
                onPressed: (){Navigator.pop(context, ResultAlertDialog.ok);},
              ),
              SimpleDialogOption(
                child: const Text('キャンセル'),
                onPressed: (){Navigator.pop(context, ResultAlertDialog.cancel);},
              ),
            ],
          );
        }
    );
    switch(ans){
      case ResultAlertDialog.ok:
        setState(() {
          personList.removeAt(personList.indexOf(personList[index]));
        });
        break;
      case ResultAlertDialog.cancel:
        break;
    }
  }

  void _changeMemoColor(Color color) => setState(() => memo.color = color);

  void _outputForReading(BuildContext context) {

  }

  Future<void> _outputForNameChanger(BuildContext context) async{
    String contentsForOutputToNameChanger = "";
    contentsForOutputToNameChanger = generateContentsToTextFile();

    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("ネームチェンジャー用出力プレビュー"),
              content: Scrollbar(
                isAlwaysShown: true,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(_edgeValueMedium),
                    margin: const EdgeInsets.all(_edgeValueMedium),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.0),
                      borderRadius: const BorderRadius.all(Radius.circular(_radiusValue)),
                    ),
                    child: Text(
                      contentsForOutputToNameChanger,
                      maxLines: null,
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                    child: const Text("クリップボードにコピー"),
                    onPressed: () async{
                      final data = ClipboardData(text: contentsForOutputToNameChanger);
                      await Clipboard.setData(data);
                    }
                ),
                TextButton(
                    child: const Text("閉じる"),
                    onPressed: () {
                      contentsForOutputToNameChanger = "";
                      Navigator.of(context).pop();
                    }
                ),
              ]
          );
        }
    );
  }

  String generateContentsToTextFile() {

    String s = "";
    for (int i = 0; i < contentList.length; i++) {
      if(contentList[i].line.isEmpty) continue;
      s += contentList[i].line;
      if(i != contentList.length - 1) s += "\n\n";
    }
    return s;
  }

  Future<void> _showWarningLineEmpty() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: AlertDialog(
                title: const Text("警告"),
                content: const Text("空白のコンテンツが含まれます。\n削除して出力しますがよろしいでしょうか？"),
                actions: <Widget>[
                  TextButton(
                      child: const Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop(ResultAlertDialog.ok);
                      }
                  ),
                  TextButton(
                      child: const Text("キャンセル"),
                      onPressed: () {
                        Navigator.of(context).pop(ResultAlertDialog.cancel);
                      }
                  )
                ]
            ),
          );
        }
    );
  }

  void _updateContentListForReorder(int oldIndex, int newIndex) {
    if(oldIndex < newIndex){
      newIndex -= 1;
    }
    final TextEditingController newController = controllers.removeAt(oldIndex);
    final Content newContent = contentList.removeAt(oldIndex);
    contentList.insert(newIndex, newContent);
    controllers.insert(newIndex, newController);
    controllers[newIndex].addListener(() {
      _reflectTextValueForContentsView();
    });
  }
}
