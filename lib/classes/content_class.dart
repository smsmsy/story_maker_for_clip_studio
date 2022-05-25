import 'package:flutter/cupertino.dart';

import 'person_class.dart';

enum ContentType{
  memo,
  serif,
  mood,
}

/// 単純なContentクラス
class Content {
  Person person;
  String line;
  ContentType contentType;
  TextEditingController controller;

//<editor-fold desc="Data Methods">

  Content({
    required this.person,
    required this.line,
    required this.contentType,
    required this.controller,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Content &&
          runtimeType == other.runtimeType &&
          person == other.person &&
          line == other.line &&
          contentType == other.contentType &&
          controller == other.controller);

  @override
  int get hashCode =>
      person.hashCode ^
      line.hashCode ^
      contentType.hashCode ^
      controller.hashCode;

  @override
  String toString() {
    return 'Content{' +
        ' person: $person,' +
        ' line: $line,' +
        ' contentType: $contentType,' +
        ' controller: $controller,' +
        '}';
  }

  Content copyWith({
    Person? person,
    String? line,
    ContentType? contentType,
    TextEditingController? controller,
  }) {
    return Content(
      person: person ?? this.person,
      line: line ?? this.line,
      contentType: contentType ?? this.contentType,
      controller: controller ?? this.controller,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'person': this.person,
      'line': this.line,
      'contentType': this.contentType,
      'controller': this.controller,
    };
  }

  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      person: map['person'] as Person,
      line: map['line'] as String,
      contentType: map['contentType'] as ContentType,
      controller: map['controller'] as TextEditingController,
    );
  }

//</editor-fold>
}