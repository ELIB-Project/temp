import "dart:async";
import "dart:convert";
import "dart:math";

import "package:dropdown_button2/dropdown_button2.dart";
import "package:elib_project/models/bottom_app_bar.dart";
import "package:elib_project/pages/home_page.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:elib_project/auth_dio.dart';
import 'package:quiver/async.dart';

final currentYear = DateTime.now().year;

String name = '';
String number = '';
String birth = '';
String authNumber = '';
bool isButtonPressed = false;

double? btnHeight;
double? temp;

class NameAuthPage extends StatefulWidget {
  const NameAuthPage({Key? key}) : super(key: key);

  @override
  _NameAuthPageState createState() => _NameAuthPageState();
}

class _NameAuthPageState extends State<NameAuthPage> {
  final GlobalKey _containerkey = GlobalKey();
  Size? _getSize() {
    if (_containerkey.currentContext != null) {
      final RenderBox renderBox =
          _containerkey.currentContext!.findRenderObject() as RenderBox;
      Size size = renderBox.size;
      return size;
    }
  }

  // person class 생성자 생성
  final TextEditingController nameinputController = TextEditingController();
  final TextEditingController numberinputController = TextEditingController();
  final TextEditingController authinputController = TextEditingController();

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

  void nameChange() {
    name = nameinputController.text;
  }

  void numberChange() {
    number = numberinputController.text;
  }

  void authChange() {
    authNumber = authinputController.text;
  }

  @override
  void initState() {
    super.initState();
    // myController에 리스너 추가
    nameinputController.addListener(nameChange);
    numberinputController.addListener(numberChange);
    authinputController.addListener(authChange);
    _textFieldFocusNode = FocusNode();
  }

  // _MyCustomFormState가 제거될 때 호출
  @override
  void dispose() {
    // 텍스트에디팅컨트롤러를 제거하고, 등록된 리스너도 제거된다.
    nameinputController.dispose();
    numberinputController.dispose();
    authinputController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  // myController의 텍스트를 콘솔에 출력하는 메소드
  @override
  Widget build(BuildContext context) {
    double queryHeight = MediaQuery.of(context).size.height;
    double queryWidth = MediaQuery.of(context).size.width;

    btnHeight = _getSize()?.height;

    if (temp == null) {
      temp = btnHeight;
    }

    double? size() {
      if (temp == null) {
        return btnHeight;
      } else {
        return temp;
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 250, 250, 250),
          colorSchemeSeed: Color.fromARGB(0, 241, 241, 241),
          useMaterial3: true),
      home: Scaffold(
          body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
              child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: queryHeight * 0.05, bottom: queryHeight * 0.01),
                      child: Image.asset('assets/image/eliblogo.png',
                          width: 100, height: 50),
                    ),
                    Container(
                      width: queryWidth * 0.9,
                      height: 2.0,
                      color: Colors.grey, // 원하는 색상으로 변경
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          queryWidth * 0.1, 0, queryWidth * 0.1, 0),
                      child: const Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "실명확인",
                              style: TextStyle(
                                color: Color.fromRGBO(57, 57, 57, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "회원가입을 완료하기 위해 실명 인증을 완료해주세요",
                              style: TextStyle(
                                color: Color.fromRGBO(87, 87, 87, 1),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              queryWidth * 0.1,
                              queryHeight * 0.01,
                              queryWidth * 0.01,
                              queryHeight * 0.01),
                          child: const Text(
                            "성명",
                            style: TextStyle(
                                color: Color.fromRGBO(57, 57, 57, 1),
                                fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                queryWidth * 0.1, 0, queryWidth * 0.1, 0),
                            child: TextFormField(
                              autofocus: true,
                              autovalidateMode: AutovalidateMode.always,
                              onChanged: (value) {
                                name = value;
                              },
                              onSaved: (value) {
                                name = value as String;
                              },
                              validator: (value) {
                                int length = value!.length;

                                if (buttonCount == 1) {
                                  if (length < 1) {
                                    return '필수 입력란입니다.';
                                  }
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(width: 2, color: Colors.black),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(width: 2, color: Colors.red),
                                ),
                                errorStyle: const TextStyle(color: Colors.red),
                                contentPadding: const EdgeInsets.only(
                                    left: 10, bottom: 10, top: 10, right: 10),
                              ),
                              style: const TextStyle(
                                decorationThickness: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              queryWidth * 0.1,
                              queryHeight * 0.02,
                              queryWidth * 0.1,
                              queryHeight * 0.01),
                          child: const Text(
                            "생년월일",
                            style: TextStyle(
                                color: Color.fromRGBO(57, 57, 57, 1),
                                fontSize: 15),
                          ),
                        ),
                        SizedBox(
                            width: queryWidth,
                            height: queryHeight * 0.05,
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                    queryWidth * 0.1, 0, queryWidth * 0.1, 0),
                                //년도 지정
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: queryWidth * 0.22,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton2(
                                          isExpanded: true,
                                          items: itemsYear
                                              .map((item) =>
                                                  DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                              .toList(),
                                          value: selectedValueYear,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedValueYear =
                                                  value as String;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          //iconSize: 14,
                                          iconEnabledColor:
                                              const Color.fromRGBO(
                                                  83, 83, 83, 1),
                                          iconDisabledColor: Colors.grey,

                                          buttonDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                          ),
                                          buttonElevation: 2,
                                          itemHeight: 50,
                                          itemPadding: const EdgeInsets.only(
                                              left: 14, right: 14),
                                          dropdownMaxHeight: 200,
                                          dropdownPadding: null,
                                          dropdownDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            //color: Colors.redAccent,
                                          ),
                                          dropdownElevation: 8,
                                          scrollbarRadius:
                                              const Radius.circular(40),
                                          scrollbarThickness: 6,
                                          scrollbarAlwaysShow: true,
                                          offset: const Offset(0, 0),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: queryWidth * 0.01,
                                          right: queryWidth * 0.02),
                                      child: const Text(
                                        "년",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(57, 57, 57, 1),
                                            fontSize: 15),
                                      ),
                                    ),

                                    // 월 지정
                                    SizedBox(
                                      width: queryWidth * 0.2,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton2(
                                          isExpanded: true,
                                          items: itemsMonth
                                              .map((item) =>
                                                  DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                              .toList(),
                                          value: selectedValueMonth,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedValueMonth =
                                                  value as String;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          //iconSize: 14,
                                          iconEnabledColor:
                                              Color.fromRGBO(83, 83, 83, 1),
                                          iconDisabledColor: Colors.grey,
                                          // buttonWidth: 100,
                                          // buttonPadding: const EdgeInsets.only(
                                          //     left: 12, right: 14),
                                          buttonDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                          ),
                                          buttonElevation: 2,
                                          itemHeight: 50,
                                          itemPadding: const EdgeInsets.only(
                                              left: 14, right: 14),
                                          dropdownMaxHeight: 200,
                                          dropdownPadding: null,
                                          dropdownDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            //color: Colors.redAccent,
                                          ),
                                          dropdownElevation: 8,
                                          scrollbarRadius:
                                              const Radius.circular(40),
                                          scrollbarThickness: 6,
                                          scrollbarAlwaysShow: true,
                                          offset: const Offset(0, 0),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: queryWidth * 0.01,
                                          right: queryWidth * 0.02),
                                      child: const Text(
                                        "월",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(57, 57, 57, 1),
                                            fontSize: 15),
                                      ),
                                    ),

                                    // 일 지정
                                    SizedBox(
                                      width: queryWidth * 0.2,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton2(
                                          isExpanded: true,
                                          items: itemsDay
                                              .map((item) =>
                                                  DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                              .toList(),
                                          value: selectedValueDay,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedValueDay =
                                                  value as String;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          //iconSize: 14,
                                          iconEnabledColor:
                                              Color.fromRGBO(83, 83, 83, 1),
                                          iconDisabledColor: Colors.grey,
                                          buttonWidth: 100,
                                          buttonPadding: const EdgeInsets.only(
                                              left: 12, right: 14),
                                          buttonDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                          ),
                                          buttonElevation: 2,
                                          itemHeight: 50,
                                          itemPadding: const EdgeInsets.only(
                                              left: 14, right: 14),
                                          dropdownMaxHeight: 200,
                                          dropdownPadding: null,
                                          dropdownDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            //color: Colors.redAccent,
                                          ),
                                          dropdownElevation: 8,
                                          scrollbarRadius:
                                              const Radius.circular(40),
                                          scrollbarThickness: 6,
                                          scrollbarAlwaysShow: true,
                                          offset: const Offset(0, 0),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: queryWidth * 0.01),
                                      child: const Text(
                                        "일",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(57, 57, 57, 1),
                                            fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              queryWidth * 0.1,
                              queryHeight * 0.02,
                              queryWidth * 0.1,
                              queryHeight * 0.01),
                          child: const Text(
                            "핸드폰",
                            style: TextStyle(
                                color: Color.fromRGBO(57, 57, 57, 1),
                                fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                queryWidth * 0.1, 0, queryWidth * 0.1, 0),
                            child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly, //숫자만!
                                NumberFormatter(), // 자동하이픈
                                LengthLimitingTextInputFormatter(
                                    13) //13자리만 입력받도록 하이픈 2개+숫자 11개
                              ],
                              autovalidateMode: AutovalidateMode.always,
                              onChanged: (value) {
                                number = value;
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
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(queryWidth * 0.1,
                              queryHeight * 0.03, queryWidth * 0.1, 0),
                          child: SizedBox(
                            //height: queryHeight * 0.04,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
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
                                      if (authcheck == true) {
                                        return '인증되었습니다.';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        hintText: "인증번호",
                                        isDense: true,
                                        border: InputBorder.none,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                              width: 2, color: Colors.black),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                              width: 2, color: Colors.black),
                                        ),
                                        errorStyle:
                                            TextStyle(color: Colors.green),
                                        contentPadding: EdgeInsets.only(
                                            left: 10,
                                            bottom: 0,
                                            top: 15,
                                            right: 5),
                                        suffix: Visibility(
                                          visible: isButtonPressed,
                                          child: Text(
                                            formatTimer(_current),
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        )),
                                    keyboardType:
                                        TextInputType.phone, // 번호 자판 지정
                                    style: TextStyle(
                                      decorationThickness: 0,
                                    ),
                                  ),
                                  // child: TextFormField(
                                  //   autovalidateMode: AutovalidateMode.always,
                                  //   controller: authinputController,
                                  //   decoration: const InputDecoration(
                                  //     hintText: '인증번호',
                                  //     hintStyle: TextStyle(
                                  //       color: Colors.grey,
                                  //     ),
                                  //     enabledBorder: OutlineInputBorder(
                                  //       borderRadius: BorderRadius.all(
                                  //           Radius.circular(10.0)),
                                  //       borderSide: BorderSide(
                                  //           width: 1, color: Colors.grey),
                                  //     ),
                                  //     focusedBorder: OutlineInputBorder(
                                  //       borderRadius: BorderRadius.all(
                                  //           Radius.circular(10.0)),
                                  //       borderSide: BorderSide(
                                  //           width: 1, color: Colors.grey),
                                  //     ),
                                  //     contentPadding: EdgeInsets.symmetric(
                                  //         vertical: 1.0, horizontal: 10.0),
                                  //     // 디자인 관련
                                  //     border: OutlineInputBorder(), //테두리
                                  //     // suffix:
                                  //   ), //변수 값 넣기
                                  // ),
                                ),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        queryWidth * 0.03,
                                        0,
                                        queryWidth * 0.03,
                                        0)),
                                SizedBox(
                                  height: size(),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        isButtonPressed
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      textStyle:
                                          MaterialStateProperty.all<TextStyle>(
                                        TextStyle(color: Colors.white),
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      // 여기서 추가적인 작업 수행 가능
                                      if (isButtonPressed != true) {
                                        print(number);
                                        if (number.length == 13) {
                                          setState(() {
                                            isButtonPressed = true;
                                          });
                                          startTimer();
                                          focusTextField();
                                          authNumbersendData(number);
                                        } else {
                                          printmessage(context, 4);
                                        }
                                      } else {
                                        authcheck = await configAuthsendData(
                                            authNumber);
                                        if (authcheck == false) {
                                          printmessage(context, 2);
                                        } else {
                                          setState(() {
                                            isButtonPressed = false;
                                          });
                                        }
                                      }
                                    },
                                    child: Text(
                                      isButtonPressed ? "인증확인" : "인증요청",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              queryWidth * 0.1, 0, queryWidth * 0.1, 0),
                          child: SizedBox(
                              height: queryHeight * 0.1,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "개인정보 수집, 이용방침",
                                    style: TextStyle(
                                      color: Color.fromRGBO(113, 113, 113, 1),
                                    ),
                                  ),
                                  // Padding(
                                  //     padding: EdgeInsets.fromLTRB(
                                  //         queryWidth * 0.03,
                                  //         0,
                                  //         queryWidth * 0.1,
                                  //         0)),
                                  TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "확인하기",
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(30, 83, 219, 1)),
                                      ))
                                ],
                              )),
                        ),
                        Center(
                          child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        const Color.fromRGBO(
                                            56, 174, 93, 1)), // 버튼의 배경색
                                textStyle: MaterialStateProperty.all<TextStyle>(
                                    const TextStyle(
                                        color: Colors.white)), // 버튼 안의 텍스트 스타일
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // 버튼의 모서리를 둥글게 설정
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                int result;
                                buttonCount = 1;
                                setState(() {});
                                if (authcheck == false && name != null) {
                                  printmessage(context, 3);
                                } else {
                                  String? _month;
                                  String? _day;
                                  if (selectedValueMonth?.length == 1) {
                                    _month = "0$selectedValueMonth";
                                  } else {
                                    _month = selectedValueMonth;
                                  }
                                  if (selectedValueDay?.length == 1) {
                                    _day = "0$selectedValueDay";
                                  } else {
                                    _day = selectedValueDay;
                                  }

                                  birth = ('$selectedValueYear-$_month-$_day');

                                  result = await nameAuthsendData(
                                      name, number, birth);
                                  print(result);
                                  try {
                                    if (result == 200) {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  BulidBottomAppBar(
                                                    index: 2,
                                                  )),
                                          (route) => false);
                                    }
                                  } catch (error) {
                                    Error();
                                  }
                                }
                              },
                              child: const Text(
                                "회원가입",
                                style: TextStyle(color: Colors.white),
                              )),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          )),
        ),
      )),
    );
  }

  Future<dynamic> printmessage(BuildContext context, int check) {
    String message = '';
    if (check == 1) {
      message = '인증되었습니다';
    } else if (check == 2) {
      message = '인증번호를 다시 확인해주세요';
    } else if (check == 3) {
      message = '인증을 완료해 주세요';
    } else if (check == 4) {
      message = '휴대폰 번호를 확인해주세요';
    }
    return showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
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
}

String? selectedValueYear;
final List<String> itemsYear = List.generate(
  currentYear - (currentYear - 100),
  (index) => (currentYear - index).toString(),
);

String? selectedValueMonth;
final List<String> itemsMonth =
    List.generate(12, (index) => (index + 1).toString());

String? selectedValueDay;
final List<String> itemsDay =
    List.generate(31, (index) => (index + 1).toString());

Future<int> nameAuthsendData(String name, String f_number, String birth) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.post('/api/v1/user/detail',
      data: jsonEncode({'name': name, 'phone': f_number, 'birth': birth}));
  if (response.statusCode == 200) {
    return 200;
  } else {
    return 0;
  }
  // final headers = {'Authorization': token};
  // return response.body;
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

class Utf8LengthLimitingTextInputFormatter extends TextInputFormatter {
  Utf8LengthLimitingTextInputFormatter(this.maxLength)
      : assert(maxLength == null || maxLength == -1 || maxLength > 0);

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (maxLength != null &&
        maxLength > 0 &&
        bytesLength(newValue.text) > maxLength) {
      // If already at the maximum and tried to enter even more, keep the old value.
      if (bytesLength(oldValue.text) == maxLength) {
        return oldValue;
      }
      return truncate(newValue, maxLength);
    }
    return newValue;
  }

  static TextEditingValue truncate(TextEditingValue value, int maxLength) {
    var newValue = '';
    if (bytesLength(value.text) > maxLength) {
      var length = 0;

      value.text.characters.takeWhile((char) {
        var nbBytes = bytesLength(char);
        if (length + nbBytes <= maxLength) {
          newValue += char;
          length += nbBytes;
          return true;
        }
        return false;
      });
    }
    return TextEditingValue(
      text: newValue,
      selection: value.selection.copyWith(
        baseOffset: min(value.selection.start, newValue.length),
        extentOffset: min(value.selection.end, newValue.length),
      ),
      composing: TextRange.empty,
    );
  }

  static int bytesLength(String value) {
    return utf8.encode(value).length;
  }
}

class NumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex <= 3) {
        if (nonZeroIndex % 3 == 0 && nonZeroIndex != text.length) {
          buffer.write('-'); // Add double spaces.
        }
      } else {
        if (nonZeroIndex % 7 == 0 &&
            nonZeroIndex != text.length &&
            nonZeroIndex > 4) {
          buffer.write('-');
        }
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

String formatTimer(int seconds) {
  int minutes = seconds ~/ 60;
  int remainingSeconds = seconds % 60;

  String minutesStr = minutes.toString().padLeft(2, '0');
  String secondsStr = remainingSeconds.toString().padLeft(2, '0');

  return '$minutesStr:$secondsStr';
}

void _navigateToHomePage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage(),
    ),
  );
}
