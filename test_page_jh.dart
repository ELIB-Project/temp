import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io'; //쿠키
import 'package:elib_project/auth_dio.dart';

const account = "testKakao1";

Future<void> signIn() async {
  //초기 회원가입 메소드처럼 구현해놓은것
  final storage = new FlutterSecureStorage(); //로그인페이지에 넣어줘야하는

  final httpsUri =
      Uri.http('test.elibtest.r-e.kr:8080', '/login/test', {'limit': '10'});
  final http.Response response = await http.get(httpsUri);

  if (response.statusCode == 200) {
    final accessToken = await response.headers['authorization'];

    var exp = RegExp(r"((?:[^,]|, )+)");
    final Iterable<RegExpMatch> matches =
        await exp.allMatches(response.headers["set-cookie"]!);

    for (final m in matches) {
      // 쿠키 한개에 대한 디코딩 처리
      Cookie cookie = Cookie.fromSetCookieValue(m[0]!);
      var refresh = cookie.value;
      final refreshToken = "Bearer " + refresh.substring(7);

      print("accesstoken: $accessToken");
      print("refreshtoken: $refreshToken");

      await storage.write(key: 'ACCESS_TOKEN', value: accessToken);
      await storage.write(key: 'REFRESH_TOKEN', value: refreshToken);
    } // for
  } else {
    print('signIn Error..................');
  }
}

class Score {
  final int totalScore;
  final int toolScore;
  final int oldToolScore;
  final int trainScore;
  final int oldTrainScore;

  const Score({
    required this.totalScore,
    required this.toolScore,
    required this.oldToolScore,
    required this.trainScore,
    required this.oldTrainScore,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      totalScore: json['totalScore'],
      toolScore: json['toolScore'],
      oldToolScore: json['oldToolScore'],
      trainScore: json['trainScore'],
      oldTrainScore: json['oldTrainScore'],
    );
  }
}

Future<void> loadScore() async {
  print("PostEvent-------------------------------------------------------");

  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/user/score');

  // if (response.statusCode == 200) {
  //   // If the server did return a 200 OK response,
  //   // then parse the JSON.
  //   return Album.fromJson(jsonDecode(response.body));
  // } else {
  //   // If the server did not return a 200 OK response,
  //   // then throw an exception.
  //   throw Exception('Failed to load album');
  // }

  print("Data:${response.data}");
  print(
      "PostEvent End -------------------------------------------------------");
}

Future<String?> sendData(String path) async {
  final httpsUri = Uri.http('test.elibtest.r-e.kr:8080', path, {'limit': '10'});
  //http.post는 리턴값이 Future이기 떄문에 async 함수 내에서 await로 호출할 수 있다.
  http.Response res =
      await http.post(httpsUri, body: jsonEncode({'code': account}));
  //여기서는 응답이 객체로 변환된 res 변수를 사용할 수 있다.
  //여기서 res.body를 jsonDecode 함수로 객체로 만들어서 데이터를 처리할 수 있다.
  return res.headers['Authorization']; //작업이 끝났기 때문에 리턴
}

class testPage extends StatefulWidget {
  const testPage({super.key});

  @override
  State<testPage> createState() => _testPageState();
}

class _testPageState extends State<testPage> {
  signTest() async {
    try {
      await signIn();
    } catch (e) {
      print('error...$e');
    }
  }

  postTest() async {
    try {
      await loadScore();
    } catch (e) {
      print('error...$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      home: Scaffold(
        body: SafeArea(
          top: true,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 5.0),
              Image.asset(
                'assets/image/eliblogo.png',
                width: 95.95,
                height: 50,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '안녕하세요 ',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            '오늘의 우리집 안전점수는?',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 110, 110, 110),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SafetyScoreBox(),
                  ],
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ToolScoreBox(),
                  TrainingScoreBox(),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '구성원 현황',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 110, 110, 110),
                      ),
                    ),
                    //FamilyScoreBox(),
                    ElevatedButton(
                      onPressed: signTest,
                      child: Text('SignIn'),
                    ),
                    ElevatedButton(
                      onPressed: postTest,
                      child: Text('Post'),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _bulidBottomAppBar(),
      ),
    );
  }
}

class ToolScoreBox extends StatelessWidget {
  const ToolScoreBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: SizedBox(
                width: 190,
                height: 140,
                child: Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Column(children: const <Widget>[
                    Icon(
                      Icons.construction,
                      color: Colors.green,
                      size: 30,
                    ),
                    Text(
                      '재난대비 도구 현황',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 110, 110, 110),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: '10',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: '  점',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold))
                        ])),
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_drop_up,
                              color: Colors.green,
                              size: 50,
                            ),
                          ],
                        ),
                      ],
                    )
                  ]),
                ))));
  }
}

class TrainingScoreBox extends StatelessWidget {
  const TrainingScoreBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: SizedBox(
              width: 190,
              height: 140,
            )));
  }
}

class FamilyScoreBox extends StatelessWidget {
  const FamilyScoreBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: SizedBox(
              width: 120,
              height: 120,
            )));
  }
}

class SafetyScoreBox extends StatefulWidget {
  const SafetyScoreBox({super.key});

  @override
  State<SafetyScoreBox> createState() => _SafetyScoreBoxState();
}

class _SafetyScoreBoxState extends State<SafetyScoreBox> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: SizedBox(
            width: 400,
            height: 150,
            child: Column(children: [
              Row(children: <Widget>[
                Container(
                  width: 200,
                  height: 150,
                  child: Column(
                    children: [
                      Spacer(),
                      Center(
                        child: Image.asset(
                          'assets/image/firefighter.png',
                          width: 150,
                          height: 110,
                        ),
                      ),
                      Container(
                          width: 150,
                          height: 30,
                          child: Center(
                            child: LinearPercentIndicator(
                              lineHeight: 15,
                              percent: 0.6,
                              progressColor: Colors.green,
                            ),
                          ))
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  width: 170,
                  height: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 85,
                          height: 25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.green,
                          ),
                          child: const Center(
                            child: Text(
                              'Good',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          )),
                      const Text.rich(TextSpan(children: [
                        TextSpan(
                            text: '60',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 70,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: '  점',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold))
                      ]))
                    ],
                  ),
                )
              ])
            ]),
          )),
    );
  }
}

BottomAppBar _bulidBottomAppBar() {
  return BottomAppBar(
    elevation: 1,
    child: SizedBox(
      height: kBottomNavigationBarHeight,
      // color: Colors.white,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              children: const <Widget>[
                Icon(
                  Icons.construction,
                ),
                Text("도구관리")
              ],
            ),
            Column(
              children: const <Widget>[
                Icon(
                  Icons.edit_document,
                ),
                Text("훈련관리")
              ],
            ),
            Column(
              children: const <Widget>[
                Icon(
                  Icons.home,
                ),
                Text("홈")
              ],
            ),
            Column(
              children: const <Widget>[
                Icon(
                  Icons.groups,
                ),
                Text("구성원관리")
              ],
            ),
            Column(
              children: const <Widget>[
                Icon(
                  Icons.more_horiz,
                ),
                Text("더보기")
              ],
            )
          ]),
    ),
  );
}
