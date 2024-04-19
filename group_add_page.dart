import 'dart:convert';
import 'package:elib_project/pages/select_member_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth_dio.dart';
import '../models/bottom_app_bar.dart';

late List<familyName> selectedIds;
late List<int> sendid;

class GroupAddPage extends StatefulWidget {
  const GroupAddPage({
    Key? key,
  }) : super(key: key);

  @override
  State<GroupAddPage> createState() => GroupAddPageState();
}

class GroupAddPageState extends State<GroupAddPage> {
  bool isButtonEnabled = false;
  bool isAuthButtonClicked = false;
  String categoryname = "";
  late FocusNode _textFieldFocusNode;

  @override
  void initState() {
    super.initState();
    // myController에 리스너 추가
    sendid = [];
    selectedIds = [];
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
          surfaceTintColor: Colors.transparent,
          backgroundColor: const Color.fromARGB(255, 250, 250, 250),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context, true); // 뒤로가기 버튼 클릭 이벤트 처리
            },
          ),
          title: const Text(
            "그룹 추가",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  querywidth * 0.05, 0, querywidth * 0.05, queryheight * 0.01),
              child: Text(
                "그룹 이름을 입력해 주세요",
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
                      categoryname = value;
                      isButtonEnabled = value.length > 1;
                    });
                  },
                  onSaved: (value) {
                    categoryname = value as String;
                  },
                  validator: (value) {
                    int length = value!.length;

                    if (length < 2 && length > 0) {
                      return '이름을 2자 이상 입력해주세요';
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '그룹 이름',
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
            Padding(
              padding: EdgeInsets.fromLTRB(
                  querywidth * 0.05, 10, querywidth * 0.05, queryheight * 0.01),
              child: Text(
                "그룹 구성원을 추가해주세요",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            InkWell(
              onTap: () async {
                selectedIds = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectMember(),
                  ),
                );
                setState(() {
                  selectedIds;
                  for (var item in selectedIds) {
                    int id = item.id;
                    sendid.add(id);
                  }
                  print(sendid);
                });
              },
              child: SizedBox(
                  width: querywidth,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(querywidth * 0.05, 10, 10, 10),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Container(
                              decoration: const ShapeDecoration(
                                color: Colors.black12,
                                shape: CircleBorder(),
                              ),
                              child: Icon(Icons.add)),
                        ),
                        const Text(
                          "그룹원 추가",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )),
            ),
            Expanded(
              child: ListBuild(
                receivedIds: selectedIds,
              ),
            )
          ],
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
              onPressed: isButtonEnabled && selectedIds.length > 0
                  ? () async {
                      if (await addGroupsendData(categoryname) == 200) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    BulidBottomAppBar(
                                      index: 3,
                                    )),
                            (route) => false);
                      }
                      // After authNumbersendData is executed, update the button state
                    }
                  : null,
              child: Text('추가완료'),
            ),
          ),
        ),
      ),
    );
  }
}

void _navigateToAddGroupPage(BuildContext context) {
  // TODO: 더보기 페이지로 화면 전환
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SelectMember(),
    ),
  );
}

class ListBuild extends StatelessWidget {
  final List<familyName> receivedIds;

  const ListBuild({required this.receivedIds});

  @override
  Widget build(BuildContext context) {
    if (receivedIds.isEmpty) {
      return Center(
        child: Text('선택된 그룹원이 없습니다.'),
      );
    } else {
      return ListView.builder(
        itemCount: receivedIds.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                  child: receivedIds[index].imgUrl == null
                      ? Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ))
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: Colors.grey),
                            image: DecorationImage(
                                image: NetworkImage(receivedIds[index].imgUrl!),
                                fit: BoxFit.cover),
                          ),
                        ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    receivedIds[index].nickname == null
                        ? Text(
                            '${receivedIds[index].name}님 ',
                            style: const TextStyle(
                                color: Color.fromRGBO(131, 131, 131, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )
                        : Text(
                            '${receivedIds[index].nickname}님 ',
                            style: const TextStyle(
                                color: Color.fromRGBO(131, 131, 131, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                  ],
                ),
                const Spacer(), // Adds flexible space
              ],
            ),

            // Add other widget properties and styling as needed
          );
        },
      );
    }
  }
}

addGroupsendData(String category) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.patch('/api/v1/family/category',
      data: jsonEncode(sendid), queryParameters: {'category': category});
  if (response.statusCode == 200) {
    print(response.data);
    return response.statusCode;
  }
}
