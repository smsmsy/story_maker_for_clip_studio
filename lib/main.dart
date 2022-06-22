import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'pages/add_person_page.dart';
import 'color_setting_dialog.dart';
import 'classes/content_class.dart';
import 'pages/edit_person_page.dart';
import 'classes/person_class.dart';


enum ResultAlertDialog {
  ok,
  cancel,
}

enum PersonButtonBuildTo{
  memo,
  serif,
  mood,
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: "源柔ゴシックＰ",
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: "源柔ゴシックＰ",
      ),
      home: const MyHomePage(
        title: 'まんが用プロット作成ツール',
      ),
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  static const double _radiusValue = 5.0;
  static const double _edgeValueLarge = 15.0;
  static const double _edgeValueMedium = 8.0;
  static const double _edgeValueSmall = 3.0;

  List<Person> persons = [];
  List contents = [];

  // List<TextEditingController> textEditingControllers = [];
  final Person memo = Person(name: "メモ", color: Colors.grey, hasMood: false);

  late Color textButtonColor;
  bool _expandedSettingsView = false;

  Brightness? _brightness;
  bool isDark = false;

  ScrollController scrollControllerForContentsView = ScrollController();
  double maxExtent = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _brightness = WidgetsBinding.instance.window.platformBrightness;
    isDark = _brightness == Brightness.dark;
    textButtonColor = isDark ? Colors.white : Colors.black;

    persons.add(
      Person(name: "サンプル 太郎", color: Colors.blue, hasMood: true),
    );
    contents.add(
      Content(
        person: memo,
        line: "",
        contentType: ContentType.memo,
        controller: TextEditingController(),
        hasPageEnd: false,
      ),
    );

    for (int i = 0; i < contents.length; i++) {
      contents[i].controller.addListener(_reflectTextValueForContentsView);
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted) {
      setState(() {
        _brightness = WidgetsBinding.instance.window.platformBrightness;
        isDark = _brightness == Brightness.dark;
        textButtonColor = isDark ? Colors.white : Colors.black;
      });
    }

    super.didChangePlatformBrightness();
  }

  void _reflectTextValueForContentsView() {
    for (int i = 0; i < contents.length; i++) {
      contents[i].line = contents[i].controller.text;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (var content in contents) {
      content.controller.dispose();
    }

    scrollControllerForContentsView.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(_edgeValueLarge),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// SettingsView
                    Container(
                      padding: const EdgeInsets.all(_edgeValueMedium),
                      color: isDark
                          ? const Color(0x1FFFFFFF)
                          : const Color(0x1F000000),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            _expandedSettingsView ? "設定を閉じる" : "設定を開く",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          onExpansionChanged: (changed) {
                            _expandedSettingsView = changed;
                            setState(() {});
                          },
                          children: [
                            /// 登場人物設定
                            Container(
                              margin: EdgeInsets.zero,
                              width: double.infinity,
                              child: ListTile(
                                title: const Text(
                                  '登場人物設定',
                                  style: TextStyle(fontSize: 15),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () async {
                                    final result = await Navigator.pushNamed(
                                        context, '/add-person-page');
                                    if (result is Person) {
                                      setState(() => persons.add(result));
                                    }
                                  },
                                  child: const Icon(Icons.add),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 1.0),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(_radiusValue),
                                ),
                              ),
                              margin: const EdgeInsets.only(top: 5.0),
                              height: 230.0,
                              child: ListView.builder(
                                itemCount: persons.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(width: 0.5)),
                                    ),
                                    child: ListTile(
                                      onTap: () async {
                                        final newPerson = await Navigator.pushNamed(
                                            context, '/edit-person-page',
                                            arguments: persons[index]);
                                        if (newPerson is Person) {
                                          setState(() {
                                            persons[index] = newPerson;
                                          });
                                        }
                                      },
                                      leading: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "No." + (index + 1).toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      title: Row(
                                        children: <Widget>[
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              minWidth: 10.0,
                                            ),
                                            child: Text(persons[index].name, style: const TextStyle(fontSize: 14),),
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              minWidth: 100.0,
                                            ),
                                            child: Text(
                                              "■",
                                              style: TextStyle(color: persons[index].color),
                                            ),
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
                                          if (value == 'delete') {
                                            _showPersonRemoveAlertDialog(index);
                                          } else if (value == 'edit') {
                                            _showEditPersonPage(persons[index]);
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(_edgeValueMedium),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text( "メモの色設定：",
                                      style: TextStyle(color: textButtonColor, fontSize: 15,),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  SizedBox(
                                    child: TextButton(
                                      onPressed: () async {
                                        final color = await openColorSettingDialog(context);
                                        _changeMemoColor(color!);
                                      },
                                      child: Text(
                                        "■",
                                        style: TextStyle(
                                          color: memo.color,
                                          fontSize: 30.0,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        side: const BorderSide(
                                          color: Colors.blue,
                                          width: 2.0,
                                        ),
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
                    const Divider(
                      thickness: 0,
                      height: 10.0,
                    ),

                    /// PersonListView
                    Row(
                      children: [
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: const Text("💬", style: TextStyle(fontSize: 25),),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(_edgeValueSmall),
                            height: 50.0,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: persons.length,
                              itemBuilder: (BuildContext context, int index) {
                                return buildAddContentsButton(persons[index], ContentType.serif);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: const Text("💭", style: TextStyle(fontSize: 25),),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.all(_edgeValueSmall),
                            height: 50.0,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: persons.length,
                              itemBuilder: (BuildContext context, int index) {
                                if(persons[index].hasMood) {
                                  return buildAddContentsButton(
                                      persons[index], ContentType.mood);
                                } else {
                                  return Container(
                                    margin: const EdgeInsets.only(right: _edgeValueSmall),
                                    width: 100,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),Row(
                      children: [
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: const Text("📝", style: TextStyle(fontSize: 25),),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.all(_edgeValueSmall),
                            height: 50.0,
                            child: buildAddContentsButton(memo, ContentType.memo),
                          ),
                        ),
                      ],
                    ),

                    const Divider(
                      thickness: 0,
                      height: 10.0,
                    ),

                    Container(
                      decoration: BoxDecoration(border: Border.all(width: 2),),
                      padding: const EdgeInsets.all(_edgeValueMedium),
                      height: 500,
                      child: Stack(
                        children: [
                          ReorderableListView.builder(
                            scrollController: scrollControllerForContentsView,
                            buildDefaultDragHandles: true,
                            itemCount: contents.length,
                            itemBuilder: (BuildContext context, int index) {
                              return contentListViewOfContentsView(index);
                            },
                            onReorder: (int oldIndex, int newIndex) {
                              _updateContentListForReorder(oldIndex, newIndex);
                            },
                          ),
                          Align(
                            alignment: const Alignment(1, 1),
                            child: SizedBox(
                              width: 40.0,
                              child: ElevatedButton(
                                onPressed: () => setState(() {
                                  scrollControllerForContentsView.animateTo(
                                    -scrollControllerForContentsView.position.minScrollExtent,
                                    duration: const Duration(
                                        seconds: 1, milliseconds: 500),
                                    curve: Curves.ease,
                                  );
                                }),
                                child: const Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 20.0,
                                ),
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                                  backgroundColor: MaterialStateProperty.all(
                                    const Color(0xcc5e5e5e),
                                  ),
                                ),
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
          ),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(),
                child: ElevatedButton(
                  child: const Text(
                    "読む用出力",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15,),
                  ),
                  onPressed: () async {
                    if (contents
                        .any((content) => content.line == "")) {
                      ResultAlertDialog selection = await _showWarningLineEmpty() as ResultAlertDialog;
                      if (selection == ResultAlertDialog.ok) {
                        _outputForReading(context);
                      }
                    } else {
                      _outputForReading(context);
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(),
                child: ElevatedButton(
                  child: const Text(
                    "クリスタ用出力",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                  onPressed: () async {
                    if (contents.any((content) => content.line == "")) {
                      ResultAlertDialog selection = await _showWarningLineEmpty() as ResultAlertDialog;
                      if (selection == ResultAlertDialog.ok) {
                        _outputForNameChanger(context);
                      }
                    } else {
                      _outputForNameChanger(context);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showIconForSerifOrMood(ContentType contentType) {
    switch(contentType){
      case ContentType.memo:
        return const Text("📝", style: TextStyle(fontSize: 25),);
      case ContentType.serif:
        return const Text("💬", style: TextStyle(fontSize: 25),);
      case ContentType.mood:
        return const Text("💭", style: TextStyle(fontSize: 25),);
    }
  }

  Widget buildAddContentsButton(Person person, ContentType contentType){
    Widget widget;

    widget = Container(
      margin: const EdgeInsets.only(right: _edgeValueSmall),
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.0,
          color: person.color,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(_radiusValue),
        ),
      ),
      child: TextButton(
        onPressed: () {
          setState(() {
            contents.add(Content(
              person: person,
              line: "",
              contentType: contentType,
              controller: TextEditingController(),
              hasPageEnd: false,
            ));
            contents[contents.length - 1].controller
                .addListener(_reflectTextValueForContentsView);
          });
          scrollControllerForContentsView.animateTo(
            maxContext(),
            curve: Curves.ease,
            duration: const Duration(
              milliseconds: 750,
            ),
          );
          // textEditingControllers.add(TextEditingController());
        },
        child: Padding(
          padding: EdgeInsets.zero,
          child: AutoSizeText(
            person.name,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 12,
              color: textButtonColor,
            ),
            maxLines: 2,
          ),
        ),
      ),
    );

    return widget;
  }

  void _updateContentListForReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      if(contents[oldIndex] is Divider) {
        contents[oldIndex - 1].hasPageEnd = false;
      }
      final newContent = contents.removeAt(oldIndex);
      contents.insert(newIndex, newContent);

      if(contents[newIndex] is Content) {
        contents[newIndex].controller.addListener(() {
          _reflectTextValueForContentsView();
        });
      } else if(contents[newIndex] is Divider) {
        if(newIndex == 0){
          contents.removeAt(0);
        }
        else if(contents[newIndex - 1] is Content) {
          contents[newIndex - 1].hasPageEnd = true;
        } else if (contents[newIndex - 1] is Divider ) {
          contents.removeAt(newIndex - 1);
        } else if (contents[newIndex + 1] is Divider ) {
          contents.removeAt(newIndex);
        }
      }
    });
  }

  Widget contentListViewOfContentsView(int index) {
    if(contents[index] is Content){
      return Padding(
        key: Key('$index'),
        padding: const EdgeInsets.all(_edgeValueSmall),
        child: Row(
          children: [
            Column(
              children: [
                const SizedBox(width: 50.0, height: 20.0,),
                Padding(
                  padding: const EdgeInsets.all(_edgeValueSmall),
                  child: Text(
                    "No." + (index + 1).toString(),
                    style: TextStyle(
                      color: contents[index].person.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 50.0,
                  height: 20.0,
                  child: OutlinedButton(
                    onPressed: () => setState( () {
                      if(contents[index].hasPageEnd) {
                        contents[index].hasPageEnd = false;
                        contents.removeAt(index + 1);
                      } else {
                        contents[index].hasPageEnd = true;
                        contents.insert(index + 1, const Divider());
                      }},
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Page", style: TextStyle(fontSize: 10.0),),
                        Icon(
                          contents[index].hasPageEnd
                              ? Icons.remove_circle
                              : Icons.add_circle,
                          size: 10.0,
                        ),
                      ],
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      primary: contents[index].hasPageEnd
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(10, 0),
                child: TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(_edgeValueMedium),
                      child: _showIconForSerifOrMood(contents[index].contentType),
                    ),
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
                  controller: contents[index].controller,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  contents[index].controller
                      .removeListener(_reflectTextValueForContentsView);
                  contents.removeAt(index);
                });
              },
              child: Icon(
                Icons.remove_circle_outline_rounded,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(width: 20,)
          ],
        ),
      );
    } else if(contents[index] is Divider){
      return Container(
        key: Key('$index'),
        child: _pageDivider(index),
      );
    } else {
      return Container(
        key: Key('$index'),
      );
    }
  }

  Widget _pageDivider(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Expanded(
          child: Divider(),
        ),

        Container(
          width: 100.0,
          alignment: Alignment.center,
          child: Text(
            "Page ${getPageNum(index)}",
            style: const TextStyle(),
          ),
        ),

        const Expanded(
          child: Divider(),
        ),
        const SizedBox(
          width: 20.0,
        ),
      ],
    );
  }

  int getPageNum(int index) {
    int count = 0;
    for(int i = 0; i < index ; i++){
      if(contents[i] is Divider) continue;
      if(contents[i].hasPageEnd) count++;
    }
    return count;
  }

  Future<Color?> openColorSettingDialog(BuildContext context) {
    return showDialog<Color>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ColorSettingDialog(memo.color),
    );
  }

  Future<void> _showEditPersonPage(Person person) async {
    final newPerson = await Navigator.pushNamed(context, '/edit-person-page',
        arguments: person);
    if (newPerson is Person) {
      setState(() => persons[persons.indexOf(person)] = newPerson);
    }
  }

  Future<void> _showPersonRemoveAlertDialog(int index) async {
    late ResultAlertDialog ans;
    ans = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("人物削除について注意"),
          content: const Text("人物を削除すると作成済みの同じ人物のコンテンツも削除されますがよろしいでしょうか？"),
          actions: <Widget>[
            SimpleDialogOption(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context, ResultAlertDialog.ok);
              },
            ),
            SimpleDialogOption(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.pop(context, ResultAlertDialog.cancel);
              },
            ),
          ],
        );
      },
    );
    switch (ans) {
      case ResultAlertDialog.ok:
        setState(() {
          for (int i = 0; i < contents.length; i++) {
            if (persons[index].name == contents[i].person.name) {
              contents.removeAt(i);
              i--;
            }
          }
          persons.removeAt(persons.indexOf(persons[index]));
        });
        break;
      case ResultAlertDialog.cancel:
        break;
    }
  }

  void _changeMemoColor(Color color) => setState(() => memo.color = color);

  void _outputForReading(BuildContext context) {}

  Future<void> _outputForNameChanger(BuildContext context) async {
    String contentsForOutputToNameChanger = "";
    contentsForOutputToNameChanger = generateContentsToTextFile();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ネームチェンジャー用出力プレビュー"),
          content: Container(
            padding: const EdgeInsets.all(_edgeValueMedium),
            margin: const EdgeInsets.all(_edgeValueMedium),
            decoration: BoxDecoration(
              border: Border.all(width: 1.0),
              borderRadius: const BorderRadius.all(Radius.circular(_radiusValue),),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: SelectableText(
                  contentsForOutputToNameChanger,
                ),
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("クリップボードにコピー"),
              onPressed: () async {
                final data = ClipboardData(text: contentsForOutputToNameChanger);
                await Clipboard.setData(data);
              },
            ),
            TextButton(
              child: const Text("閉じる"),
              onPressed: () {
                contentsForOutputToNameChanger = "";
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String generateContentsToTextFile() {
    String s = "";

    for (var content in contents) {
      if (content.person == memo) continue;
      if (content.line.isEmpty) continue;

      final lines = content.line.split("\n");
      for (var line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine == "") continue;

        s += trimmedLine;
        s += "\n";
      }
      s += "\n";
    }
    return s.trim();
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
                },
              ),
              TextButton(
                child: const Text("キャンセル"),
                onPressed: () {
                  Navigator.of(context).pop(ResultAlertDialog.cancel);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  double maxContext() {
    double result;
    scrollControllerForContentsView.position.maxScrollExtent == 0
        ? result = scrollControllerForContentsView.position.maxScrollExtent
        : result = scrollControllerForContentsView.position.maxScrollExtent + 62;
    return result;
  }

}
