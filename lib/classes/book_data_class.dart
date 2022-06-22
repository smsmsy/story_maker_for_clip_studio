class BookData {
  String title;
  List<dynamic> contents;

//<editor-fold desc="Data Methods">

  BookData({
    required this.title,
    required this.contents,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookData &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          contents == other.contents);

  @override
  int get hashCode => title.hashCode ^ contents.hashCode;

  @override
  String toString() {
    return 'BookData{ title: $title, contents: $contents,}';
  }

  BookData copyWith({
    String? title,
    List<dynamic>? contents,
  }) {
    return BookData(
      title: title ?? this.title,
      contents: contents ?? this.contents,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'contents': contents,
    };
  }

  factory BookData.fromMap(Map<String, dynamic> map) {
    return BookData(
      title: map['title'] as String,
      contents: map['contents'] as List<dynamic>,
    );
  }

//</editor-fold>
}