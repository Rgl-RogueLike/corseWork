import 'package:flutter/material.dart';
import '../models/book.dart';
import 'dart:convert';
import 'add_book_screen.dart';
import 'book_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  final List<Book> books;

  const HomeScreen({Key? key, required this.books}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _navigateToAddBookScreen(BuildContext context) async {
    final Book? newBook = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddBookScreen(
          onBookAdded: (book) {
            setState(() {
              widget.books.add(book);
            });
          },
        ),
      ),
    );
  }

  void _navigateToBookScreen(BuildContext context, Book book) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => BookScreen(book: book)),
    );

    if (result != null && result is bool && result) {
      _removeBook(context, book);
    }
  }

  void _removeBook(BuildContext context, Book book) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удаление книги'),
          content: Text('Вы уверены, что хотите удалить эту книгу?'),
          actions: <Widget>[
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Удалить'),
              onPressed: () async {
                Navigator.of(context).pop();
                final isFileDeleted = await _deleteBookFile(book);
                if (isFileDeleted) {
                  setState(() {
                    widget.books.remove(book);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Не удалось удалить файл книги')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _deleteBookFile(Book book) async {
    final file = File('${book.path}');
    try {
      await file.delete();
      return true;
    } catch (e) {
      print('Failed to delete book file: $e');
      return false;
    }
  }

  String removeInvalidBase64Characters(String base64String) {
    return base64String.replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), '');
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('О приложении'),
          content: Text('Данное приложение является курсовой работой студента '
              'группы ПИ2002 Никиты Харитонова.'
              'Данное приложение открывает книги формата .fb2.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(252, 235, 172, 1),
        title: Text('Приложение для чтения книг',
          style: TextStyle(color: Colors.black),),
        actions: [
          IconButton(
            icon: Icon(Icons.info,
            color: Colors.black),
            onPressed: () => _showAppInfoDialog(context),
          ),
        ],
      ),
      backgroundColor: Color.fromRGBO(252, 235, 172, 1),
      body: ListView.builder(
        itemCount: widget.books.length + 1,
        itemBuilder: (context, index) {
          if (index < widget.books.length) {
            final book = widget.books[index];
            final String? firstImageData =
            book.imageDatas.isNotEmpty ? removeInvalidBase64Characters(book.imageDatas[0]) : null;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 2.0,
              color: Color.fromRGBO(255, 255, 255, 1),
              child: ListTile(
                onTap: () => _navigateToBookScreen(context, book),
                leading: firstImageData != null
                    ? Image.memory(
                  base64.decode(firstImageData),
                  width: 48,
                  height: 48,
                )
                    : Container(width: 48, height: 48),
                title: Text(
                  book.title
                ),
                subtitle: Text(
                  book.author
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _removeBook(context, book);
                  },
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _navigateToAddBookScreen(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                ),
                child: Text('Добавить книгу',
                  style: TextStyle(color: Colors.black),),
              ),
            );
          }
        },
      ),
    );
  }
}
