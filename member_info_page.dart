import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'package:elib_project/auth_dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/bottom_app_bar.dart';
import 'edit_custom_tool.dart';
import 'edit_default_tool.dart';

double appBarHeight = 40;
double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height - appBarHeight) * scale;
double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

String searchText = "";

int toolcount = 0;

class defaultTool {
  final int? id;
  final int toolId;
  final String? name;
  final List? imgUrl;
  final List? shopUrl;
  final List? videoUrl;
  final String toolExplain;
  final int count;
  final String? locate;
  final String? exp;
  final String? mfd;
  final String? maker;

  defaultTool({
    required this.id,
    required this.toolId,
    required this.name,
    required this.imgUrl,
    required this.shopUrl,
    required this.videoUrl,
    required this.toolExplain,
    required this.count,
    required this.locate,
    required this.exp,
    required this.mfd,
    required this.maker,
  });

  factory defaultTool.fromJson(Map<String, dynamic> json) {
    return defaultTool(
      id: json['id'],
      toolId: json['toolId'],
      name: json['name'],
      imgUrl: json['imgUrl'],
      shopUrl: json['shopUrl'],
      videoUrl: json['videoUrl'],
      toolExplain: json['toolExplain'],
      count: json['count'],
      locate: json['locate'],
      exp: json['exp'],
      mfd: json['mfd'],
      maker: json['maker'],
    );
  }
}

class customTool {
  final int id;
  final String? name;
  final String? toolExplain;
  final int count;
  final String? locate;
  final String? exp;
  final String? mfd;

  customTool({
    required this.id,
    required this.name,
    required this.toolExplain,
    required this.count,
    required this.locate,
    required this.exp,
    required this.mfd,
  });

  factory customTool.fromJson(Map<String, dynamic> json) {
    return customTool(
      id: json['id'],
      name: json['name'],
      toolExplain: json['toolExplain'],
      count: json['count'],
      locate: json['locate'],
      exp: json['exp'],
      mfd: json['mfd'],
    );
  }
}

Future<List<defaultTool>> loadDefaultTool(int id) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  print("access ${accessToken}");

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/family/$id/tool/default');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<defaultTool> list =
        data.map((dynamic e) => defaultTool.fromJson(e)).toList();

    //토큰확인용
    final accessToken = await storage.read(key: 'ACCESS_TOKEN');
    final refreshToken = await storage.read(key: 'REFRESH_TOKEN');
    print("newaccess ${accessToken}");
    print("newrefresh ${refreshToken}");

    return list;
  } else {
    throw Exception('Failed to Load');
  }
}

Future<List<customTool>> loadCustomTool(int id) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/family/$id/tool/custom');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<customTool> list =
        data.map((dynamic e) => customTool.fromJson(e)).toList();
    return list;
  } else {
    throw Exception('Failed to Load');
  }
}

class GlobalData {
  static double queryWidth = 0.0;
  static double queryHeight = 0.0;
  static double lat = 0.0;
  static double lon = 0.0;
  static String updated = "";
}

class MemberInfoPage extends StatefulWidget {
  final int pageNum;
  final int userId;
  final String phone;
  const MemberInfoPage(
      {Key? key,
      required this.pageNum,
      required this.userId,
      required this.phone})
      : super(key: key);

  @override
  State<MemberInfoPage> createState() => _MemberInfoPageState();
}

class _MemberInfoPageState extends State<MemberInfoPage> {
  late Future<List<defaultTool>> futureDefaultTool;
  late Future<List<customTool>> futureCustomTool;

  @override
  void initState() {
    super.initState();
    futureDefaultTool = loadDefaultTool(widget.userId);
    futureCustomTool = loadCustomTool(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    GlobalData.queryHeight = MediaQuery.of(context).size.height;
    GlobalData.queryWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<LocationInfo>(
      future: loadFamilyLocation(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          LocationInfo location = snapshot.data!;
          GlobalData.lat = location.lat;
          GlobalData.lon = location.lon;
          GlobalData.updated = location.updated;
          // 여기서 location 객체의 속성을 사용하여 필요한 작업을 수행할 수 있습니다.
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                scaffoldBackgroundColor: Color.fromARGB(255, 250, 250, 250),
                useMaterial3: true),
            home: DefaultTabController(
              initialIndex: widget.pageNum,
              length: 4,
              child: Scaffold(
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
                    "구성원 조회",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(48),
                    child: Material(
                      color: const Color.fromARGB(255, 250, 250, 250),
                      child: Theme(
                        data: ThemeData(
                          scaffoldBackgroundColor:
                              const Color.fromARGB(255, 250, 250, 250),
                          colorSchemeSeed:
                              const Color.fromARGB(0, 241, 241, 241),
                        ).copyWith(splashColor: Colors.green),
                        child: const TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Color.fromRGBO(
                            171,
                            171,
                            171,
                            1,
                          ),
                          tabs: <Widget>[
                            Tab(
                              child: Text(
                                '도구 현황',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                '훈련 현황',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                '최근 위치',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                '긴급 연락',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                body: TabBarView(
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          children: [
                            FutureBuilder<List<defaultTool>>(
                                future: futureDefaultTool,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError)
                                    return Text('${snapshot.error}');
                                  else if (snapshot.hasData) {
                                    return Column(
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15, right: 15),
                                              child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width, //fullsize
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          snapshot.data?.length,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemBuilder:
                                                          (context, i) {
                                                        int countColor;
                                                        int countText;
                                                        int iconColor;
                                                        int iconBack;

                                                        int locateColor =
                                                            0xFFCFDFFF;
                                                        int locateText =
                                                            0xFF6A9DFF;

                                                        int expColor =
                                                            0xFFB6F4CB;
                                                        int expText =
                                                            0xFF38AE5D;

                                                        double locateWidth = 80;
                                                        double locatePadding =
                                                            10;
                                                        double expWidth = 80;
                                                        double expPadding = 10;

                                                        double makerWidth = 80;
                                                        double makerPadding =
                                                            10;

                                                        if (snapshot.data?[i]
                                                                .count ==
                                                            0) {
                                                          countColor =
                                                              0xFFFFC5C5; //pink background
                                                          countText =
                                                              0xFFF16969; //pink text

                                                          iconBack =
                                                              0xFFFFC5C5; //pink background
                                                          iconColor =
                                                              0xFFF16969; //pink text
                                                        } else {
                                                          countColor =
                                                              0xFFFFF3B2; //yellow background
                                                          countText =
                                                              0xFFE4C93D; //yellow text

                                                          iconBack =
                                                              0xFFFFF3B2; //yellow background
                                                          iconColor =
                                                              0xFFE4C93D; //yellow text
                                                        }

                                                        String? name;
                                                        if (snapshot.data?[i]
                                                                    .name ==
                                                                null ||
                                                            snapshot.data?[i]
                                                                    .name ==
                                                                "") {
                                                          name = "";
                                                        } else {
                                                          name = snapshot
                                                              .data?[i].name;
                                                        }

                                                        String? toolExplain;
                                                        if (snapshot.data?[i]
                                                                    .toolExplain ==
                                                                null ||
                                                            snapshot.data?[i]
                                                                    .toolExplain ==
                                                                "") {
                                                          toolExplain =
                                                              "상세정보를 입력하세요.";
                                                        } else {
                                                          toolExplain = snapshot
                                                              .data?[i]
                                                              .toolExplain;
                                                          if (toolExplain!
                                                                  .length >
                                                              24) {
                                                            toolExplain =
                                                                toolExplain
                                                                    ?.substring(
                                                                        0, 24);
                                                            toolExplain =
                                                                "$toolExplain...";
                                                          }
                                                        }

                                                        String? exp;
                                                        if (snapshot.data?[i]
                                                                    .exp ==
                                                                null ||
                                                            snapshot.data?[i]
                                                                    .exp ==
                                                                "") {
                                                          exp = "";
                                                          expWidth = 0;
                                                          expPadding = 0;
                                                        } else {
                                                          exp = snapshot
                                                              .data?[i].exp;
                                                        }

                                                        String? maker;
                                                        if (snapshot.data?[i]
                                                                    .maker ==
                                                                null ||
                                                            snapshot.data?[i]
                                                                    .maker ==
                                                                "") {
                                                          maker = "Ad.";
                                                          makerWidth = 40;
                                                          //makerPadding = 0;
                                                        } else {
                                                          maker = snapshot
                                                              .data?[i].maker;

                                                          if (maker!.length <
                                                              3) {
                                                            makerWidth = 40;
                                                          } else if (maker!
                                                                  .length <
                                                              4) {
                                                            makerWidth = 50;
                                                          } else if (maker!
                                                                  .length <
                                                              5) {
                                                            makerWidth = 60;
                                                          } else if (maker!
                                                                  .length >
                                                              5) {
                                                            maker = maker
                                                                ?.substring(
                                                                    0, 5);
                                                            maker = "$maker...";
                                                          }
                                                        }

                                                        String? locate;
                                                        if (snapshot.data?[i]
                                                                    .locate ==
                                                                null ||
                                                            snapshot.data?[i]
                                                                    .locate ==
                                                                "") {
                                                          locate = "";
                                                          locateWidth = 0;
                                                          locatePadding = 0;
                                                        } else {
                                                          locate = snapshot
                                                              .data?[i].locate;

                                                          if (locate!.length <
                                                              3) {
                                                            locateWidth = 40;
                                                          } else if (locate!
                                                                  .length <
                                                              4) {
                                                            locateWidth = 50;
                                                          } else if (locate!
                                                                  .length <
                                                              5) {
                                                            locateWidth = 60;
                                                          } else if (locate!
                                                                  .length >
                                                              5) {
                                                            locate = locate
                                                                ?.substring(
                                                                    0, 5);
                                                            locate =
                                                                "$locate...";
                                                          }
                                                        }

                                                        if (searchText!
                                                                .isNotEmpty &&
                                                            !snapshot
                                                                .data![i].name!
                                                                .toLowerCase()
                                                                .contains(searchText
                                                                    .toLowerCase())) {
                                                          return const SizedBox
                                                              .shrink();
                                                        } else {
                                                          return Column(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 10,
                                                                      bottom:
                                                                          10),
                                                                  child:
                                                                      Container(
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              right: 20,
                                                                              left: 10,
                                                                              top: 5,
                                                                              bottom: 5),
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(
                                                                                width: 1.8,
                                                                                color: Color(iconBack),
                                                                              ),
                                                                              color: Color(iconBack),
                                                                              borderRadius: BorderRadius.circular(10),
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.all(5.0),
                                                                              child: Icon(
                                                                                Icons.local_fire_department,
                                                                                color: Color(iconColor),
                                                                                size: 30,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(top: 1),
                                                                              child: Text.rich(TextSpan(children: [
                                                                                TextSpan(
                                                                                    text: '$name',
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey.shade700,
                                                                                      fontSize: 18,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    )),
                                                                              ])),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(top: 2),
                                                                              child: Text.rich(TextSpan(children: [
                                                                                TextSpan(
                                                                                    text: '$toolExplain',
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey.shade500,
                                                                                      fontSize: 16,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    )),
                                                                              ])),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(top: 5),
                                                                              child: Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(right: 10),
                                                                                    child: Container(
                                                                                      height: 20,
                                                                                      width: 35,
                                                                                      decoration: BoxDecoration(
                                                                                        border: Border.all(
                                                                                          width: 1,
                                                                                          color: Color(countColor),
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(5),
                                                                                        color: Color(countColor),
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                        child: Text(
                                                                                          '${snapshot.data?[i].count}개',
                                                                                          style: TextStyle(
                                                                                            color: Color(countText),
                                                                                            fontSize: 12,
                                                                                            fontWeight: FontWeight.bold,
                                                                                          ),
                                                                                          textAlign: TextAlign.center,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(right: locatePadding),
                                                                                    child: Container(
                                                                                      height: 20,
                                                                                      width: locateWidth,
                                                                                      decoration: BoxDecoration(
                                                                                        border: Border.all(
                                                                                          width: 1,
                                                                                          color: Color(locateColor),
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(5),
                                                                                        color: Color(locateColor),
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                        child: Text(
                                                                                          '$locate',
                                                                                          style: TextStyle(
                                                                                            color: Color(locateText),
                                                                                            fontSize: 12,
                                                                                            fontWeight: FontWeight.bold,
                                                                                          ),
                                                                                          textAlign: TextAlign.center,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(right: expPadding),
                                                                                    child: Container(
                                                                                      height: 20,
                                                                                      width: expWidth,
                                                                                      decoration: BoxDecoration(
                                                                                        border: Border.all(
                                                                                          width: 1,
                                                                                          color: Color(expColor),
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(5),
                                                                                        color: Color(expColor),
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                        child: Text(
                                                                                          '$exp',
                                                                                          style: TextStyle(
                                                                                            color: Color(expText),
                                                                                            fontSize: 12,
                                                                                            fontWeight: FontWeight.bold,
                                                                                          ),
                                                                                          textAlign: TextAlign.center,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                    height: 20,
                                                                                    width: makerWidth,
                                                                                    decoration: BoxDecoration(
                                                                                      border: Border.all(
                                                                                        width: 1,
                                                                                        color: Colors.grey.shade300,
                                                                                      ),
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      color: Colors.grey.shade300,
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                      child: Text(
                                                                                        '$maker',
                                                                                        style: TextStyle(
                                                                                          color: Colors.grey,
                                                                                          fontSize: 12,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        ),
                                                                                        textAlign: TextAlign.center,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ]);
                                                        }
                                                      })),
                                            ),
                                            FutureBuilder<List<customTool>>(
                                                future: futureCustomTool,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasError)
                                                    return Text(
                                                        '${snapshot.error}');
                                                  else if (snapshot.hasData) {
                                                    return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 15,
                                                                right: 15),
                                                        child: SizedBox(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child:
                                                              ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemCount: snapshot
                                                                .data?.length,
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            itemBuilder:
                                                                (context, i) {
                                                              int countColor;
                                                              int countText;
                                                              int iconColor;
                                                              int iconBack;

                                                              int locateColor =
                                                                  0xFFCFDFFF;
                                                              int locateText =
                                                                  0xFF6A9DFF;

                                                              int expColor =
                                                                  0xFFB6F4CB;
                                                              int expText =
                                                                  0xFF38AE5D;

                                                              double
                                                                  locateWidth =
                                                                  80;
                                                              double
                                                                  locatePadding =
                                                                  10;
                                                              double expWidth =
                                                                  80;
                                                              double
                                                                  expPadding =
                                                                  10;

                                                              if (snapshot
                                                                      .data?[i]
                                                                      .count ==
                                                                  0) {
                                                                countColor =
                                                                    0xFFFFC5C5; //pink background
                                                                countText =
                                                                    0xFFF16969; //pink text

                                                                iconBack =
                                                                    0xFFFFC5C5; //pink background
                                                                iconColor =
                                                                    0xFFF16969; //pink text
                                                              } else {
                                                                countColor =
                                                                    0xFFFFF3B2; //yellow background
                                                                countText =
                                                                    0xFFE4C93D; //yellow text

                                                                iconBack =
                                                                    0xFFFFF3B2; //yellow background
                                                                iconColor =
                                                                    0xFFE4C93D; //yellow text
                                                              }

                                                              String? name;
                                                              if (snapshot
                                                                          .data?[
                                                                              i]
                                                                          .name ==
                                                                      null ||
                                                                  snapshot
                                                                          .data?[
                                                                              i]
                                                                          .name ==
                                                                      "") {
                                                                name = "";
                                                              } else {
                                                                name = snapshot
                                                                    .data?[i]
                                                                    .name;
                                                              }

                                                              String?
                                                                  toolExplain;
                                                              if (snapshot
                                                                          .data?[
                                                                              i]
                                                                          .toolExplain ==
                                                                      null ||
                                                                  snapshot
                                                                          .data?[
                                                                              i]
                                                                          .toolExplain ==
                                                                      "") {
                                                                toolExplain =
                                                                    "상세정보를 입력하세요.";
                                                              } else {
                                                                toolExplain =
                                                                    snapshot
                                                                        .data?[
                                                                            i]
                                                                        .toolExplain;
                                                                if (toolExplain!
                                                                        .length >
                                                                    15) {
                                                                  toolExplain =
                                                                      toolExplain
                                                                          ?.substring(
                                                                              0,
                                                                              15);
                                                                  toolExplain =
                                                                      "$toolExplain...";
                                                                }
                                                              }

                                                              String? exp;
                                                              if (snapshot
                                                                          .data?[
                                                                              i]
                                                                          .exp ==
                                                                      null ||
                                                                  snapshot
                                                                          .data?[
                                                                              i]
                                                                          .exp ==
                                                                      "") {
                                                                exp = "";
                                                                expWidth = 0;
                                                                expPadding = 0;
                                                              } else {
                                                                exp = snapshot
                                                                    .data?[i]
                                                                    .exp;
                                                              }

                                                              String? locate;
                                                              if (snapshot
                                                                          .data?[
                                                                              i]
                                                                          .locate ==
                                                                      null ||
                                                                  snapshot
                                                                          .data?[
                                                                              i]
                                                                          .locate ==
                                                                      "") {
                                                                locate = "";
                                                                locateWidth = 0;
                                                                locatePadding =
                                                                    0;
                                                              } else {
                                                                locate =
                                                                    snapshot
                                                                        .data?[
                                                                            i]
                                                                        .locate;

                                                                if (locate!
                                                                        .length <
                                                                    3) {
                                                                  locateWidth =
                                                                      40;
                                                                } else if (locate!
                                                                        .length <
                                                                    4) {
                                                                  locateWidth =
                                                                      50;
                                                                } else if (locate!
                                                                        .length <
                                                                    5) {
                                                                  locateWidth =
                                                                      60;
                                                                } else if (locate!
                                                                        .length >
                                                                    5) {
                                                                  locate = locate
                                                                      ?.substring(
                                                                          0, 5);
                                                                  locate =
                                                                      "$locate...";
                                                                }
                                                              }

                                                              if (searchText!
                                                                      .isNotEmpty &&
                                                                  !snapshot
                                                                      .data![i]
                                                                      .name!
                                                                      .toLowerCase()
                                                                      .contains(
                                                                          searchText
                                                                              .toLowerCase())) {
                                                                return SizedBox
                                                                    .shrink();
                                                              } else
                                                                return InkWell(
                                                                  onTap: () {
                                                                    showCustom(
                                                                        context,
                                                                        snapshot
                                                                            .data?[i]);
                                                                  },
                                                                  child: Column(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                10,
                                                                            bottom:
                                                                                10),
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(right: 20, left: 10, top: 5, bottom: 5),
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border.all(
                                                                                      width: 1.7,
                                                                                      color: Color(iconBack),
                                                                                    ),
                                                                                    color: Color(iconBack),
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(10.0),
                                                                                    child: Icon(
                                                                                      Icons.medical_services,
                                                                                      color: Color(iconColor),
                                                                                      size: 20,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(top: 1),
                                                                                    child: Text.rich(TextSpan(children: [
                                                                                      TextSpan(
                                                                                          text: '$name',
                                                                                          style: TextStyle(
                                                                                            color: Colors.grey.shade700,
                                                                                            fontSize: 18,
                                                                                            fontWeight: FontWeight.bold,
                                                                                          )),
                                                                                    ])),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(top: 2),
                                                                                    child: Text.rich(TextSpan(children: [
                                                                                      TextSpan(
                                                                                          text: '$toolExplain',
                                                                                          style: TextStyle(
                                                                                            color: Colors.grey.shade500,
                                                                                            fontSize: 16,
                                                                                            fontWeight: FontWeight.bold,
                                                                                          )),
                                                                                    ])),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(top: 5),
                                                                                    child: Row(
                                                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(right: 10),
                                                                                          child: Container(
                                                                                            height: 20,
                                                                                            width: 35,
                                                                                            decoration: BoxDecoration(
                                                                                              border: Border.all(
                                                                                                width: 1,
                                                                                                color: Color(countColor),
                                                                                              ),
                                                                                              borderRadius: BorderRadius.circular(5),
                                                                                              color: Color(countColor),
                                                                                            ),
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                              child: Text(
                                                                                                '${snapshot.data?[i].count}개',
                                                                                                style: TextStyle(
                                                                                                  color: Color(countText),
                                                                                                  fontSize: 12,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                ),
                                                                                                textAlign: TextAlign.center,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(right: locatePadding),
                                                                                          child: Container(
                                                                                            height: 20,
                                                                                            width: locateWidth,
                                                                                            decoration: BoxDecoration(
                                                                                              border: Border.all(
                                                                                                width: 1,
                                                                                                color: Color(locateColor),
                                                                                              ),
                                                                                              borderRadius: BorderRadius.circular(5),
                                                                                              color: Color(locateColor),
                                                                                            ),
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                              child: Text(
                                                                                                '$locate',
                                                                                                style: TextStyle(
                                                                                                  color: Color(locateText),
                                                                                                  fontSize: 12,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                ),
                                                                                                textAlign: TextAlign.center,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(right: expPadding),
                                                                                          child: Container(
                                                                                            height: 20,
                                                                                            width: expWidth,
                                                                                            decoration: BoxDecoration(
                                                                                              border: Border.all(
                                                                                                width: 1,
                                                                                                color: Color(expColor),
                                                                                              ),
                                                                                              borderRadius: BorderRadius.circular(5),
                                                                                              color: Color(expColor),
                                                                                            ),
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.only(left: 5, right: 5),
                                                                                              child: Text(
                                                                                                '$exp',
                                                                                                style: TextStyle(
                                                                                                  color: Color(expText),
                                                                                                  fontSize: 12,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                ),
                                                                                                textAlign: TextAlign.center,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                            },
                                                          ),
                                                        ));
                                                  } else
                                                    return CircularProgressIndicator();
                                                })
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                  return CircularProgressIndicator();
                                }),
                          ],
                        ),
                      ),
                    ),
                    const Center(
                      child: Text("It's rainy here"),
                    ),
                    const Center(
                      child: LocationBuildPage(),
                    ),
                    EmergencyCall(
                        phoneNum: widget.phone, userId: widget.userId),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class EmergencyCall extends StatelessWidget {
  final String phoneNum;
  final int userId;
  const EmergencyCall({Key? key, required this.phoneNum, required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
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
      Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  GlobalData.queryWidth * 0.05,
                  GlobalData.queryHeight * 0.01,
                  GlobalData.queryWidth * 0.05,
                  GlobalData.queryHeight * 0.03),
              child: const Text(
                "국가기관",
                style: TextStyle(
                    color: Color.fromRGBO(171, 171, 171, 1),
                    fontWeight: FontWeight.bold),
              ),
            ),
            InkWell(
              onTap: () async {
                final url = Uri.parse('tel:112');
                if (await canLaunchUrl(url)) {
                  launchUrl(url);
                } else {
                  // ignore: avoid_print
                  print("Can't launch $url");
                }
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        GlobalData.queryWidth * 0.1,
                        GlobalData.queryHeight * 0.01,
                        GlobalData.queryWidth * 0.1,
                        GlobalData.queryHeight * 0.01),
                    child: Container(
                      width: 50,
                      height: 50, // 세로 크기 조정
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset('assets/image/policelogo.png',
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      '112 전화연결',
                      style: TextStyle(
                          color: Color.fromRGBO(131, 131, 131, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                  ),
                  const Expanded(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(0, GlobalData.queryHeight * 0.02,
                    0, GlobalData.queryHeight * 0.02)),
            InkWell(
              onTap: () async {
                final url = Uri.parse('tel:112');
                if (await canLaunchUrl(url)) {
                  launchUrl(url);
                } else {
                  // ignore: avoid_print
                  print("Can't launch $url");
                }
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        GlobalData.queryWidth * 0.1,
                        GlobalData.queryHeight * 0.01,
                        GlobalData.queryWidth * 0.1,
                        GlobalData.queryHeight * 0.01),
                    child: Container(
                      width: 50,
                      height: 50, // 세로 크기 조정
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                        // image: DecorationImage(
                        //     image: AssetImage('assets/image/emergency_logo.png'),
                        //     fit: BoxFit.fill),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            'assets/image/firestationlogo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      '119 전화연결',
                      style: TextStyle(
                          color: Color.fromRGBO(131, 131, 131, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                  ),
                  const Expanded(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(
            //       GlobalData.queryWidth * 0.05,
            //       GlobalData.queryHeight * 0.03,
            //       GlobalData.queryWidth * 0.05,
            //       GlobalData.queryHeight * 0.03),
            //   child: const Text(
            //     "국가 기관",
            //     style: TextStyle(
            //         color: Color.fromRGBO(171, 171, 171, 1),
            //         fontWeight: FontWeight.bold),
            //   ),
            // ),
            // // 119 소방대원
            // InkWell(
            //   onTap: () async {
            //     final url = Uri.parse('tel:119');
            //     if (await canLaunchUrl(url)) {
            //       launchUrl(url);
            //     } else {
            //       // ignore: avoid_print
            //       print("Can't launch $url");
            //     }
            //   },
            //   child: Row(
            //     children: [
            //       Container(
            //         height: 50, // 세로 크기 조정
            //         decoration: BoxDecoration(
            //           shape: BoxShape.circle,
            //           border: Border.all(
            //             color: Colors.grey,
            //             width: 1.0,
            //           ),
            //           // image: DecorationImage(
            //           //     image: AssetImage('assets/image/firestationlogo.png'),
            //           //     fit: BoxFit.fill),
            //         ),
            //         child: ClipOval(
            //           child: Image.asset(
            //             'assets/image/firestationlogo.png',
            //             fit: BoxFit.fill, // Adjust the fit as needed
            //           ),
            //         ),
            //       ),
            //       const Expanded(
            //           flex: 2,
            //           child: Text(
            //             '119',
            //             style: TextStyle(
            //                 color: Color.fromRGBO(131, 131, 131, 1),
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 25),
            //           )),
            //       const Expanded(
            //         child: Icon(
            //           Icons.arrow_forward_ios,
            //           size: 30,
            //           color: Colors.grey,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Padding(
            //     padding: EdgeInsets.fromLTRB(0, GlobalData.queryHeight * 0.02, 0,
            //         GlobalData.queryHeight * 0.02)),
            // // 112 경찰
            // InkWell(
            //   onTap: () async {
            //     final url = Uri.parse('tel:112');
            //     if (await canLaunchUrl(url)) {
            //       launchUrl(url);
            //     } else {
            //       // ignore: avoid_print
            //       print("Can't launch $url");
            //     }
            //   },
            //   child: Row(
            //     children: [
            //       Expanded(
            //         flex: 2,
            //         child: Container(
            //           height: 50, // 세로 크기 조정
            //           decoration: BoxDecoration(
            //             shape: BoxShape.circle,
            //             border: Border.all(
            //               color: Colors.grey,
            //               width: 1.0,
            //             ),
            //             image: DecorationImage(
            //                 image: AssetImage('assets/image/policelogo.png'),
            //                 fit: BoxFit.fill),
            //           ),
            //         ),
            //       ),
            //       const Expanded(
            //           flex: 2,
            //           child: Text(
            //             '112',
            //             style: TextStyle(
            //                 color: Color.fromRGBO(131, 131, 131, 1),
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 25),
            //           )),
            //       const Expanded(
            //         child: Icon(
            //           Icons.arrow_forward_ios,
            //           size: 30,
            //           color: Colors.grey,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(
                top: GlobalData.queryHeight * 0.05,
              ),
              child: Divider(
                  thickness: 1,
                  height: 1,
                  color: Color.fromRGBO(131, 131, 131, 1)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  GlobalData.queryWidth * 0.05,
                  GlobalData.queryHeight * 0.03,
                  GlobalData.queryWidth * 0.05,
                  GlobalData.queryHeight * 0.03),
              child: const Text(
                "연락하기",
                style: TextStyle(
                    color: Color.fromRGBO(171, 171, 171, 1),
                    fontWeight: FontWeight.bold),
              ),
            ),
            InkWell(
              onTap: () async {
                final url = Uri.parse('tel:$phoneNum');
                if (await canLaunchUrl(url)) {
                  launchUrl(url);
                } else {
                  // ignore: avoid_print
                  print("Can't launch $url");
                }
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        GlobalData.queryWidth * 0.1,
                        GlobalData.queryHeight * 0.01,
                        GlobalData.queryWidth * 0.1,
                        GlobalData.queryHeight * 0.01),
                    child: Container(
                      height: 50, // 세로 크기 조정
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset('assets/image/call_logo.png',
                              fit: BoxFit.cover, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      '전화걸기',
                      style: TextStyle(
                          color: Color.fromRGBO(131, 131, 131, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                  ),
                  const Expanded(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(0, GlobalData.queryHeight * 0.02,
                    0, GlobalData.queryHeight * 0.02)),
            InkWell(
              onTap: () async {
                await sendAlarm(userId);
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Theme(
                        data: ThemeData(
                          dialogBackgroundColor:
                              Colors.white, // Override dialog background color
                        ),
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(
                            "긴급알림",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "긴급 알림을 보냈습니다 ",
                                style: TextStyle(fontSize: 15),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("확인")),
                              )
                            ],
                          ),
                        ),
                      );
                    });
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        GlobalData.queryWidth * 0.1,
                        GlobalData.queryHeight * 0.01,
                        GlobalData.queryWidth * 0.1,
                        GlobalData.queryHeight * 0.01),
                    child: Container(
                      height: 50, // 세로 크기 조정
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                        // image: DecorationImage(
                        //     image: AssetImage('assets/image/emergency_logo.png'),
                        //     fit: BoxFit.fill),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            'assets/image/emergency_logo.png',
                            fit: BoxFit.cover,
                            color: Color.fromRGBO(255, 92, 92, 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      '알림 보내기',
                      style: TextStyle(
                          color: Color.fromRGBO(131, 131, 131, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                  ),
                  const Expanded(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ]),
    ]);
  }
}

class LocationBuildPage extends StatefulWidget {
  const LocationBuildPage({Key? key}) : super(key: key);

  @override
  State<LocationBuildPage> createState() => LocationBuildPageState();
}

class LocationBuildPageState extends State<LocationBuildPage> {
  late NaverMapController _mapController;
  final Completer<NaverMapController> mapControllerCompleter = Completer();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;
    final mapSize = Size(mediaQuery.size.width, mediaQuery.size.height);
    final physicalSize =
        Size(mapSize.width * pixelRatio, mapSize.height * pixelRatio);

    print("physicalSize: $physicalSize");

    return Scaffold(
      backgroundColor: const Color(0xFF343945),
      body: Center(
          child: SizedBox(
              width: mapSize.width,
              height: mapSize.height,
              // color: Colors.greenAccent,
              child: _naverMapSection())),
    );
  }

  Widget _naverMapSection() => NaverMap(
        forceGesture: true,
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
              target: NLatLng(GlobalData.lat, GlobalData.lon),
              zoom: 18,
              bearing: 0,
              tilt: 0),
          indoorEnable: true,
          locationButtonEnable: true,
          consumeSymbolTapEvents: false,
          rotationGesturesEnable: true,
          scrollGesturesEnable: true,
          tiltGesturesEnable: true,
          zoomGesturesEnable: true,
          stopGesturesEnable: true,
          scrollGesturesFriction: 1.0,
          zoomGesturesFriction: 1.0,
        ),
        onMapReady: (controller) async {
          _mapController = controller;
          mapControllerCompleter.complete(controller);
          log("onMapReady", name: "onMapReady");
          _addMarker();
        },
      );
  void _addMarker() {
    final marker = NMarker(
      id: 'userPosition',
      position: NLatLng(GlobalData.lat, GlobalData.lon),
    );

    _mapController.addOverlay(marker);
    final onMarkerInfoWindow = NInfoWindow.onMarker(
        id: marker.info.id, text: '마지막 접속 일시: ${GlobalData.updated}');
    marker.openInfoWindow(onMarkerInfoWindow);
  }
}

// loadFamilyLocation(userId)
Future<LocationInfo> loadFamilyLocation(int id) async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/family/$id/locate');

  if (response.statusCode == 200) {
    return LocationInfo.fromJson(response.data);
  } else {
    throw Exception('fail');
  }
}

class LocationInfo {
  final double lat;
  final double lon;
  final String updated;
  LocationInfo({required this.lat, required this.lon, required this.updated});
  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
        lat: json['lat'], lon: json['lon'], updated: json['updated']);
  }
}

Future<void> sendAlarm(int id) async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.post('/api/v1/family/$id/alarm/sos');

  if (response.statusCode == 200) {
    print("ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ");
    print(response.data);
  } else {
    throw Exception('fail');
  }
}

Future<dynamic> showDefault(BuildContext context, defaultTool) {
  String? locate = defaultTool.locate;
  if (locate == null || locate == "") {
    locate = "-";
  } else {
    if (locate.length > 15) {
      locate = locate.substring(0, 15);
      locate = "$locate...";
    }
  }

  String? exp = defaultTool.exp;
  if (exp == null || exp == "") {
    exp = "-";
  }

  String? mfd = defaultTool.mfd;
  if (mfd == null || mfd == "") {
    mfd = "-";
  }

  String? maker = defaultTool.maker;

  String? toolExplain = defaultTool.toolExplain;
  if (toolExplain == null || toolExplain == "") {
    toolExplain = "-";
  } else {
    if (toolExplain.length > 15) {
      toolExplain = toolExplain.substring(0, 15);
      toolExplain = "$toolExplain...";
    }
  }

  List? shopUrl = defaultTool.shopUrl;
  List? imgUrl = defaultTool.imgUrl;
  List? videoUrl = defaultTool.videoUrl;

  bool shopVisible = true;
  if (shopUrl!.isEmpty == true) {
    shopVisible = false;
  }

  bool imgVisible = true;
  if (imgUrl!.isEmpty == true) {
    imgVisible = false;
  }

  bool videoVisible = true;
  if (videoUrl!.isEmpty == true) {
    videoVisible = false;
  }

  double fontSize = 12;

  return showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      content: Container(
        height: 480,
        width: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: shopVisible,
                  child: IconButton(
                    icon: Icon(
                      Icons.store,
                      color: Colors.blue,
                      size: 30,
                    ),
                    onPressed: () {},
                  ),
                ),
                Visibility(
                  visible: imgVisible,
                  child: IconButton(
                    icon: Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 30,
                    ),
                    onPressed: () {
                      print(imgUrl);
                    },
                  ),
                ),
                Visibility(
                  visible: videoVisible,
                  child: IconButton(
                    icon: Icon(
                      Icons.videocam,
                      color: Colors.grey,
                      size: 30,
                    ),
                    onPressed: () {
                      print(videoUrl);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.7,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.local_fire_department,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 15),
              child: Text(
                defaultTool.name,
                style: TextStyle(
                    color: const Color.fromARGB(255, 70, 70, 70),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '보유수량',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    defaultTool.count.toString(),
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '위치',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${locate}',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '제조일자',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${mfd}',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '유통기한',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${exp}',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '상세정보',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${toolExplain}',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      elevation: 10.0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
    ),
  );
}

Future<dynamic> showCustom(BuildContext context, customTool) {
  String? locate = customTool.locate;
  if (locate == null || locate == "") {
    locate = "-";
  } else {
    if (locate.length > 15) {
      locate = locate.substring(0, 15);
      locate = "$locate...";
    }
  }

  String? exp = customTool.exp;
  if (exp == null || exp == "") {
    exp = "-";
  }

  String? mfd = customTool.mfd;
  if (mfd == null || mfd == "") {
    mfd = "-";
  }

  String? toolExplain = customTool.toolExplain;
  if (toolExplain == null || toolExplain == "") {
    toolExplain = "-";
  } else {
    if (toolExplain.length > 15) {
      toolExplain = toolExplain.substring(0, 15);
      toolExplain = "$toolExplain...";
    }
  }

  double fontSize = 12;

  return showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      content: Container(
        height: 480,
        width: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.7,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.medical_services,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 15),
              child: Text(
                customTool.name,
                style: TextStyle(
                    color: const Color.fromARGB(255, 70, 70, 70),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '보유수량',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    customTool.count.toString(),
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '위치',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${locate}',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '제조일자',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${mfd}',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '유통기한',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${exp}',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '상세정보',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${toolExplain}',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      elevation: 10.0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
    ),
  );
}
