import 'package:elib_project/pages/edit_info_page.dart';
import 'package:elib_project/pages/name_auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quiver/async.dart';
import '../auth_dio.dart';

class EditPhonePage extends StatefulWidget {
  const EditPhonePage({super.key});

  @override
  State<EditPhonePage> createState() => _EditPhonePageState();
}

class _EditPhonePageState extends State<EditPhonePage> {
  final GlobalKey _containerkey = GlobalKey();
  bool isButtonEnabled = false;
  bool isAuthButtonClicked = false;
  String authNumber = '';
  bool authcheck = false;
  int buttonCount = 0;
  int _start = 300;
  int _current = 300;
  late FocusNode _textFieldFocusNode;

  void focusTextField() {
    _textFieldFocusNode.requestFocus();
  }

  void startTimer() {
    CountdownTimer countDownTimer = CountdownTimer(
      Duration(seconds: _start),
      Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = _start - duration.elapsed.inSeconds;
      });
    });

    sub.onDone(() {
      print("Done");
      sub.cancel();
    });
  }

  @override
  void initState() {
    super.initState();
    // myController에 리스너 추가

    _textFieldFocusNode = FocusNode();
  }

  // _MyCustomFormState가 제거될 때 호출
  @override
  void dispose() {
    // 텍스트에디팅컨트롤러를 제거하고, 등록된 리스너도 제거된다.
    _textFieldFocusNode.dispose();
    super.dispose();
  }

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
        resizeToAvoidBottomInset: true,
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
            "전화번호 수정",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
            child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(querywidth * 0.05, 0,
                      querywidth * 0.05, queryheight * 0.01),
                  child: Text(
                    "새로운 휴대폰 번호를 입력해주세요",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        querywidth * 0.05, 0, querywidth * 0.05, 10),
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
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(width: 2, color: Colors.black),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 2, color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(width: 2, color: Colors.red),
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
                ),
                Visibility(
                  visible: isAuthButtonClicked,
                  child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            querywidth * 0.05, 0, querywidth * 0.05, 0),
                        child: TextFormField(
                          focusNode: _textFieldFocusNode,
                          key: _containerkey,
                          autovalidateMode: AutovalidateMode.always,
                          onChanged: (value) {
                            authNumber = value;
                          },
                          onSaved: (value) {
                            authNumber = value as String;
                          },
                          validator: (value) {
                            if (authNumber == true) {
                              return '인증되었습니다.';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "인증번호",
                              isDense: true,
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
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide:
                                    BorderSide(width: 2, color: Colors.black),
                              ),
                              errorStyle: TextStyle(color: Colors.green),
                              contentPadding: EdgeInsets.only(
                                  left: 10, bottom: 0, top: 15, right: 5),
                              suffix: Visibility(
                                visible: isAuthButtonClicked,
                                child: Text(
                                  formatTimer(_current),
                                  style: TextStyle(color: Colors.red),
                                ),
                              )),
                          keyboardType: TextInputType.phone, // 번호 자판 지정
                          style: TextStyle(
                            decorationThickness: 0,
                          ),
                        ),
                      )),
                )
              ],
            ),
          ),
        )),
        bottomSheet: SafeArea(
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: isAuthButtonClicked // Check if the auth button is clicked
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          Colors.blue, // Change the color when clicked
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      authcheck = await configAuthsendData(authNumber);
                      if (authcheck == true) {
                        Navigator.pop(context, true);
                      } else {
                        printmessage(context);
                      }
                    },
                    child: Text('인증번호 확인'), // Change the text when clicked
                  )
                : ElevatedButton(
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
                            await authNumbersendData(number);
                            // After authNumbersendData is executed, update the button state
                            setState(() {
                              isAuthButtonClicked = true;
                            });
                            focusTextField();
                            startTimer();
                          }
                        : null,
                    child: Text('인증번호 전송'),
                  ),
          ),
        ),
      ),
    );
  }
}

Future<void> authNumbersendData(String f_number) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response =
      await dio.post('/api/v1/user/sms', queryParameters: {'number': f_number});
  if (response.statusCode == 200) {
    print(response.data);
  }
}

Future<bool> configAuthsendData(String authNumber) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response =
      await dio.get('/api/v1/user/sms', queryParameters: {'code': authNumber});
  if (response.statusCode == 200) {
    print(response.data);
  }
  return response.data;
}

Future<dynamic> printmessage(BuildContext context) {
  String message = '인증번호를 다시 확인해주세요';
  return showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                message,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}
