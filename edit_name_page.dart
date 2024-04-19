import 'package:elib_project/pages/plus_page.dart';
import 'package:elib_project/pages/name_auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth_dio.dart';

class EditNamePage extends StatefulWidget {
  final String currentname;

  const EditNamePage({
    Key? key,
    required this.currentname,
  }) : super(key: key);

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  bool isButtonEnabled = false;
  bool isAuthButtonClicked = false;

  late FocusNode _textFieldFocusNode;

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
            "이름 변경",
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
                    "새로운 이름을 입력해주세요",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        querywidth * 0.05, 0, querywidth * 0.05, 10),
                    child: TextFormField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                            4) //4자리만 입력받도록 하이픈 2개+숫자 11개
                      ],
                      autovalidateMode: AutovalidateMode.always,
                      onChanged: (value) {
                        setState(() {
                          name = value;
                          isButtonEnabled = value.length > 1;
                          if (name == widget.currentname) {
                            isButtonEnabled = false;
                          }
                        });
                      },
                      onSaved: (value) {
                        name = value as String;
                      },
                      validator: (value) {
                        int length = value!.length;

                        if (length < 2 && length > 0) {
                          return '이름을 2자 이상 입력해주세요';
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '이름',
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
                      if (await editNamesendData(name) == 200) {
                        Navigator.pop(context, true);
                      }
                      // After authNumbersendData is executed, update the button state
                    }
                  : null,
              child: Text('변경 완료'),
            ),
          ),
        ),
      ),
    );
  }
}

editNamesendData(String name) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response =
      await dio.patch('/api/v1/user/name', queryParameters: {'name': name});
  if (response.statusCode == 200) {
    print(response.data);
    return response.statusCode;
  }
}
