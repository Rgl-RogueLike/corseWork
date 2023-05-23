import 'dart:io';
import 'dart:convert';
import 'package:xml/xml.dart';

class Book {
  String title;
  String path;
  String author;
  List<String> imageDatas;

  Book({this.title = '', this.path = '', this.author = '', this.imageDatas = const []});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'path': path,
      'author': author,
      'imageDatas': imageDatas,
    };
  }

  static Future<Book> fromFile(File file) async {
    try {
      final content = await file.readAsString();
      final document = XmlDocument.parse(content);
      final metadata = document.findAllElements('title-info').first;
      final title = metadata.findAllElements('book-title').first.text;
      final authorElement = metadata.findAllElements('author').first;
      final author = '${authorElement.findElements('first-name').first.text} '
          '${authorElement.findElements('last-name').first.text}';
      final imageElements = document.findAllElements('binary');
      final imageDatas = imageElements.map((element) => element.text).toList();
      return Book(title: title, path: file.path, author: author, imageDatas: imageDatas);
    } catch (e) {
      print('Error while parsing file: $e');
      throw Exception('Failed to parse file');
    }
  }

  Future<List<List<int>>> decodeImages() async {
    final decodedImages = <List<int>>[];

    for (final imageData in imageDatas) {
      final bytes = base64.decode(imageData);
      decodedImages.add(bytes);
    }

    return decodedImages;
  }
}
