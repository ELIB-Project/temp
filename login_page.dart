import 'dart:convert';
import 'dart:io';
import 'package:elib_project/pages/name_auth_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:elib_project/pages/home_page.dart';
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../models/bottom_app_bar.dart';
import "package:shared_preferences/shared_preferences.dart";

final storage = new FlutterSecureStorage();

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
    this.accessToken,
    this.refreshToken,
    required this.title,
  }) : super(key: key);

  final String title;
  final String? accessToken;
  final String? refreshToken;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isCheckLoginStay = false;
  @override
  void initState() {
    super.initState();
    checkLoginStay();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _asyncMethod();
    // });
  }

  void checkLoginStay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('_isCheckLoginStay') == true) {
      setState(() {
        _isCheckLoginStay = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _asyncMethod();
      });
    }
  }

  void changeLoginStay(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCheckLoginStay = value;
      prefs.setBool('_isCheckLoginStay', value);
    });
  }

  _asyncMethod() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'ACCESS_TOKEN');

    if (accessToken != null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => BulidBottomAppBar(
                    index: 2,
                  )),
          (route) => false);
    } else {
      print('Try Login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(top: 100)),
          Image.asset('assets/image/eliblogo.png', width: 288, height: 150),
          const Text("Every Life Is Beautiful"),
          const Padding(
            padding: EdgeInsets.only(top: 50),
          ),
          InkWell(
            onTap: () async {
              if (await isKakaoTalkInstalled()) {
                print('카카오톡으로 로그인 성공');
                // KakaoTalk이 설치된 경우의 로그인 처리
                try {
                  await UserApi.instance.loginWithKakaoTalk();
                  User user = await UserApi.instance.me();
                  final token = await FirebaseMessaging.instance.getToken();
                  print("내 디바이스 토큰: $token");
                  var userToken = await sendData(
                      user.id.toString(), '/login/oauth2/code/kakao', token!);
                  if (await nameAuthsendData(
                          '/api/v1/user/detail/check', userToken!) ==
                      'true') {
                    print('성공');
                    await Future.delayed(const Duration(seconds: 1));
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                BulidBottomAppBar(
                                  index: 2,
                                )),
                        (route) => false);
                  } else {
                    print('실패');
                    _navigateToNameAuthPage(context);
                  }
                } catch (error) {
                  print('카카오톡으로 로그인 실패 $error');
                  if (error is PlatformException && error.code == 'CANCELED') {
                    return;
                  }
                  try {
                    await UserApi.instance.loginWithKakaoAccount();
                    print('카카오계정으로 로그인 성공');
                    User user = await UserApi.instance.me();
                    final token = await FirebaseMessaging.instance.getToken();
                    print("내 디바이스 토큰: $token");
                    var userToken = await sendData(
                        user.id.toString(), '/login/oauth2/code/kakao', token!);
                    if (await nameAuthsendData(
                            '/api/v1/user/detail/check', userToken!) ==
                        'true') {
                      print('성공');

                      await Future.delayed(const Duration(seconds: 1));
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  BulidBottomAppBar(
                                    index: 2,
                                  )),
                          (route) => false);
                    } else {
                      print('실패');
                      _navigateToNameAuthPage(context);
                    }
                    print('카카오계정으로 로그인 성공');
                  } catch (error) {
                    print('카카오계정으로 로그인 실패 $error');
                  }
                }
              } else {
                // KakaoTalk이 설치되지 않은 경우의 로그인 처리
                try {
                  await UserApi.instance.loginWithKakaoAccount();
                  User user = await UserApi.instance.me();
                  final token = await FirebaseMessaging.instance.getToken();
                  print("내 디바이스 토큰: $token");
                  var userToken = await sendData(
                      user.id.toString(), '/login/oauth2/code/kakao', token!);
                  if (await nameAuthsendData(
                          '/api/v1/user/detail/check', userToken!) ==
                      'true') {
                    print('성공');
                    await Future.delayed(const Duration(seconds: 1));
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                BulidBottomAppBar(
                                  index: 2,
                                )),
                        (route) => false);
                  } else {
                    print('실패');
                    _navigateToNameAuthPage(context);
                  }
                  print('카카오계정으로 로그인 성공');
                } catch (error) {
                  print('카카오계정으로 로그인 실패 $error');
                }
              }
            },
            child: Card(
              elevation: 1,
              color: Colors.yellow,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: const SizedBox(
                width: 300,
                height: 45,
                child: Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.chat_bubble_fill),
                      SizedBox(width: 60),
                      Text(
                        "카카오로 계속하기",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Row(
              children: [
                Checkbox(
                  value: _isCheckLoginStay,
                  onChanged: (value) {
                    changeLoginStay(value!);
                  },
                ),
                Text(
                  "로그인 상태 유지하기",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 80.0),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 2.0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    '또는',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 2.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    final NaverLoginResult result =
                        await FlutterNaverLogin.logIn();
                    final token = await FirebaseMessaging.instance.getToken();
                    print("내 디바이스 토큰: $token");
                    var userToken = await sendData(
                        result.account.id, "/login/oauth2/code/naver", token!);
                    print(" 네이버 로그인 ${userToken}");
                    if (await nameAuthsendData(
                            '/api/v1/user/detail/check', userToken!) ==
                        'true') {
                      print('성공');
                      await Future.delayed(const Duration(seconds: 1));
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  BulidBottomAppBar(
                                    index: 2,
                                  )),
                          (route) => false);
                    } else {
                      print('실패');
                      _navigateToNameAuthPage(context);
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset('assets/image/naver_logo.png',
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                InkWell(
                  onTap: () async {
                    final GoogleSignInAccount? googleUser =
                        await GoogleSignIn().signIn();
                    final token = await FirebaseMessaging.instance.getToken();
                    print("내 디바이스 토큰: $token");
                    var userToken = await sendData(
                        googleUser!.id, "/login/oauth2/code/google", token!);
                    print("구글 로그인 ${userToken}");
                    if (await nameAuthsendData(
                            '/api/v1/user/detail/check', userToken!) ==
                        'true') {
                      print('성공');
                      await Future.delayed(const Duration(seconds: 1));
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  BulidBottomAppBar(
                                    index: 2,
                                  )),
                          (route) => false);
                    } else {
                      print('실패');
                      _navigateToNameAuthPage(context);
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset('assets/image/google_logo.png',
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('문의하기'),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.grey,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('(주)엘립'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> sendData(String data, String path, String token) async {
  final httpsUri =
      Uri.https('elib.elib-app-service.o-r.kr:8080', path, {'limit': '10'});
  final headers = {
    'App-Identifier':
        "\$2a\$12\$j/HiFV6r3yh4evvgB/5qLOFHtM/mpUlXkItuZUk3GMSrwRpnklU5O"
  };
  http.Response response = await http.post(httpsUri,
      headers: headers,
      body: jsonEncode({'id': data.toString(), 'fcmToken': token}));

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

  return response.headers['authorization'];
}

Future<String> nameAuthsendData(String path, String token) async {
  final httpsUri =
      Uri.https('elib.elib-app-service.o-r.kr:8080', path, {'limit': '10'});
  final headers = {
    'Authorization': token,
    'App-Identifier':
        "\$2a\$12\$j/HiFV6r3yh4evvgB/5qLOFHtM/mpUlXkItuZUk3GMSrwRpnklU5O"
  };
  http.Response res = await http.get(httpsUri, headers: headers);
  return res.body;
}

void _navigateToNameAuthPage(BuildContext context) {
  //구성원 관리
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NameAuthPage(),
    ),
  );
}
