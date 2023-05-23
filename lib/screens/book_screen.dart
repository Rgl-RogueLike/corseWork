import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:xml/xml.dart';
import '../models/book.dart';

class BookScreen extends StatefulWidget {
  final Book book;

  const BookScreen({Key? key, required this.book}) : super(key: key);

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  List<List<XmlNode>> _pages = [];

  @override
  void initState() {
    super.initState();
    loadBookContents();
  }

  Future<void> loadBookContents() async {
    try {
      final contents = await File(widget.book.path).readAsString();
      final document = XmlDocument.parse(contents);
      final paragraphs = document.findAllElements('p').toList();
      final maxCharsPerPage = _getMaxCharsPerPage(context);

      int count = 0;
      int pageIndex = 0;
      List<XmlNode> page = [];

      for (var paragraph in paragraphs) {
        final text = paragraph.text;

        if (text.length > maxCharsPerPage) {
          final regex = RegExp('.{1,$maxCharsPerPage}(\\s+|\$)', multiLine: true);
          final matches = regex.allMatches(text);
          for (var match in matches) {
            final splitText = match.group(0)!;
            final xmlText = '<p>${splitText.trim()}</p>';
            final xmlElement = XmlDocument.parse(xmlText).rootElement.children.first;
            if (count + splitText.length > maxCharsPerPage) {
              _pages.add(page);
              pageIndex++;
              page = [];
              count = 0;
            }
            count += splitText.length;
            page.add(xmlElement);
          }
          if (count + text.length > maxCharsPerPage) {
            _pages.add(page);
            pageIndex++;
            page = [];
            count = 0;
          }
        } else {
          if (count + text.length > maxCharsPerPage) {
            _pages.add(page);
            pageIndex++;
            page = [];
            count = 0;
          }
          count += text.length;
          page.add(paragraph);
        }
      }

      if (page.isNotEmpty) {
        _pages.add(page);
      }

      if (page.isNotEmpty) {
        _pages.add(page);
      }

      setState(() {});
    } catch (e) {
      print('Error loading book contents: $e');
    }
  }

  int _getMaxCharsPerPage(BuildContext context) {
    final textHeight = MediaQuery.of(context).size.height;
    final fontSize = Theme.of(context).textTheme.bodyText1?.fontSize ?? 14;
    final lineHeight = fontSize * 1.5;
    final maxChars = (textHeight ~/ lineHeight) * 50;
    return maxChars;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final pageWidth = screenSize.width * 0.95;
    final pageHeight = screenSize.height * 0.99;

    return Scaffold(
      backgroundColor: Color.fromRGBO(252, 235, 172, 1),
      body: _pages.isNotEmpty
          ? Container(
        width: pageWidth,
        height: pageHeight,
        child: PageView.builder(
          itemCount: _pages.length,
          itemBuilder: (context, pageIndex) {
            final page = _pages[pageIndex];
            final htmlData = page
                .where((node) =>
            node.nodeType == XmlNodeType.ELEMENT &&
                (node is XmlElement &&
                    (node.name.local == 'p' ||
                        node.name.local == 'title')))
                .map((node) => node.toXmlString())
                .join();

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Html(
                        data: htmlData,
                        onLinkTap: (url, context, attributes, element) {
                          print('Link tapped: $url');
                        },
                        style: {
                          'a': Style(
                            textDecoration: TextDecoration.none,
                            color: Colors.blue,
                          ),
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Страница ${pageIndex + 1} из ${_pages.length}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
