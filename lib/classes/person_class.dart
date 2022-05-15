import 'package:flutter/material.dart';

/// 単純なPersonクラス
class Person {
  String name;
  Color color;
  bool hasMood;

//<editor-fold desc="Data Methods">

  Person({
    required this.name,
    required this.color,
    required this.hasMood,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Person &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              color == other.color &&
              hasMood == other.hasMood);

  @override
  int get hashCode => name.hashCode ^ color.hashCode ^ hasMood.hashCode;

  @override
  String toString() {
    return 'Person{ name: $name, color: $color, hasMood: $hasMood, }';
  }

  Person copyWith({
    String? name,
    Color? color,
    bool? hasMood,
  }) {
    return Person(
      name: name ?? this.name,
      color: color ?? this.color,
      hasMood: hasMood ?? this.hasMood,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
      'hasMood': hasMood,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      name: map['name'] as String,
      color: map['color'] as Color,
      hasMood: map['hasMood'] as bool,
    );
  }

//</editor-fold>
}

