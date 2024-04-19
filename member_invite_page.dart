import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:elib_project/pages/edit_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth_dio.dart';
import '../models/bottom_app_bar.dart';
import 'name_auth_page.dart';

class GlobalData {
  static double queryWidth = 0.0;
  static double queryHeight = 0.0;
}

class MemberInvitePage extends StatefulWidget {
  const MemberInvitePage({super.key});

  @override
  State<MemberInvitePage> createState() => _MemberInvitePageState();
}

class _MemberInvitePageState extends State<MemberInvitePage> {
  // final TextEditingController numberinputController = TextEditingController();
  String number = '';
  bool isButtonEnabled = false;

  // void numberChange() {
  //   number = numberinputController.text;
  // }

  @override
  void initState() {
    super.initState();
    // myController에 리스너 추가

    // numberinputController.addListener(numberChange);
  }

  // _MyCustomFormState가 제거될 때 호출
  @override
  void dispose() {
    // 텍스트에디팅컨트롤러를 제거하고, 등록된 리스너도 제거된다.

    // numberinputController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GlobalData.queryHeight = MediaQuery.of(context).size.height;
    GlobalData.queryWidth = MediaQuery.of(context).size.width;
    final double Query_fontSize =
        MediaQuery.of(context).size.width * 0.05; // 디바이스 너비에 따라 폰트 크기 계산
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 250, 250, 250),
          colorSchemeSeed: Color.fromARGB(0, 241, 241, 241),
          useMaterial3: true),
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 250, 250, 250),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context); // 뒤로가기 버튼 클릭 이벤트 처리
            },
          ),
          title: const Text(
            "구성원 초대",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          // 나머지 AppBar 설정
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              width: GlobalData.queryWidth,
              height: GlobalData.queryHeight,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image/eliblogo.png'),
                  colorFilter: ColorFilter.matrix([
                    // 희미한 효과를 주는 컬러 매트릭스
                    0.1, 0, 0, 0, 0,
                    0, 0.9, 0, 0, 0,
                    0, 0, 0.1, 0, 0,
                    0, 0, 0, 0.1, 0,
                  ]),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                GlobalData.queryWidth * 0.1,
                                GlobalData.queryHeight * 0.05,
                                GlobalData.queryWidth * 0.01,
                                GlobalData.queryHeight * 0.01),
                            child: const Text(
                              "전화번호",
                              style: TextStyle(
                                  color: Color.fromRGBO(57, 57, 57, 1),
                                  fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                GlobalData.queryWidth * 0.1,
                                0,
                                GlobalData.queryWidth * 0.1,
                                0),
                            child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly, //숫자만!
                                NumberFormatter(), // 자동하이픈
                                LengthLimitingTextInputFormatter(
                                    13) //13자리만 입력받도록 하이픈 2개+숫자 11개
                              ],
                              autovalidateMode: AutovalidateMode.always,
                              onChanged: (value) {
                                setState(() {
                                  number = value;
                                  isButtonEnabled = value.length == 13;
                                });
                              },
                              onSaved: (value) {
                                number = value as String;
                              },
                              validator: (value) {
                                int length = value!.length;

                                if (length < 13 && length > 0) {
                                  return '휴대폰번호를 다시 확인해주세요';
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: '휴대전화번호',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(width: 2, color: Colors.black),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(width: 2, color: Colors.red),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(width: 2, color: Colors.red),
                                ),
                                errorStyle: TextStyle(color: Colors.red),
                                contentPadding: EdgeInsets.only(
                                    left: 10, bottom: 10, top: 10, right: 5),
                              ),
                              keyboardType: TextInputType.phone, // 번호 자판 지정
                              style: TextStyle(
                                decorationThickness: 0,
                              ),
                            ),
                          ),
                          //분류 지정
                          // Padding(
                          //   padding: EdgeInsets.fromLTRB(
                          //       GlobalData.queryWidth * 0.1,
                          //       GlobalData.queryHeight * 0.05,
                          //       GlobalData.queryWidth * 0.01,
                          //       GlobalData.queryHeight * 0.01),
                          //   child: const Text(
                          //     "분류",
                          //     style: TextStyle(
                          //         color: Color.fromRGBO(57, 57, 57, 1),
                          //         fontSize: 15),
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: GlobalData.queryHeight * 0.05,
                          //   child: Padding(
                          //       padding: EdgeInsets.fromLTRB(
                          //           GlobalData.queryWidth * 0.1,
                          //           0,
                          //           GlobalData.queryWidth * 0.1,
                          //           0),
                          //       child: RelationshipBulilder()),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomSheet: SafeArea(
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: isButtonEnabled
                  ? () async {
                      dynamic result = await memberInvite(number);
                      print("ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ");
                      print(result);
                      if (result == 200) {
                        await printmessage(context, 1);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    BulidBottomAppBar(
                                      index: 3,
                                    )),
                            (route) => false);
                      } else if (result == 400) {
                        await printmessage(context, 3);
                      } else if (result == 409) {
                        await printmessage(context, 2);
                      }
                    }
                  : null,
              child: Text('초대하기'),
            ),
          ),
        ),
      ),
    );
  }
}

Future<dynamic> memberInvite(String inviteNumber) async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  try {
    final response = await dio.post('/api/v1/family',
        data: jsonEncode({'phone': inviteNumber}));
    if (response.statusCode == 200) {
      print("요청 성공");
      return response.statusCode;
    }
  } catch (e) {
    if (e is DioError) {
      if (e.response != null) {
        // 응답이 있는 경우
        if (e.response!.statusCode == 400) {
          print("400 에러: 잘못된 요청");
          // 400에러에 대한 예외 처리
          return 400;
        } else if (e.response!.statusCode == 409) {
          // 다른 상태 코드에 대한 처리
          print("다른 상태 코드: ${e.response!.statusCode}");
          // 예외를 던지거나 다른 처리를 수행할 수 있음
          return 409;
        }
      } else {
        // 응답이 없는 경우 (네트워크 에러 등)
        print("에러 발생: ${e.toString()}");
        // 예외를 던지거나 다른 처리를 수행할 수 있음
      }
    } else {
      // 다른 예외 처리
      print("다른 예외 발생: $e");
      // 예외를 던지거나 다른 처리를 수행할 수 있음
    }

    print(e);
  }
  return;
}

class RelationshipBulilder extends StatefulWidget {
  const RelationshipBulilder({
    super.key,
  });

  @override
  _RelationshipState createState() => _RelationshipState();
}

class _RelationshipState extends State<RelationshipBulilder> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: GlobalData.queryWidth * 0.9,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          isExpanded: true,
          items: itemsRelationship
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          value: selectedValueRelationship,
          onChanged: (value) {
            setState(() {
              selectedValueRelationship = value as String;
            });
          },
          icon: const Icon(
            Icons.arrow_drop_down,
          ),
          //iconSize: 14,
          iconEnabledColor: Color.fromRGBO(83, 83, 83, 1),
          iconDisabledColor: Colors.grey,
          // buttonWidth: 100,
          // buttonPadding: const EdgeInsets.only(
          //     left: 12, right: 14),
          buttonDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey,
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          buttonElevation: 2,
          itemHeight: 50,
          itemPadding: const EdgeInsets.only(left: 14, right: 14),
          dropdownMaxHeight: 200,
          dropdownPadding: null,
          dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            //color: Colors.redAccent,
          ),
          dropdownElevation: 8,
          scrollbarRadius: const Radius.circular(40),
          scrollbarThickness: 6,
          scrollbarAlwaysShow: true,
          offset: const Offset(0, 0),
        ),
      ),
    );
  }
}

String? selectedValueRelationship;
List<String> itemsRelationship = ['부모', '자녀', '친구', '기타'];

Future<dynamic> printmessage(BuildContext context, int check) {
  String message = '';
  if (check == 1) {
    message = '구성원 요청을 보냈습니다';
  } else if (check == 2) {
    message = '이미 가족 구성원입니다';
  } else if (check == 3) {
    message = '가입된 번호가 없습니다\n 다시 입력해 주세요';
  }
  return showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor:
                Colors.white, // Override dialog background color
          ),
          child: AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  message,
                ),
              ],
            ),
            contentPadding: EdgeInsets.fromLTRB(0, 10.0, 0, 0), //왼 위 오 아
            actions: <Widget>[
              TextButton(
                child: Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
            actionsPadding: EdgeInsets.only(bottom: 10.0),
          ),
        );
      });
}
