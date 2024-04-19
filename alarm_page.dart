import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth_dio.dart';

import 'member_info_page.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class GlobalData {
  static double queryWidth = 0.0;
  static double queryHeight = 0.0;
}

class _AlarmPageState extends State<AlarmPage> {
  @override
  Widget build(BuildContext context) {
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
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                Navigator.pop(context); // 뒤로가기 버튼 클릭 이벤트 처리
              },
            ),
            title: const Text(
              "알림",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(children: [
              Expanded(child: AlarmListBuild(context) //긴급 1번 일반 0번
                  )
            ]),
          ),
        ));
  }

  Widget AlarmListBuild(BuildContext context) {
    return FutureBuilder<List<AlarmInfo>>(
      // future: getEntries(0), // entries를 얻기 위해 Future를 전달
      future: () async {
        List<AlarmInfo> entries1 = await getEntries(0);
        List<AlarmInfo> entries2 = await getEntries(1);
        return [...entries1, ...entries2];
      }(),
      builder: (BuildContext context, AsyncSnapshot<List<AlarmInfo>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 데이터를 아직 받아오는 중이면 로딩 표시를 보여줌
          return Center(child: const CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // 데이터를 받아오는 도중 에러가 발생하면 에러 메시지를 보여줌
          return Text('Error: ${snapshot.error}');
        } else {
          // 데이터를 정상적으로 받아왔을 경우
          List<AlarmInfo> entries = snapshot.data!; // 해결된 데이터를 얻음
          // Future<List<AlarmInfo>> entries2 = getEntries(1); // 추가적인 리스트를 얻는 함수 호출
          // List<AlarmInfo> mergedEntries = [...entries, ...entries2]; // 두 리스트를 합치기
          List<String> displayedTexts =
              []; // List to keep track of displayed texts
          return SizedBox(
            width: GlobalData.queryWidth,
            height: GlobalData.queryHeight,
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                final reversedIndex = entries.length - 1 - index; // 인덱스를 거꾸로 계산
                String text = '';
                int type = entries[reversedIndex].type;

                if (type == 1) {
                  text = '긴급알림';
                } else {
                  text = entries[reversedIndex].date;
                }
                bool shouldDisplayText = !displayedTexts
                    .contains(text); // Check if text should be displayed
                if (shouldDisplayText) {
                  displayedTexts
                      .add(text); // Add the text to the list of displayed texts
                }

                return SizedBox(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (shouldDisplayText) ...[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          GlobalData.queryWidth * 0.05,
                          0,
                          GlobalData.queryWidth * 0.05,
                          0,
                        ),
                        child: Row(
                          children: [
                            Visibility(
                              visible:
                                  type == 1, // Conditionally show/hide the icon
                              child: const Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: Icon(
                                  Icons.notifications_active_rounded,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            Text(
                              text,
                              style: const TextStyle(
                                color: Color.fromRGBO(171, 171, 171, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    InkWell(
                      onLongPress: () async {
                        int result;
                        result = await _showBottomDeleteSheet(
                            context, entries[reversedIndex].id);
                        if (result == 1) {
                          // 삭제할 알림을 식별하고 삭제
                          int deletedId = entries[reversedIndex].id;
                          entries.removeWhere((entry) => entry.id == deletedId);
                          // setState를 호출하여 화면을 업데이트
                          setState(() {});
                        }
                      },
                      onTap: () async {
                        if (type == 0) {
                          int? alarmType = await reseponseInviteAlarm(
                              context,
                              entries[reversedIndex].myName, //알람 받는 사람
                              entries[reversedIndex].yourName); // 알람 보내는 사람
                          if (alarmType != null) {
                            responseAlarmServer(
                                entries[reversedIndex].id, alarmType);
                          }
                          //responseAlarm(entries[reversedIndex].id, type);
                          //구성원 초대 알람
                        } else if (type == 1) {
                          print(entries[reversedIndex].familyPhoneNumber);
                          reseponseEmergentcyAlarm(
                              context,
                              entries[reversedIndex].yourName,
                              entries[reversedIndex].requestUserId,
                              entries[reversedIndex].familyPhoneNumber);
                          //긴급알림
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            GlobalData.queryWidth * 0.05,
                            0,
                            GlobalData.queryWidth * 0.05,
                            0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: entries[reversedIndex].familyProfileImg ==
                                      null
                                  ? Container(
                                      width: 40,
                                      height: 60,
                                      // width: GlobalData.queryWidth * 0.1,
                                      // height: GlobalData.queryHeight * 0.1,
                                      padding: const EdgeInsets.all(5.0),
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
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 40,
                                      height: 60,
                                      // width: GlobalData.queryWidth * 0.1,
                                      // height: GlobalData.queryHeight * 0.1,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            width: 2, color: Colors.grey),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                entries[reversedIndex]
                                                    .familyProfileImg!),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                type == 2
                                    ? ('${entries[reversedIndex].yourName}${entries[reversedIndex].message}')
                                    : ('${entries[reversedIndex].yourName}${entries[reversedIndex].message}'),
                                style: const TextStyle(
                                    color: Color.fromRGBO(171, 171, 171, 1),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ));
              },
            ),
          );
        }
      },
    );
  }

  _showBottomDeleteSheet(BuildContext context, int alarmid) async {
    return showModalBottomSheet(
      backgroundColor: Color.fromRGBO(255, 250, 250, 1),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: GlobalData.queryWidth,
              child: Stack(children: [
                const Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      "삭제",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ]),
            ),
            SizedBox(
              height: 50,
              child: InkWell(
                onTap: () async {
                  final String result;
                  result = await Delete_Alarm(alarmid);
                  if (result == 'delete success') Navigator.pop(context, 1);
                },
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        '알림 삭제',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.red),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<List<AlarmInfo>> getEntries(int AlarmNum) async {
  List<AlarmInfo> entries = await loadAlarmInfo(AlarmNum);
  return entries;
}

Future<List<AlarmInfo>> loadAlarmInfo(int AlarmNum) async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  late final response;

  if (AlarmNum == 0) {
    //일반알람인 경우
    response = await dio.get('/api/v1/user/alarm');
  } else if (AlarmNum == 1) //긴급 알람인 경우
  {
    response = await dio.get('/api/v1/user/alarm/sos');
  }

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<AlarmInfo> list =
        data.map((dynamic e) => AlarmInfo.fromJson(e)).toList();
    return list;
    // print(list?[i].name);
  } else {
    throw Exception('fail');
  }
}

class AlarmInfo {
  final int id;
  final int? requestUserId;
  final String? familyPhoneNumber;
  final int type;
  final String message;
  final bool checked; //내가 알람을 읽은지 안읽은지
  final String date;
  final String myName;
  final String yourName;
  final String? familyProfileImg;
  AlarmInfo(
      {required this.id,
      this.requestUserId,
      this.familyPhoneNumber,
      required this.type,
      required this.message,
      required this.checked,
      required this.date,
      required this.myName,
      required this.yourName,
      required this.familyProfileImg});

  factory AlarmInfo.fromJson(Map<String, dynamic> json) {
    return AlarmInfo(
        id: json['id'],
        requestUserId: json['requestUserId'],
        familyPhoneNumber: json['familyPhoneNumber'],
        type: json['type'],
        message: json['message'],
        checked: json['checked'],
        date: json['date'],
        myName: json['myName'],
        yourName: json['yourName'],
        familyProfileImg: json['familyProfileImg']);
  }
}

Future<void> responseAlarmServer(int alarmId, int alarmtype) async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.patch(
    '/api/v1/family/invite/$alarmId/$alarmtype',
  );

  if (response.statusCode == 200) {
    print(response.data);
  } else {
    throw Exception('fail');
  }
}

Future<int?> reseponseInviteAlarm(
    BuildContext context, String myName, String yourName) async {
  final result = await showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return SizedBox(
        height: GlobalData.queryHeight * 0.45,
        width: GlobalData.queryWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              '구성원 초대',
              style: TextStyle(
                  color: Color.fromRGBO(87, 87, 87, 1),
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: GlobalData.queryHeight * 0.03),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Container(
                            height: GlobalData.queryHeight * 0.1, // 세로 크기 조정
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
                          ),
                          Text(
                            myName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(131, 131, 131, 1)),
                          )
                        ],
                      ),
                    ),
                    const Center(
                        child: Icon(Icons.swap_horiz,
                            size: 60, color: Colors.grey)),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Container(
                            height: GlobalData.queryHeight * 0.1, // 세로 크기 조정
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
                          ),
                          Text(
                            yourName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(131, 131, 131, 1)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: GlobalData.queryHeight * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromRGBO(56, 174, 93, 1),
                        // button의 모서리 둥근 정도를 바꿀 수 있음
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('수락하기'),
                      onPressed: () async {
                        await _showdialog_check(context);
                        Navigator.pop(context, 1);
                      }),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromRGBO(255, 92, 92, 1),
                        // button의 모서리 둥근 정도를 바꿀 수 있음
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('거절하기'),
                      onPressed: () {
                        Navigator.pop(context, 0);
                      }),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
  return result;
}

_showdialog_check(BuildContext context) {
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
                  "구성원이 추가 되었습니다",
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

void reseponseEmergentcyAlarm(
    BuildContext context, String yourName, int? userId, String? phone) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return SizedBox(
        height: GlobalData.queryHeight * 0.45,
        width: GlobalData.queryWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              '긴급알람',
              style: TextStyle(
                  color: Color.fromRGBO(87, 87, 87, 1),
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: GlobalData.queryHeight * 0.03),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          height: GlobalData.queryHeight * 0.1, // 세로 크기 조정
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
                        ),
                        Text(
                          yourName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(131, 131, 131, 1)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: GlobalData.queryHeight * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromRGBO(240, 212, 63, 1),
                        // button의 모서리 둥근 정도를 바꿀 수 있음
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('마지막 위치 확인'),
                      onPressed: () {
                        _navigateToMemberInfoPage(context, 2, userId, phone);
                      }),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromRGBO(255, 92, 92, 1),
                        // button의 모서리 둥근 정도를 바꿀 수 있음
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('전화 연결'),
                      onPressed: () async {
                        final url = Uri.parse('tel:$phone');
                        if (await canLaunchUrl(url)) {
                          launchUrl(url);
                        } else {
                          // ignore: avoid_print
                          print("Can't launch $url");
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _navigateToMemberInfoPage(
    BuildContext context, int pageNum, int? id, String? phone) {
  // TODO: 더보기 페이지로 화면 전환
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          MemberInfoPage(pageNum: pageNum, userId: id!, phone: phone!),
    ),
  );
}

Future<String> Delete_Alarm(int id) async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response =
      await dio.delete('/api/v1/user/alarm', queryParameters: {'alarmId': id});

  if (response.statusCode == 200) {
    print("ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ");
    print(response.data);
    return response.data;
  } else {
    throw Exception('fail');
  }
}
