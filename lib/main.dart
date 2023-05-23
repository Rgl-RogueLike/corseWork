import 'dart:io';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'models/book.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<Book> books = [];
  Directory appDocDir = await getApplicationDocumentsDirectory();
  Directory bookDir = Directory("${appDocDir.path}/book");
  if (!await bookDir.exists()) {
    await bookDir.create();
  }

  List<FileSystemEntity> files = bookDir.listSync();
  for (FileSystemEntity file in files) {
    if (file is File) {
      Future<Book?> bookFuture = Book.fromFile(file);
      Book? book = await bookFuture;
      if (book != null) {
        books.add(book);
      }
    }
  }
  runApp(MyApp(books: books));
}

class MyApp extends StatelessWidget {
  final List<Book> books;

  const MyApp({Key? key, required this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(books: books),
    );
  }
}
