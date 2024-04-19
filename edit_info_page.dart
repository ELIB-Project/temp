import 'dart:io';

import 'package:dio/dio.dart';
import 'package:elib_project/pages/alarm_page.dart';
import 'package:elib_project/pages/edit_name_page.dart';
import 'package:elib_project/pages/edit_phone_page.dart';
import 'package:elib_project/pages/plus_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../auth_dio.dart'; // intl 패키지 추가

final _formKey = GlobalKey<FormState>();
String updateName = '';

class GlobalData {
  static double queryWidth = 0.0;
  static double queryHeight = 0.0;
}

class EditInfoPage extends StatefulWidget {
  const EditInfoPage({super.key});
  @override
  _EditInfoPageState createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  int count = 0;
  late String _textFormFieldValue;
  late DateTime date;
  late Future<userInfo> userinfo;

  @override
  void initState() {
    super.initState();
    date = DateTime.now();
    userinfo = loadUserInfo();
  }

  void updateDate(DateTime selectedDate) {
    setState(() {
      date = selectedDate;
      count = 1;
      print(date);
    });
  }

  XFile? _pickedFile;

  @override
  Widget build(BuildContext context) {
    final double Query_fontSize = MediaQuery.of(context).size.width * 0.05;
    final double lineLength = MediaQuery.of(context).size.width * 0.7;
    GlobalData.queryHeight = MediaQuery.of(context).size.height;
    GlobalData.queryWidth = MediaQuery.of(context).size.width;
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
                Navigator.pop(context); // 뒤로가기 버튼 클릭 이벤트 처리
              },
            ),
            title: const Text(
              "회원 정보 수정",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
              child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: FutureBuilder<userInfo>(
              future: userinfo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // 데이터를 아직 받아오는 중이면 로딩 표시를 보여줌
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // 데이터를 받아오는 도중 에러가 발생하면 에러 메시지를 보여줌
                  return Text('Error: ${snapshot.error}');
                } else {
                  userInfo entries = snapshot.data!;
                  if (count == 0) {
                    date = DateTime.parse(entries.birth);
                    count == 1;
                  }
                  return SingleChildScrollView(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (entries.imgUrl == null)
                                Center(
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      _showBottomSheet();
                                    },
                                    child: _pickedFile == null
                                        ? Container(
                                            width: 100,
                                            height: 100,
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
                                              // child: Image.network(entries.imgUrl,
                                              //     width: 100,
                                              //     height: 100,
                                              //     fit: BoxFit.fill),
                                            ),
                                          )
                                        : Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  width: 2,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                              image: DecorationImage(
                                                  image: FileImage(
                                                      File(_pickedFile!.path)),
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                  ),
                                )
                              else
                                Center(
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      await _showBottomSheet();
                                    },
                                    child: _pickedFile == null
                                        ? Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  width: 2, color: Colors.grey),
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      entries.imgUrl!),
                                                  fit: BoxFit.cover),
                                            ),
                                          )
                                        : Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  width: 2, color: Colors.grey),
                                              image: DecorationImage(
                                                  image: FileImage(
                                                      File(_pickedFile!.path)),
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    GlobalData.queryWidth * 0.05,
                                    GlobalData.queryHeight * 0.01,
                                    GlobalData.queryWidth * 0.05,
                                    GlobalData.queryHeight * 0.01),
                                child: Text(
                                  "이름",
                                  style: TextStyle(
                                      color: Color.fromRGBO(171, 171, 171, 1.0),
                                      fontSize: (Query_fontSize - 5)),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    GlobalData.queryWidth * 0.05,
                                    GlobalData.queryHeight * 0.01,
                                    GlobalData.queryWidth * 0.05,
                                    GlobalData.queryHeight * 0.01),
                                child: InkWell(
                                  onTap: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => EditNamePage(
                                                  currentname: entries.name,
                                                ))).then((value) {
                                      setState(() {
                                        userinfo = loadUserInfo();
                                      });
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entries.name,
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                              171, 171, 171, 1.0),
                                          fontSize: Query_fontSize,
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    GlobalData.queryWidth * 0.05,
                                    GlobalData.queryHeight * 0.01,
                                    GlobalData.queryWidth * 0.05,
                                    GlobalData.queryHeight * 0.01),
                                child: Text(
                                  "휴대전화",
                                  style: TextStyle(
                                    color: Color.fromRGBO(171, 171, 171, 1.0),
                                    fontSize: (Query_fontSize - 5),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditPhonePage(),
                                    ),
                                  );
                                  if (result) {
                                    print("성공");
                                    setState(() {
                                      userinfo = loadUserInfo();
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      GlobalData.queryWidth * 0.05,
                                      GlobalData.queryHeight * 0.01,
                                      GlobalData.queryWidth * 0.05,
                                      GlobalData.queryHeight * 0.01),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${entries.phone.substring(0, 3)}-${entries.phone.substring(3, 7)}-${entries.phone.substring(7, 11)}",
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                              171, 171, 171, 1.0),
                                          fontSize: Query_fontSize,
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    GlobalData.queryWidth * 0.05,
                                    GlobalData.queryHeight * 0.01,
                                    GlobalData.queryWidth * 0.05,
                                    GlobalData.queryHeight * 0.01),
                                child: Text(
                                  "생년월일",
                                  style: TextStyle(
                                      color: Color.fromRGBO(171, 171, 171, 1.0),
                                      fontSize: (Query_fontSize - 5)),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    GlobalData.queryWidth * 0.05,
                                    0,
                                    GlobalData.queryWidth * 0.05,
                                    0),
                                child: InkWell(
                                  onTap: () async {
                                    final selectedDate = await showDatePicker(
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors
                                                  .yellow, // header background color
                                              onPrimary: Colors
                                                  .black, // header text color
                                              onSurface: Colors
                                                  .green, // body text color
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                primary: Colors
                                                    .red, // button text color
                                              ),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                      context:
                                          context, // 팝업으로 띄우기 때문에 context 전달
                                      initialDate:
                                          date, // 달력을 띄웠을 때 선택된 날짜. 위에서 date 변수에 오늘 날짜를 넣었으므로 오늘 날짜가 선택돼서 나옴
                                      firstDate: DateTime(1950), // 시작 년도
                                      lastDate: DateTime
                                          .now(), // 마지막 년도. 오늘로 지정하면 미래의 날짜는 선택할 수 없음
                                    );
                                    if (selectedDate != null) {
                                      updateDate(selectedDate);
                                      editBirthsendData(DateFormat('yyyy-MM-dd')
                                          .format(selectedDate));
                                    }
                                  },
                                  child: Text(
                                    DateFormat('yyyy-MM-dd')
                                        .format(date), // 날짜를 지정된 형식으로 포맷팅
                                    style: TextStyle(
                                        color:
                                            Color.fromRGBO(171, 171, 171, 1.0),
                                        fontSize: (Query_fontSize)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    GlobalData.queryWidth * 0.05,
                                    0,
                                    GlobalData.queryWidth * 0.05,
                                    GlobalData.queryHeight * 0.2),
                                child: Container(
                                  width: GlobalData.queryWidth,
                                  height: 2.0,
                                  color: Colors.black, // 원하는 색상으로 변경
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
              },
            ),
          )),
        ));
  }

  _showBottomSheet() async {
    // String? url = await receiveKakaoScheme();
    // ignore: use_build_context_synchronously
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                final result = await _getCameraImage();
                if (result) {
                  Navigator.pop(context);
                  dynamic sendData = _pickedFile!.path;
                  await imgSendData(sendData);
                  // setState(() {
                  //   userinfo = loadUserInfo();
                  // });

                  print("전송완료");
                }
              },
              child: const SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Icon(
                        Icons.photo_camera,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '카메라',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 3,
            ),
            InkWell(
              onTap: () async {
                final result = await _getPhotoLibraryImage();
                if (result) {
                  dynamic sendData = _pickedFile!.path;
                  Navigator.pop(context);
                  await imgSendData(sendData);
                  print("전송완료");
                }
              },
              child: Container(
                height: 50,
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Icon(
                        Icons.photo,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '갤러리',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _getCameraImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
    }
  }

  _getPhotoLibraryImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
      return true;
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
      return false;
    }
  }
}

Future<userInfo> loadUserInfo() async {
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

void _navigateToEditPhonePage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditPhonePage(),
    ),
  );
}

void _navigateToEditNamePage(BuildContext context, String name) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditNamePage(
        currentname: name,
      ),
    ),
  );
}

editBirthsendData(String birth) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response =
      await dio.patch('/api/v1/user/birth', queryParameters: {'birth': birth});
  if (response.statusCode == 200) {
    print(response.data);
    return response.statusCode;
  }
}

Future<void> imgSendData(sendData) async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  var formData =
      FormData.fromMap({'file': await MultipartFile.fromFile(sendData)});
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.post('/api/v1/user/profile/img', data: formData);
  if (response.statusCode == 200) {
    print("응답 성공");
    print(response.data);
  } else {
    throw Exception('fail');
  }
}
