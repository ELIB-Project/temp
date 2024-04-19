import 'package:elib_project/auth_dio.dart';
import 'package:elib_project/models/bottom_app_bar.dart';
import 'package:elib_project/pages/edit_info_page.dart';
import 'package:elib_project/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SetPage extends StatefulWidget {
  const SetPage({super.key});

  @override
  State<SetPage> createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
  @override
  Widget build(BuildContext context) {
    final double querywidth = MediaQuery.of(context).size.width;
    final double queryheight = MediaQuery.of(context).size.height;

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
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => BulidBottomAppBar(
                              index: 4,
                            )),
                    (route) => false);
              },
            ),
            title: const Text(
              "설정",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            // 나머지 AppBar 설정
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      querywidth * 0.05, 0, querywidth * 0.05, 0),
                  child: const Text(
                    "내정보",
                    style: TextStyle(
                        color: Color.fromRGBO(171, 171, 171, 1.0),
                        fontSize: 18),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _navigateToEditInfoPage(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            querywidth * 0.05,
                            queryheight * 0.01,
                            querywidth * 0.05,
                            queryheight * 0.01),
                        child: Text(
                          "회원 정보 수정",
                          style: TextStyle(
                            color: Color.fromRGBO(131, 131, 131, 1.0),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: querywidth * 0.05),
                        child: const Icon(Icons.arrow_forward_ios_rounded),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      querywidth * 0.05,
                      queryheight * 0.05,
                      querywidth * 0.05,
                      queryheight * 0.01),
                  child: Text("설정",
                      style: TextStyle(
                        color: Color.fromRGBO(171, 171, 171, 1.0),
                        fontSize: 18,
                      )),
                ),
                InkWell(
                  onTap: () {
                    //로그아웃 페이지로이동
                    LogOutBottonSheet(context);
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            querywidth * 0.05,
                            queryheight * 0.01,
                            querywidth * 0.05,
                            queryheight * 0.01),
                        child: Text(
                          "로그아웃",
                          style: TextStyle(
                            color: Color.fromRGBO(131, 131, 131, 1.0),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    //회원탈퇴 페이지로이동
                    resignBottonSheet(context);
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            querywidth * 0.05,
                            queryheight * 0.01,
                            querywidth * 0.05,
                            queryheight * 0.01),
                        child: Text(
                          "회원탈퇴",
                          style: TextStyle(
                            color: Color.fromRGBO(131, 131, 131, 1.0),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

//로그아웃 BottomSheet
  void LogOutBottonSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.white, // 모달 배경색
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0), // 모달 좌상단 라운딩 처리
              topRight: Radius.circular(0), // 모달 우상단 라운딩 처리
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(flex: 1, child: Container()),
                Expanded(
                    flex: 1,
                    child: Text(
                      '로그아웃 하시겠습니까?',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.normal,
                      ),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: BorderSide(
                                        color: Colors.red,
                                      ))),
                            ),
                            child: const Text('예'),
                            onPressed: () async {
                              final storage = FlutterSecureStorage();
                              await storage.delete(key: 'ACCESS_TOKEN');
                              _navigateToLoginPage(context);
                            },
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.grey.shade300),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ))),
                            ),
                            child: const Text('아니오'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //회원탈퇴 bottomsheet
  void resignBottonSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.white, // 모달 배경색
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0), // 모달 좌상단 라운딩 처리
              topRight: Radius.circular(0), // 모달 우상단 라운딩 처리
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(flex: 1, child: Container()),
                Expanded(
                    flex: 1,
                    child: Text(
                      '회원탈퇴 하시겠습니까?',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.normal,
                      ),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: BorderSide(
                                        color: Colors.red,
                                      ))),
                            ),
                            child: const Text('예'),
                            onPressed: () async {
                              String result = await resignsendData();
                              if (result != null) {
                                _navigateToLoginPage(context);
                              }
                            },
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.grey.shade300),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ))),
                            ),
                            child: const Text('아니오'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _navigateToEditInfoPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditInfoPage(),
    ),
  );
}

void _navigateToLoginPage(BuildContext context) {
  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => LoginPage(
                title: "login",
              )),
      (route) => false);
}

resignsendData() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.delete('/api/v1/user/resign');
  if (response.statusCode == 200) {
    print(response.data);
    return response.data;
  }
}
