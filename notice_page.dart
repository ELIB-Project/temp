import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../auth_dio.dart';
import 'notice_content_page.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  int _page = 1;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  late ScrollController _controller;
  List<PostInfo> _postInfoList =
      []; // Create an empty list to hold the fetched data

  @override
  void initState() {
    super.initState();
    _initLoad();
    _controller = ScrollController()..addListener(_nextLoad);
  }

  void _initLoad() async {
    setState(() {
      _isFirstLoadRunning = true;
    });
    try {
      final List<PostInfo> loadedPosts =
          await loadPostInfo(_page); // Call the function to load data
      setState(() {
        _postInfoList = loadedPosts; // Update the list with the fetched data
      });
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _nextLoad() async {
    if (_hasNextPage &&
        !_isFirstLoadRunning &&
        !_isLoadMoreRunning &&
        _controller.position.extentAfter < 100) {
      setState(() {
        _isLoadMoreRunning = true;
      });
      _page += 1;
      try {
        // final res =
        //     await http.get(Uri.parse("$_url?_page=$_page&_limit=$_limit"));

        // final List fetchedPosts = json.decode(res.body);
        final List<PostInfo> loadedPosts =
            await loadPostInfo(_page); // Call the function to load data
        final List<PostInfo> fetchedPosts = loadedPosts;
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            _postInfoList.addAll(fetchedPosts);
          });
        } else {
          // This means there is no more data
          // and therefore, we will not send another GET request
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (e) {
        print(e.toString());
      }

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_nextLoad);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          scaffoldBackgroundColor: Color.fromARGB(255, 250, 250, 250),
          colorSchemeSeed: Color.fromARGB(0, 241, 241, 241),
          useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
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
        body: _isFirstLoadRunning
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      controller: _controller,
                      itemCount: _postInfoList.length,
                      itemBuilder: (context, index) => Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            _postInfoList[index].title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(_postInfoList[index].updated),
                          children: <Widget>[
                            ListTile(title: Text(_postInfoList[index].text)),
                          ],
                        ),
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     _navigateToNoticeContentPage(
                      //         context,
                      //         _postInfoList[index].title,
                      //         _postInfoList[index].text,
                      //         _postInfoList[index].updated);
                      //   },
                      //   child: ListTile(
                      //     tileColor: Colors.white,
                      // title: Text(
                      //   _postInfoList[index].title,
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // subtitle: Text(_postInfoList[index].updated),
                      //     trailing: Icon(Icons.more_vert),
                      //   ),
                      // ),
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                    ),
                  ),
                  if (_isLoadMoreRunning == true)
                    Container(
                      padding: const EdgeInsets.all(30),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

Future<int> loadPageNumber() async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/manage/notice');

  if (response.statusCode == 200) {
    return response.data;
    // print(list?[i].name);
  } else {
    throw Exception('fail');
  }
}

Future<List<PostInfo>> loadPostInfo(int pagenumber) async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/manage/notice/$pagenumber');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<PostInfo> list =
        data.map((dynamic e) => PostInfo.fromJson(e)).toList();
    return list;
    // print(list?[i].name);
  } else {
    throw Exception('fail');
  }
}

class PostInfo {
  final String title;
  final String text;
  final String updated;

  PostInfo({
    required this.title,
    required this.text,
    required this.updated,
  });

  factory PostInfo.fromJson(Map<String, dynamic> json) {
    return PostInfo(
      title: json['title'],
      text: json['text'],
      updated: json['updated'],
    );
  }
}

void _navigateToNoticeContentPage(
    BuildContext context, String title, String content, String updated) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          NoticeContentPage(title: title, content: content, updated: updated),
    ),
  );
}
