import 'package:flutter/cupertino.dart';

import 'person_class.dart';

/// 単純なContentクラス
class Content {
  Person person;
  String line;
  TextEditingController controller;

//<editor-fold desc="Data Methods">


  Content({
    required this.person,
    required this.line,
    required this.controller,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Content &&
              runtimeType == other.runtimeType &&
              person == other.person &&
              line == other.line &&
              controller == other.controller
          );


  @override
  int get hashCode =>
      person.hashCode ^
      line.hashCode ^
      controller.hashCode;


  @override
  String toString() {
    return 'Content{ person: $person, line: $line, controller: $controller }';
  }


  Content copyWith({
    Person? person,
    String? line,
    TextEditingController? controller,
  }) {
    return Content(
      person: person ?? this.person,
      line: line ?? this.line,
      controller: controller ?? this.controller,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'person': person,
      'line': line,
      'controller': controller,
    };
  }

  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      person: map['person'] as Person,
      line: map['line'] as String,
      controller: map['controller'] as TextEditingController,
    );
  }


//</editor-fold>
}