import 'package:elib_project/models/bottom_app_bar.dart';
import 'package:elib_project/pages/name_auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth_dio.dart';

class EnterCodePage extends StatefulWidget {
  const EnterCodePage({super.key});
  @override
  State<EnterCodePage> createState() => _EnterCodePageState();
}

class _EnterCodePageState extends State<EnterCodePage> {
  final GlobalKey _containerkey = GlobalKey();
  bool isButtonEnabled = false;
  bool isButtonPressed = false;
  String code = "";
  String? entercode; // Declare as nullable String
  @override
  void initState() {
    super.initState();

    // myController에 리스너 추가
  }

  // _MyCustomFormState가 제거될 때 호출
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    entercode = ModalRoute.of(context)?.settings.arguments as String?;
    if (entercode != null) {
      setState(() {
        isButtonEnabled = true;
      });
    }
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
            "초대코드 입력",
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
                    "초대코드 5자리를 입력해주세요",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        querywidth * 0.05, 0, querywidth * 0.05, 10),
                    child: TextFormField(
                      initialValue: entercode != null ? entercode : null,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(5) //5자리만 입력받도록
                      ],
                      autovalidateMode: AutovalidateMode.always,
                      onChanged: (value) {
                        setState(() {
                          code = value;
                          isButtonEnabled = value.length == 5;
                        });
                      },
                      onSaved: (value) {
                        code = value as String;
                      },
                      validator: (value) {
                        if (isButtonPressed) {
                          return '잘못된 코드이거나 만료된 코드입니다.';
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'ex) 12345',
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
                      style: TextStyle(
                        decorationThickness: 0,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),
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
                      if (await enterCodesendData(code)) {
                        // ignore: use_build_context_synchronously
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    BulidBottomAppBar(
                                      index: 3,
                                    )),
                            (route) => false);
                      } else {
                        setState(() {
                          isButtonPressed = true;
                        });
                      }
                      // After authNumbersendData is executed, update the button state
                    }
                  : null,
              child: Text('구성원 등록하기'),
            ),
          ),
        ),
      ),
    );
  }
}

enterCodesendData(String code) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response =
      await dio.post('/api/v1/family/code', queryParameters: {'code': code});
  if (response.statusCode == 200) {
    print(response.data);
    return response.data;
  }
}
