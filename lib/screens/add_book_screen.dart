import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddBookScreen extends StatefulWidget {
  final Function(Book) onBookAdded;

  AddBookScreen({Key? key, required this.onBookAdded}) : super(key: key);

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  late File _bookFile;
  bool _fileSelected = false;
  String _bookTitle = '';
  String _bookAuthor = '';

  void _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    if (result != null && result.files.isNotEmpty && result.files.first.extension?.toLowerCase() == 'fb2') {
      setState(() {
        _bookFile = File(result.files.single.path!);
        _fileSelected = true;
        _bookTitle = _bookFile.path.split('/').last;
        _bookAuthor = '';
        _getBookDetails();
      });
    } else return;
  }

  Future<void> _getBookDetails() async {
    final book = await Book.fromFile(_bookFile);
    setState(() {
      _bookTitle = book.title;
      _bookAuthor = book.author;
    });
  }

  Future<void> _addBook() async {
    if (_bookFile != null) {
      final appDocDir = await getApplicationDocumentsDirectory();
      final bookDir = Directory("${appDocDir.path}/book");
      if (!await bookDir.exists()) {
        await bookDir.create(recursive: true);
      }

      final existingFiles = bookDir.listSync();
      final existingBookPaths = existingFiles.map((file) => file.path).toList();
      if (existingBookPaths.contains('${bookDir.path}/$_bookTitle')) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Книга уже добавлена'),
              content: Text('Эта книга уже добавлена в приложение.'),
              actions: <Widget>[
                TextButton(
                  child: Text('ОК'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      final newFile = await _bookFile.copy('${bookDir.path}/$_bookTitle');
      final book = await Book.fromFile(newFile);
      widget.onBookAdded(book);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(252, 235, 172, 1),
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Добавление книги',
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Color.fromRGBO(252, 235, 172, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_fileSelected) ...[
              Text('Название книги: $_bookTitle'),
              Text('Автор: $_bookAuthor'),
              SizedBox(height: 16.0),
            ],
            ElevatedButton(
              onPressed: _openFileExplorer,
              child: Text('Выберите книгу',
                style: TextStyle(color: Colors.black),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addBook,
              child: Text('Добавить книгу',
                style: TextStyle(color: Colors.black),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
