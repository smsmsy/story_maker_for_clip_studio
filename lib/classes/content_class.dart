import 'person_class.dart';

/// 単純なContentクラス
class Content {
  Person person;
  String line;

//<editor-fold desc="Data Methods">

  Content({
    required this.person,
    required this.line,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Content &&
          runtimeType == other.runtimeType &&
          person == other.person &&
          line == other.line);

  @override
  int get hashCode => person.hashCode ^ line.hashCode;

  @override
  String toString() {
    return 'Content{' + ' person: $person,' + ' line: $line,' + '}';
  }

  Content copyWith({
    Person? person,
    String? line,
  }) {
    return Content(
      person: person ?? this.person,
      line: line ?? this.line,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'person': this.person,
      'line': this.line,
    };
  }

  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      person: map['person'] as Person,
      line: map['line'] as String,
    );
  }

//</editor-fold>
}