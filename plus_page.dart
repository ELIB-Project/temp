import 'dart:convert';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:elib_project/models/bottom_app_bar.dart';
import 'package:elib_project/pages/notice_page.dart';
import 'package:elib_project/pages/test_nfc_page.dart';
import 'package:elib_project/pages/set_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:elib_project/pages/test_nfc_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../auth_dio.dart';

late Future<userInfo> user_info;

class PlusPage extends StatefulWidget {
  const PlusPage({super.key, required String title});

  @override
  State<PlusPage> createState() => _PlusPageState();
}

class _PlusPageState extends State<PlusPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    user_info = load_UserInfo();
    return FutureBuilder<userInfo>(
        future: user_info,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 데이터를 아직 받아오는 중이면 로딩 표시를 보여줌
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 데이터를 받아오는 도중 에러가 발생하면 에러 메시지를 보여줌
            return Text('Error: ${snapshot.error}');
          } else {
            userInfo entries = snapshot.data!;

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  scaffoldBackgroundColor: Color.fromARGB(255, 250, 250, 250),
                  colorSchemeSeed: Color.fromARGB(0, 241, 241, 241),
                  useMaterial3: true),
              home: Scaffold(
                appBar: AppBar(
                  backgroundColor: Color.fromARGB(255, 250, 250, 250),
                ),
                body: SafeArea(
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/image/eliblogo.png',
                        width: 95.95,
                        height: 50,
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 1.5),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 7.0,
                                    offset: Offset(
                                        2, 5), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: 350,
                                height: 150,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: entries.imgUrl == null
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    width: 2,
                                                    color: Colors.grey),
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        entries.imgUrl!),
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("${entries.name} 님"),
                                          Text(
                                            '${entries.phone.substring(0, 3)}-${entries.phone.substring(3, 7)}-${entries.phone.substring(7)}',
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                          onTap: () {
                                            // _navigateToSettingPage(context);
                                            Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SetPage()))
                                                .then((value) {
                                              setState(() {
                                                user_info = load_UserInfo();
                                              });
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1.0,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.settings,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          )),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Text(
                                'more',
                                style:
                                    TextStyle(fontSize: 22, color: Colors.grey),
                              )),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(padding: EdgeInsets.all(15)),
                          Icon(Icons.link, size: 24),
                          SizedBox(width: 10),
                          InkWell(
                              onTap: () async {
                                await launch(
                                    'http://ellip.dodosolution.net/main',
                                    forceWebView: false,
                                    forceSafariVC: false);
                              },
                              child: const Text(
                                'ELIB 바로가기',
                                style: TextStyle(fontSize: 18),
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Padding(padding: EdgeInsets.all(15)),
                          Icon(Icons.help_outline, size: 24),
                          SizedBox(width: 10),
                          InkWell(
                            onTap: () async {
                              if (!(await NfcManager.instance.isAvailable())) {
                                if (Platform.isAndroid) {
                                  // ignore: use_build_context_synchronously
                                  await showDialog(
                                    context: context,
                                    builder: (context) => Theme(
                                      data: ThemeData(
                                        dialogBackgroundColor: Colors
                                            .white, // Override dialog background color
                                      ),
                                      child: AlertDialog(
                                        backgroundColor:
                                            Color.fromRGBO(255, 250, 250, 1),
                                        title: const Text("오류"),
                                        content: const Text(
                                          "NFC를 지원하지 않는 기기이거나 일시적으로 비활성화 되어 있습니다.",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              AppSettings.openAppSettings(
                                                  type: AppSettingsType.nfc);
                                            },
                                            child: const Text("설정",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text("확인",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                throw "NFC를 지원하지 않는 기기이거나 일시적으로 비활성화 되어 있습니다.";
                              } else {
                                if (Platform.isAndroid) {
                                  String id = await showDialog(
                                    context: context,
                                    builder: (context) => _AndroidSessionDialog(
                                        "기기를 필터 가까이에 가져다주세요.", _handleTag),
                                  );
                                }
                              }
                            },
                            child: Text(
                              'NFC 설정',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Padding(padding: EdgeInsets.all(15)),
                          const Icon(Icons.event_available_rounded, size: 24),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              _navigateToNoticePage(context);
                            },
                            child: const Text(
                              '공지사항',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}

Future<userInfo> load_UserInfo() async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/user/detail');

  if (response.statusCode == 200) {
    print("ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ");
    print(response.data);
    return userInfo.fromJson(response.data);
  } else {
    throw Exception('fail');
  }
}

class userInfo {
  final int id;
  final String name;
  final String birth;
  final String phone;
  final String? imgUrl;

  userInfo(
      {required this.id,
      required this.name,
      required this.birth,
      required this.phone,
      required this.imgUrl});

  factory userInfo.fromJson(Map<String, dynamic> json) {
    return userInfo(
        id: json['id'],
        name: json['name'],
        birth: json['birth'],
        phone: json['phone'],
        imgUrl: json['image']);
  }
}

void _navigateToSettingPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SetPage(),
    ),
  );
}

void _navigateToNoticePage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const NoticePage(),
    ),
  );
}

class _AndroidSessionDialog extends StatefulWidget {
  const _AndroidSessionDialog(this.alertMessage, this.handleTag);

  final String alertMessage;

  final String Function(NfcTag tag) handleTag;

  @override
  State<StatefulWidget> createState() => _AndroidSessionDialogState();
}

class _AndroidSessionDialogState extends State<_AndroidSessionDialog> {
  String? _alertMessage;
  String? _errorMessage;

  String? _result;

  @override
  void initState() {
    super.initState();

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          _result = widget.handleTag(tag);

          var ndef = Ndef.from(tag);
          if (ndef == null || !ndef.isWritable) {
            throw "쓰기가 불가능한 NFC 태그 입니다.";
          }
          NdefMessage message = await ndef.read();

          if (message == null) {
            throw "Failed to read NDEF message from NFC tag.";
          }
          NdefRecord record = message.records[0]; // Assuming there's one record
          print("ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ");
          String storedText = String.fromCharCodes(record.payload);

          // Now you have the stored text in the NFC tag, and you can use it as needed.
          print("Stored text: $storedText");
          if (storedText.contains("elib")) {
            makePhoneCall("01095215654");
          }

          // 여기 위주로 확인해보자!!
          // late NdefMessage message;
          // NdefMessage(<NdefRecord>[NdefRecord.createText("asdas")]);
          // NdefMessage message = NdefMessage(<NdefRecord>[
          //   NdefRecord.createUri(Uri.parse('www.naver.com')),
          // ]);
          // await ndef.write(message);
          await NfcManager.instance.stopSession();

          setState(() => _alertMessage = "NFC 태그를 인식하였습니다.");
        } catch (e) {
          await NfcManager.instance.stopSession();

          setState(() => _errorMessage = '$e');
        }
      },
    ).catchError((e) => setState(() => _errorMessage = '$e'));
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _errorMessage?.isNotEmpty == true
            ? "오류"
            : _alertMessage?.isNotEmpty == true
                ? "성공"
                : "준비",
      ),
      content: Text(
        _errorMessage?.isNotEmpty == true
            ? _errorMessage!
            : _alertMessage?.isNotEmpty == true
                ? _alertMessage!
                : widget.alertMessage,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
              _errorMessage?.isNotEmpty == true
                  ? "확인"
                  : _alertMessage?.isNotEmpty == true
                      ? "완료"
                      : "취소",
              style: TextStyle(color: Colors.amber)),
          onPressed: () => Navigator.of(context).pop(_result),
        ),
      ],
    );
  }
}

String _handleTag(NfcTag tag) {
  try {
    final List<int> tempIntList;

    if (Platform.isIOS) {
      tempIntList = List<int>.from(tag.data["mifare"]["identifier"]);
    } else {
      tempIntList =
          List<int>.from(Ndef.from(tag)?.additionalData["identifier"]);
    }
    String id = "";

    tempIntList.forEach((element) {
      id = id + element.toRadixString(16);
    });

    return id;
  } catch (e) {
    throw "NFC 데이터를 가져올 수 없습니다.";
  }
}

void makePhoneCall(String phoneNumber) async {
  bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  if (!res!) {
    throw 'Could not make phone call';
  }
}
