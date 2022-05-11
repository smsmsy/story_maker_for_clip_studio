import 'package:flutter/material.dart';

/// 単純なPersonクラス
class Person {
  String name;
  Color color;

//<editor-fold desc="Data Methods">

  Person({
    required this.name,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Person &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          color == other.color);

  @override
  int get hashCode => name.hashCode ^ color.hashCode;

  @override
  String toString() {
    return 'Person{' + ' name: $name,' + ' color: $color,' + '}';
  }

  Person copyWith({
    String? name,
    Color? color,
  }) {
    return Person(
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'color': this.color,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      name: map['name'] as String,
      color: map['color'] as Color,
    );
  }

//</editor-fold>
}

