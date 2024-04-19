import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../auth_dio.dart';

class NoticeContentPage extends StatefulWidget {
  const NoticeContentPage(
      {super.key,
      required this.title,
      required this.content,
      required this.updated});

  final String title;
  final String content;
  final String updated;
  @override
  State<NoticeContentPage> createState() => _NoticeContentPageState();
}

class _NoticeContentPageState extends State<NoticeContentPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 250, 250, 250),
          colorSchemeSeed: Color.fromARGB(0, 241, 241, 241),
          useMaterial3: true),
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                Navigator.pop(context, true); // 뒤로가기 버튼 클릭 이벤트 처리
              },
            ),
            title: const Text(
              "공지사항",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Text(
                    widget.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Text(widget.updated),
                ),
                const Divider(
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(widget.content,
                      style: const TextStyle(
                        fontSize: 18,
                      )),
                ),
              ],
            ),
          )),
    );
  }
}
