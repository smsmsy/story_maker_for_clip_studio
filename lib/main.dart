import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light, fontFamily: "源柔ゴシックＰ",),
      darkTheme: ThemeData(brightness: Brightness.dark, fontFamily: "源柔ゴシックＰ",),
      home: const MyHomePage(title: 'まんが用プロット作成ツール',),
      routes: <String, WidgetBuilder>{
        '/top-page': (BuildContext context) => const MyHomePage(title: 'My Tool',),
        '/add-person-page': (BuildContext context) => const AddPersonPage(),
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

  List<Person> persons = [];
  List<Person> personsCombinedMemo = [];

  List<Content> contents = [];
  List<TextEditingController> controllers = [];
  final Person memo = Person("メモ", Colors.grey);

  late Brightness brightness;
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();

    brightness = SchedulerBinding.instance!.window.platformBrightness;
    isDarkMode = brightness == Brightness.dark;

    persons.add(Person("サンプル 太郎", Colors.blue));
    contents.add(Content(memo, "ここにセリフや心情を追加し、プロットを作成することができます。"));

    for(int i = 0; i < contents.length; i++){
      controllers.add(TextEditingController(text: contents[i].line));
      controllers[i].addListener(_reflectTextValueForContentsView);
    }
  }

  void _reflectTextValueForContentsView() {
    for(int i = 0; i < controllers.length; i++){
      contents[i].line = controllers[i].text;
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {controller.dispose();}
    super.dispose();
  }

  bool _expanded = false;

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
                Container(
                  padding: const EdgeInsets.all(_edgeValueMedium),
                  color: isDarkMode ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        _expanded ? "設定を閉じる" : "設定を開く",
                        style: const TextStyle(fontSize: 20),),
                      // collapsedBackgroundColor: isDarkMode ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
                      // backgroundColor: isDarkMode ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
                      onExpansionChanged: (changed) {
                        _expanded = changed;
                        setState(() {});
                      },
                      children: [
                        /// 登場人物設定
                        Container(
                          margin: EdgeInsets.zero,
                          width: double.infinity,
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 1,))),
                          child: ListTile(
                            title: const Text('■ 登場人物設定', style: TextStyle(fontSize: 18),),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.pushNamed(context, '/add-person-page');
                                if(result is Person) { setState(() => persons.add(result)); }
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
                          margin: const EdgeInsets.only(top: 5.0),
                          height: 120.0,
                          child: ListView.builder(
                            itemCount: persons.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(width: 0.5)),
                                ),
                                child: ListTile(
                                  onTap: () async{
                                    final newPerson = await Navigator.pushNamed(
                                        context, '/edit-person-page',
                                        arguments: persons[index]
                                    );
                                    if (newPerson is Person) {
                                      setState((){
                                        persons[index] = newPerson;
                                      });
                                    }
                                  },
                                  title: Row(
                                    children: <Widget>[
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minWidth: 10.0,),
                                        child: Text(persons[index].name),
                                      ),
                                      const SizedBox(width: 10.0,),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minWidth: 100.0,),
                                        child: Text("■", style: TextStyle(color: persons[index].color),),
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
                                        _showEditPersonPage(persons[index]);
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
                          width: double.infinity,
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 1))),
                          child: const ListTile(
                            title: Text('■ メモ設定', style: TextStyle(fontSize: 18),),
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
                      ],
                    ),
                  ),
                ),


                /// コンテンツ画面
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  width: double.infinity,
                  child: const ListTile(
                    title: Text('■ コンテンツビュー', style: TextStyle(fontSize: 20),),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(_edgeValueMedium),
                  height: 70.0,
                  child: Center(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: persons.length + 1,
                      itemBuilder: (BuildContext context, int index){
                        return personListViewOfContentsView(index);
                      },
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(border: Border.all(width: 2),),
                  padding: const EdgeInsets.all(_edgeValueMedium),
                  height: 500,
                  child: ReorderableListView.builder(
                    itemCount: contents.length,
                    itemBuilder: (BuildContext context, int index) {
                      return contentListViewOfContentsView(index);
                    },
                    onReorder: (int oldIndex, int newIndex) {
                      _updateContentListForReorder(oldIndex, newIndex);
                    },
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
                                for (var content in contents) {
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

  Widget personListViewOfContentsView(int index) {
    personsCombinedMemo = [...persons];
    if(personsCombinedMemo[0] != memo) personsCombinedMemo.insert(0, memo);

    return Container(
      margin: const EdgeInsets.only(right: _edgeValueMedium),
      width: 150,
      decoration: BoxDecoration(
          border: Border.all(
            width: 1.0,
            color: personsCombinedMemo[index].color,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(_radiusValue))
      ),
      child: Expanded(
        child: Center(
          child: ListTile(
            onTap: () {
              setState(() {
                contents.add(Content(personsCombinedMemo[index], ""));
              });
              controllers.add(TextEditingController());
              controllers[controllers.length-1].addListener(_reflectTextValueForContentsView);
            },
            title: Text(personsCombinedMemo[index].name),
            // trailing: Text("■", style: TextStyle(color: personsCombinedMemo[index].color),),
          ),
        ),
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
            style: TextStyle(
              color: contents[index].person.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      title: TextFormField(
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radiusValue),
            borderSide: BorderSide(
              color: contents[index].person.color,
              width: 2.0,
            ),
          ),
          labelStyle: TextStyle(
            fontSize: 12,
            color: contents[index].person.color,
          ),
          labelText: contents[index].person.name,
          floatingLabelStyle: TextStyle(
            fontSize: 16,
            color: contents[index].person.color,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radiusValue),
            borderSide: BorderSide(
              color: contents[index].person.color,
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
                contents.removeAt(index);
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
      setState(()=> persons[persons.indexOf(person)] = newPerson);
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
          persons.removeAt(persons.indexOf(persons[index]));
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
                      // maxLines: null,
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
    for (int i = 0; i < contents.length; i++) {
      if(contents[i].person == memo) continue;
      if(contents[i].line.isEmpty) continue;
      s += contents[i].line;
      if(i != contents.length - 1) s += "\n\n";
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
    final Content newContent = contents.removeAt(oldIndex);
    contents.insert(newIndex, newContent);
    controllers.insert(newIndex, newController);
    controllers[newIndex].addListener(() {
      _reflectTextValueForContentsView();
    });
  }
}
