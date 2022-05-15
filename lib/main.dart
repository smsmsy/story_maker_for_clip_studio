import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/add_person_page.dart';
import 'color_setting_dialog.dart';
import 'classes/content_class.dart';
import 'pages/edit_person_page.dart';
import 'classes/person_class.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_svg/flutter_svg.dart';

enum ResultAlertDialog {
  ok, cancel,
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  GoogleAuthProvider googleProvider = GoogleAuthProvider();

  googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
  googleProvider.setCustomParameters({
    'login_hint': 'user@example.com'
  });

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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver  {
  static const double _radiusValue = 5.0;
  static const double _edgeValueLarge = 15.0;
  static const double _edgeValueMedium = 8.0;
  static const double _edgeValueSmall = 3.0;

  List<Person> persons = [];
  List<Person> personsCombinedMemo = [];
  List<Content> contents = [];
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

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });

    WidgetsBinding.instance?.addObserver(this);
    _brightness = WidgetsBinding.instance?.window.platformBrightness;
    isDark = _brightness == Brightness.dark;
    textButtonColor = isDark ? Colors.white : Colors.black;

    persons.add(Person(
      name: "サンプル 太郎",
      color: Colors.blue,
      hasMood: true
    ),);
    contents.add(Content(
      person: memo,
      line: "",
      controller: TextEditingController(),
    ),);

    for(int i = 0; i < contents.length; i++){
      contents[i].controller.addListener(_reflectTextValueForContentsView);
    }

    // scrollControllerForContentsView = ScrollController();
    // scrollControllerForContentsView.addListener(_reflectMaxExtentScrollControllerForContentsView);
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted) {
      setState(() {
        _brightness = WidgetsBinding.instance?.window.platformBrightness;
        isDark = _brightness == Brightness.dark;
        textButtonColor = isDark ? Colors.white : Colors.black;
      });
    }

    super.didChangePlatformBrightness();
  }

  void _reflectTextValueForContentsView() {
    for(int i = 0; i < contents.length; i++){
      contents[i].line = contents[i].controller.text;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    for (var content in contents) {content.controller.dispose();}

    scrollControllerForContentsView.dispose();

    super.dispose();
  }

  User? _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.fromWindowPadding(WindowPadding.zero, 8.0),
            children: <Widget>[
              ListTile(
                title: Text(
                  _user == null ? "ログインしていません" : "ようこそ、${_user?.displayName} さん",
                ),
              ),
              /// TODO : 保存処理周りをFirebase Storageで実装する。
              // ListTile(
              //   leading: const Icon(Icons.save),
              //   title: const Text("プロジェクトファイルを保存"),
              //   onTap: () async {
              //     /// TODO: ファイル保存処理は未実装のため、何かしら代替手段を考える必要がある
              //     String? outputFile = await FilePicker.platform.saveFile(
              //       dialogTitle: 'Please select an output file:',
              //       fileName: 'output-file.txt',
              //     );
              //     if (outputFile == null) {
              //       // User canceled the picker
              //     }
              //   },
              // ),
              // ListTile(
              //   leading: const Icon(Icons.open_in_browser),
              //   title: const Text("プロジェクトファイルを開く"),
              //   onTap: () async {
              //     final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
              //     if (result != null && result.files.isNotEmpty) {
              //       final fileBytes = result.files.first.bytes;
              //       final fileName = result.files.first.name;
              //       /// TODO: firebase_storageでファイルをダウンロード・アップロードする処理を加えると扱えるっぽい。
              //       print(fileName);
              //     }
              //   },
              // ),

              ListTile(
                leading: Icon(
                  _user == null ? Icons.login : Icons.logout,
                  color: _user == null ? Colors.blue : Colors.red,
                ),
                title: Text(
                  _user == null ? "Googleでログイン" : "ログアウト",
                  style: TextStyle(
                    color: _user == null ? Colors.blue : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  if(_user == null){
                    _googleSignin();
                  } else {
                    _googleAccountSignOut();
                  }
                },

              ),
            ],
          )
      ),
      body: Scrollbar(
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(_edgeValueLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// SettingsView
                Container(
                  padding: const EdgeInsets.all(_edgeValueMedium),
                  color: isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        _expandedSettingsView ? "設定を閉じる" : "設定を開く",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                            title: const Text('■ 登場人物設定', style: TextStyle(fontSize: 20),),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.pushNamed(context, '/add-person-page');
                                if(result is Person) { setState(() => persons.add(result)); }
                              },
                              child: const Icon(Icons.add),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 1.0),
                              borderRadius: const BorderRadius.all(Radius.circular(_radiusValue))
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
                                  leading: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "No." + (index+1).toString(),
                                        style: const TextStyle(fontWeight: FontWeight.bold,),
                                      ),
                                    ],
                                  ),
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
                                        _showPersonRemoveAlertDialog(index);
                                      } else if(value == 'edit'){
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
                                  child: Text(
                                    "メモの色設定：",
                                    style: TextStyle(
                                      color: textButtonColor,
                                      fontSize: 20,
                                    ),
                                  )
                              ),
                              const SizedBox(width: 10.0,),
                              SizedBox(
                                child: TextButton(
                                  onPressed: () async {
                                    final color = await openColorSettingDialog(context);
                                    _changeMemoColor(color!);
                                  },
                                  child: Text("■", style: TextStyle(color: memo.color, fontSize: 30.0,),),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    side: const BorderSide(color: Colors.blue, width: 2.0,),
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
                const Divider(thickness: 0, height: 10.0,),

                /// ContentsView
                Row(
                  children: [
                    Container(
                      width: 50,
                      alignment: Alignment.center,
                      child: isDark
                          ? SvgPicture.asset("/images/svgs/serif_white.svg", width: 30,)
                          : SvgPicture.asset("/images/svgs/serif_black.svg", width: 30,),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(_edgeValueSmall),
                        height: 50.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: persons.length + 1,
                          itemBuilder: (BuildContext context, int index){
                            return personListViewOfContentsView(index);
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
                      child: isDark
                          ? SvgPicture.asset("/images/svgs//mood_white.svg", width: 30,)
                          : SvgPicture.asset("/images/svgs//mood_black.svg", width: 30,),
                    ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.all(_edgeValueSmall),
                        height: 50.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: persons.length + 1,
                          itemBuilder: (BuildContext context, int index){
                            return personListViewOfContentsViewForMood(index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(thickness: 0, height: 10.0,),

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
                          return contentListViewOfContentsView (index);
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
                                duration: const Duration(seconds: 1, milliseconds: 500),
                                curve: Curves.ease,
                              );
                            }),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              size: 20.0,
                            ),
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(EdgeInsets.zero),
                              backgroundColor: MaterialStateProperty.all(const Color(0xcc5e5e5e),),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  thickness: 1.0,
                  height: 20.0,
                ),

                /// OutputView
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(),
                          child: ElevatedButton(
                            child: const Text("読む用に出力", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                            onPressed: () async {
                              if(contents.any((content) => content.line == "")){
                                ResultAlertDialog selection = await _showWarningLineEmpty() as ResultAlertDialog;
                                if(selection == ResultAlertDialog.ok) {
                                  _outputForReading(context);
                                }
                              } else {
                                _outputForReading(context);
                              }
                            },
                          )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(),
                          child: ElevatedButton(
                            child: const Text("クリスタ用に出力", style: TextStyle(fontSize: 15),),
                            onPressed: () async {
                              if(contents.any((content) => content.line == "")){
                                ResultAlertDialog selection = await _showWarningLineEmpty() as ResultAlertDialog;
                                if(selection == ResultAlertDialog.ok){
                                  _outputForNameChanger(context);
                                }
                              } else {
                                _outputForNameChanger(context);
                              }
                            },
                          )
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _showIconForSerifOrMood(int index) {
    if(isDark){
      return contents[index].person.hasMood
          ? SvgPicture.asset("/images/svgs/mood_white.svg", width: 30, )
          : SvgPicture.asset("/images/svgs/serif_white.svg", width: 30,);
    } else {
      return contents[index].person.hasMood
          ? SvgPicture.asset("/images/svgs/mood_black.svg", width: 30,)
          : SvgPicture.asset("/images/svgs/serif_black.svg", width: 30,);
    }
  }

  Widget personListViewOfContentsView(int index) {
    setCombinedPersons();

    return Container(
      margin: const EdgeInsets.only(right: _edgeValueSmall),
      width: 100,
      decoration: BoxDecoration(
          border: Border.all(
            width: 2.0,
            color: personsCombinedMemo[index].color,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(_radiusValue))
      ),
      child: TextButton(
        onPressed: () {
          setState(() {
            contents.add( Content(
              person: Person(
                name: personsCombinedMemo[index].name,
                color: personsCombinedMemo[index].color,
                hasMood: false,
              ),
              line: "",
              controller: TextEditingController(),
            ));
            contents[contents.length-1].controller.addListener(_reflectTextValueForContentsView);
          });
          scrollControllerForContentsView.animateTo(
            macContext(),
            curve: Curves.ease,
            duration: const Duration(milliseconds: 750,),
          );
          // textEditingControllers.add(TextEditingController());
        },
        child: Padding(
          padding: EdgeInsets.zero,
          child: Text(
            personsCombinedMemo[index].name,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 12,
              color: textButtonColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget personListViewOfContentsViewForMood(int index) {
    setCombinedPersons();

    Widget widget = Container(
      margin: const EdgeInsets.only(right: _edgeValueSmall),
      width: 100,
    );

    if(personsCombinedMemo[index].hasMood){
      widget = Container(
        margin: const EdgeInsets.only(right: _edgeValueSmall),
        width: 100,
        decoration: BoxDecoration(
            border: Border.all(
              width: 2.0,
              color: personsCombinedMemo[index].color,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(_radiusValue))
        ),
        child: TextButton(
          onPressed: () {
            setState(() {
              contents.add(Content(
                person: Person(
                  name: personsCombinedMemo[index].name,
                  color: personsCombinedMemo[index].color,
                  hasMood: true,
                ),
                line: "",
                controller: TextEditingController(),
              ));
              contents[contents.length-1].controller.addListener(_reflectTextValueForContentsView);
            });
            scrollControllerForContentsView.animateTo(
              macContext(),
              curve: Curves.ease,
              duration: const Duration(milliseconds: 750,),
            );
            // textEditingControllers.add(TextEditingController());
          },
          child: Padding(
            padding: EdgeInsets.zero,
            child: Text(
              personsCombinedMemo[index].name,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 12,
                color: textButtonColor,
              ),
            ),
          ),
        ),
      );
    }

    return widget;
  }

  void setCombinedPersons() {
    if(persons.isEmpty){
      personsCombinedMemo = [memo];
    } else {
      personsCombinedMemo = [...persons];
      if(personsCombinedMemo[0] != memo) personsCombinedMemo.insert(0, memo);
    }
  }

  Widget contentListViewOfContentsView(int index) {
    return ListTile(
      key: Key('$index'),
      contentPadding: const EdgeInsets.only(left: 20.0, right: 15),
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
      title: Transform.translate(
        offset: const Offset(10, 0),
        child: TextFormField(
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(_edgeValueMedium),
              child: _showIconForSerifOrMood(index),
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
      trailing: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                contents[index].controller.removeListener(_reflectTextValueForContentsView);
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

  Future<void> _showPersonRemoveAlertDialog(int index) async{
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
          for(int i = 0; i < contents.length; i++){
            if(persons[index].name == contents[i].person.name){
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
              content: Container(
                padding: const EdgeInsets.all(_edgeValueMedium),
                margin: const EdgeInsets.all(_edgeValueMedium),
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0),
                  borderRadius: const BorderRadius.all(Radius.circular(_radiusValue)),
                ),
                child: Scrollbar(
                  isAlwaysShown: true,
                  child: SingleChildScrollView(
                    child: SelectableText(contentsForOutputToNameChanger,),
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

    for(var content in contents) {
      if(content.person == memo) continue;
      if(content.line.isEmpty) continue;

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
    // final TextEditingController newController = textEditingControllers.removeAt(oldIndex);
    final Content newContent = contents.removeAt(oldIndex);
    contents.insert(newIndex, newContent);
    // textEditingControllers.insert(newIndex, newController);
    contents[newIndex].controller.addListener(() {
      _reflectTextValueForContentsView();
    });
  }

  Future<UserCredential> _googleSignin() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope(
        'https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({
      'login_hint': 'user@example.com'
    });

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  Future<void> _googleAccountSignOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  double macContext() {
    double result;
    scrollControllerForContentsView.position.maxScrollExtent == 0
        ? result = scrollControllerForContentsView.position.maxScrollExtent
        : result = scrollControllerForContentsView.position.maxScrollExtent + 62;
    return result;
  }


}
