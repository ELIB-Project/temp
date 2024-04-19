import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:elib_project/auth_dio.dart';
import 'package:elib_project/pages/tool_manage.dart';
import 'package:elib_project/pages/tool_regist_qr.dart';
import 'package:elib_project/pages/train_manage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uni_links/uni_links.dart';

import 'alarm_page.dart';

int safetyColor = 0;

double fullWidth = 0;
double categoryWidth = 70;
double categoryLine = 0;
double categorySpace = categoryWidth + categoryLine;

late Future<void> loadCategory;

late Future<Map<String, int>> calculateDefaultTool;

List toolCategories = [];
String? selectedCategory;

//전체 도구 불러오기
Future<List<defaultTool>> loadAllDefaultTool() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/user/tool/default');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<defaultTool> list =
        data.map((dynamic e) => defaultTool.fromJson(e)).toList();

    return list;
  } else {
    throw Exception('Failed to Load');
  }
}

//도구 타입별로 분류
Future<List<defaultTool>> loadDefaultToolByType(String type) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/user/tool/default');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<defaultTool> list =
        data.map((dynamic e) => defaultTool.fromJson(e)).toList();

    // 해당 타입에 해당하는 도구만 반환
    return list.where((tool) => tool.type == type).toList();
  } else {
    throw Exception('Failed to Load');
  }
}

//도구 화재 불러오기-안씀
//futureFireTools = loadFireTools();로 사용
late Future<List<defaultTool>> futureFireTools;

Future<List<defaultTool>> loadFireTools() async {
  return await loadDefaultToolByType("화재");
}

Future<void> init() async {
  final storage = FlutterSecureStorage();
  String? toolStorage = await storage.read(key: 'Category_Tool');

  if (toolStorage == null || toolStorage == "") {
    toolCategories = ["전체", "화재", "응급", "지진", "생존", "전쟁", "수해", "기타"];
    await storage.write(
        key: 'Category_Tool', value: jsonEncode(toolCategories));
  } else {
    toolCategories = jsonDecode(toolStorage!);
  }

  if (selectedCategory == null || selectedCategory == "") {
    selectedCategory = toolCategories[0];
  } else {
    if (toolCategories.contains(selectedCategory) == false) {
      selectedCategory = toolCategories[0];
    }
  }
}

//커스텀 도구 불러오기
Future<List<customTool>> loadAllCustomTool() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/user/tool/custom');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<customTool> list =
        data.map((dynamic e) => customTool.fromJson(e)).toList();

    return list;
  } else {
    throw Exception('Failed to Load');
  }
}

//빈 리스트 반환 1
Future<List<defaultTool>> loadEmptyDefaultTool() async {
  return [];
}

//빈 리스트 반환 2
Future<List<customTool>> loadEmptyCustomTool() async {
  return [];
}

/////////////////////////////////////////////////////////////////////////////

//전체 훈련 불러오기
Future<List<trainList>> loadAllDefaultTrain() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/train');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<trainList> list =
        data.map((dynamic e) => trainList.fromJson(e)).toList();

    //미이수 개수
    int allTrainCount = list.length;
    int trainCount = allTrainCount - await loadTrainCount();
    buildTextData(trainCount, allTrainCount);

    return list;
  } else {
    throw Exception('Failed to Load');
  }
}

//훈련 타입별로 분류
Future<List<trainList>> loadDefaultTrainByType(String type) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/train');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<trainList> list =
        data.map((dynamic e) => trainList.fromJson(e)).toList();

    //미이수 개수
    int allTrainCount = list.where((train) => train.type == type).toList().length;
    int trainCount = allTrainCount - list.where((train) => train.type == type && train.imgComplete==true && train.videoComplete==true).toList().length;
    buildTextData(trainCount, allTrainCount);

    // 해당 타입에 해당하는 도구만 반환
    return list.where((train) => train.type == type).toList();
  } else {
    throw Exception('Failed to Load');
  }
}

String textA = "";
String textB = "";
String textC = "";
String textD = "";
String textE = "";

Color colorB = Colors.grey.shade600;
Color colorC = Colors.grey.shade600;
Color colorD = Colors.grey.shade600;

void buildTextData(int trainCount, int allTrainCount) {

  if (allTrainCount == 0) {
    textA = "이수 할 훈련이 없습니다.";
    textB = "";
    textC = "";
    textD = "";
    textE = "";
  }else if (trainCount == 0) {
    textA = "";
    textB = "모든 훈련을 ";
    textC = "이수완료 ";
    textD = "했습니다.";
    textE = "";

    colorB = Colors.grey.shade600;
    colorC = Colors.green;
    colorD = Colors.grey.shade600;
  } else if (trainCount > 0) {
    textA = "총 ";
    textB = "$trainCount";
    textC = "개의 훈련이 ";
    textD = "미이수";
    textE = " 상태입니다.";

    colorB = Colors.red;
    colorC = Colors.grey.shade600;
    colorD = Colors.red;
  }
}

//미이수 훈련 개수 찾기
Future<int> loadTrainCount() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/user/train/count');

  if (response.statusCode == 200) {
    return response.data;
  } else {
    throw Exception('fail');
  }
}

//////////////////////////////////////////////////////////////////////////

//훈련 카테고리 관련
late Future<void> loadCategoryTr;

List trainCategories = [];
String? selectedCategoryTr;

Future<void> initTr() async {

  final storage = FlutterSecureStorage();
  String? trainStorage = await storage.read(key: 'Category_Train');
  if (trainStorage == null || trainStorage == "") {
    trainCategories = ["전체", "화재", "응급", "지진", "생존", "전쟁", "수해", "기타"];
    await storage.write(
        key: 'Category_Train', value: jsonEncode(trainCategories));
  } else {
    trainCategories = jsonDecode(trainStorage!);
  }

  if (selectedCategoryTr == null || selectedCategoryTr == "") {
    selectedCategoryTr = trainCategories[0];
  } else {
    if (trainCategories.contains(selectedCategoryTr) == false) {
      selectedCategoryTr = trainCategories[0];
    }
  }
}

//////////////////////////////////////////////////////////////////////////

double appBarHeight = 70;
double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height - appBarHeight) * scale;
double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

class Score {
  final String name;
  final int totalScore;
  final int oldTotalScore;
  final int toolScore;
  final int oldToolScore;
  final int trainScore;
  final int oldTrainScore;

  Score({
    required this.name,
    required this.totalScore,
    required this.oldTotalScore,
    required this.toolScore,
    required this.oldToolScore,
    required this.trainScore,
    required this.oldTrainScore,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      name: json['name'],
      totalScore: json['totalScore'],
      oldTotalScore: json['oldTotalScore'],
      toolScore: json['toolScore'],
      oldToolScore: json['oldToolScore'],
      trainScore: json['trainScore'],
      oldTrainScore: json['oldTrainScore'],
    );
  }
}

class familyScore {
  final String name;
  final int totalScore;

  familyScore({
    required this.name,
    required this.totalScore,
  });

  factory familyScore.fromJson(Map<String, dynamic> json) {
    return familyScore(
      name: json['name'],
      totalScore: json['totalScore'],
    );
  }
}

Future<Score> loadScore() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/user/score');

  if (response.statusCode == 200) {
    return Score.fromJson(response.data);
  } else {
    throw Exception('Failed to Load');
  }
}

Future<List<familyScore>> loadFamilyScore() async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/family/score');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<familyScore> list =
        data.map((dynamic e) => familyScore.fromJson(e)).toList();

    return list;
  } else {
    throw Exception('Failed to Load');
  }
}

class importTool {
  String? toolId;
  String? mfd;
  String? exp;
  String? locate;
  String? name;
  String? toolExplain;
  String? maker;

  importTool(String? toolId, String? mfd, String? exp, String? locate,
      String? name, String? toolExplain, String? maker) {
    this.toolId = toolId;
    this.mfd = mfd;
    this.exp = exp;
    this.locate = locate;
    this.name = name;
    this.toolExplain = toolExplain;
    this.maker = maker;
  }
}

class checkTool {
  String? name;
  String? toolExplain;
  String? maker;

  checkTool({this.name, this.toolExplain, this.maker});

  factory checkTool.fromJson(Map<String, dynamic> json) {
    return checkTool(
      name: json['name'],
      toolExplain: json['toolExplain'],
      maker: json['maker'],
    );
  }
}

int? realTool;
int? realTrain;

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.changeIndex});
  final changeIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Future<Score> futureScore;
  late Future<List<familyScore>> futureFamilyScore;

  Future<void> initUniLinks() async {
    StreamSubscription _sub;

    _sub = linkStream.listen((String? link) {
      // Parse the link and warn the user, if it is not correct
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        if (initialLink.contains("entercode")) {
          // Parse the URL string
          Uri uri = Uri.parse(initialLink);
          // Get the query parameters as a map
          Map<String, String> queryParameters = uri.queryParameters;
          print(queryParameters);
          String? entercode = queryParameters['code'];
          print(entercode);
          Navigator.pushNamed(context, '/entercode', arguments: entercode);
        } else if (initialLink.contains("qr")) {
          Uri uri = Uri.parse(initialLink);
          // Get the query parameters as a map
          Map<String, dynamic> queryParameters = uri.queryParameters;
          print(queryParameters);
          String? toolId = queryParameters['toolId'];
          String? mfd = queryParameters['mfd'];
          String? exp = queryParameters['exp'];

          importTool tool =
              importTool(toolId, mfd, exp, null, null, null, null);
          print(tool);

          try {
            final storage = FlutterSecureStorage();
            final accessToken = await storage.read(key: 'ACCESS_TOKEN');
            var dio = await authDio();
            dio.options.headers['Authorization'] = '$accessToken';

            final response = await dio.get('/api/v1/tool/${tool.toolId}');

            if (response.statusCode == 200) {

              checkTool check = checkTool.fromJson(response.data);
              tool.name = check.name;
              tool.toolExplain = check.toolExplain;
              tool.maker = check.maker;

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => qrDefaultToolPage(
                            tool: tool,
                            count: 0,
                          ))).then((value) {});
            }
          } catch (e) {
            
          }
        }
      }
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }

  bool alarmstate = false;

  Future<bool> getNewAlarm() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'ACCESS_TOKEN');
    var dio = await authDio();
    dio.options.headers['Authorization'] = '$accessToken';
    final response = await dio.get('/api/v1/user/alarm/state');
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('fail');
    }
  }

  void _navigateToAlarmPage(BuildContext context) {
    // TODO: 더보기 페이지로 화면 전환
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmPage(),
      ),
    );
  }

  CheckAlarmState() async {
    alarmstate = await getNewAlarm();
    setState(() {
      alarmstate;
    });
    print(alarmstate);
  }

  @override
  void initState() {

    super.initState();
    initUniLinks();
    loadCategory = init();

    //
    //futureDefaultTool = loadDefaultTool();
    //futureCustomTool = loadCustomTool();

    //calculateDefaultTool = calculateDefaultToolCount();
    //calculateTrain = calculateTrainCount();

    //도구 불러오기
    //futureFireTools = loadFireTools();

    futureScore = loadScore();
    futureFamilyScore = loadFamilyScore();

    loadCategoryTr = initTr();

    //
    //futureTrainList = loadTrainList();

    CheckAlarmState();
    Future<Position> position = _getUserLocation();
    position.then((value) {
      if (value != null) {
        double latitude = value.latitude;
        double longitude = value.longitude;
        sendUserLocation(latitude, longitude);
        print("Latitude: $latitude, Longitude: $longitude");
      } else {
        print("Failed to get the position.");
      }
    }).catchError((error) {
      print("Error: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 250, 250, 250),
          colorSchemeSeed: Color.fromARGB(0, 241, 241, 241),
          useMaterial3: true),
      home: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              // futureDefaultTool = loadDefaultTool();
              // futureCustomTool = loadCustomTool();
              // futureScore = loadScore();
              // futureFamilyScore = loadFamilyScore();
              // loadCategoryTr = initTr();
              // futureTrainList = loadTrainList();
              // CheckAlarmState();
              // loadCategory;
              // alarmstate;
              // futureDefaultTool;
              // futureCustomTool;
              // futureScore;
              // futureFamilyScore;
              // loadCategoryTr;
              // futureTrainList;

              //calculateDefaultTool = calculateDefaultToolCount();
              //calculateTrain = calculateTrainCount();

              //새로고침 영역

              //도구
              //futureFireTools = loadFireTools();
            });
          },
          child: SafeArea(
            top: true,
            child: FutureBuilder<Score>(
                future: futureScore,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // 데이터를 아직 받아오는 중이면 로딩 표시를 보여줌
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError)
                    return Text('${snapshot.error}');
                  else if (snapshot.hasData) {
                    realTool = snapshot.data?.toolScore;
                    realTrain = snapshot.data?.trainScore;

                    return SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Container(
                                height: mediaHeight(context, 0.1),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset(
                                        'assets/image/eliblogo.png',
                                        width: mediaWidth(context, 0.15),
                                      ),
                                      alarmstate == false
                                          ? IconButton(
                                              icon: const Icon(
                                                  Icons
                                                      .notifications_none_outlined,
                                                  size: 30,
                                                  color: Color.fromRGBO(
                                                      66, 66, 66, 1)),
                                              onPressed: () {
                                                _navigateToAlarmPage(context);
                                                setState(() {
                                                  alarmstate = false;
                                                });
                                              },
                                            )
                                          : Stack(
                                              children: <Widget>[
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .notifications_none_outlined,
                                                      size: 30,
                                                      color: Color.fromRGBO(
                                                          66, 66, 66, 1)),
                                                  onPressed: () {
                                                    _navigateToAlarmPage(
                                                        context);
                                                    setState(() {
                                                      alarmstate = false;
                                                    });
                                                  },
                                                ),
                                                Positioned(
                                                  right: 10,
                                                  top: 10,
                                                  child: Container(
                                                    padding: EdgeInsets.all(1),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    constraints: BoxConstraints(
                                                      minWidth: 12,
                                                      minHeight: 12,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                      // : Stack(
                                      //   children: [
                                      //     IconButton(
                                      //   icon: const Icon(
                                      //       Icons.notifications_none_outlined,
                                      //       size: 30,
                                      //       color: Color.fromRGBO(66, 66, 66, 1)),
                                      //   onPressed: () {},
                                      // ),

                                      //   ],
                                      // )
                                    ])),
                          ),
                          //SizedBox(height: mediaHeight(context, 0.03)),

                          Column(
                            children: [
                              //그래프
                              SafetyScoreBox(
                                totalScore: snapshot.data?.totalScore,
                                oldTotalScore: snapshot.data?.oldTotalScore,
                                name: snapshot.data?.name,
                              ),

                              ToolScoreBox(
                                toolScore: snapshot.data?.toolScore,
                                oldToolScore: snapshot.data?.oldToolScore,
                                changeIndex: widget.changeIndex,
                              ),

                              //SizedBox(height: mediaHeight(context, 0.03)),

                              TrainingScoreBox(
                                trainScore: snapshot.data?.trainScore,
                                oldTrainScore: snapshot.data?.oldTrainScore,
                                changeIndex: widget.changeIndex,
                              ),

                              SizedBox(height: mediaHeight(context, 0.05)),

                              ToolBox(
                                changeIndex: widget.changeIndex,
                              ),

                              SizedBox(height: mediaHeight(context, 0.05)),

                              TrainBox(
                                changeIndex: widget.changeIndex,
                              ),

                              SizedBox(height: mediaHeight(context, 0.05)),

                              FutureBuilder<List<familyScore>>(
                                  future: futureFamilyScore,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError)
                                      return Text('${snapshot.error}');
                                    else if (snapshot.hasData) {
                                      return FamilyScoreBox(
                                        list: snapshot.data,
                                        changeIndex: widget.changeIndex,
                                      );
                                    } else
                                      return Visibility(
                                          visible: false,
                                          child: CircularProgressIndicator());
                                  }),

                              SizedBox(height: mediaHeight(context, 0.02)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return Visibility(
                      visible: false, child: CircularProgressIndicator());
                }),
          ),
        ),
        //bottomNavigationBar: BulidBottomAppBar()
      ),
    );
  }
}

String toolText = "";

class ToolScoreBox extends StatefulWidget {
  const ToolScoreBox({
    Key? key,
    required this.toolScore,
    required this.oldToolScore,
    this.changeIndex,
  }) : super(key: key);

  final toolScore;
  final oldToolScore;
  final changeIndex;

  @override
  State<ToolScoreBox> createState() => _ToolScoreBoxState();
}

class _ToolScoreBoxState extends State<ToolScoreBox>
    with TickerProviderStateMixin {
  double percentage = 0.0;
  double newPercentage = 0.0;
  double gapPercentage = 0.0;
  double newgapPercentage = 0.0;
  int toolScore = 0;

  late AnimationController percentageAnimationController;

  void initState() {
    super.initState();

    percentageAnimationController = AnimationController(
        vsync: this, duration: new Duration(milliseconds: 10000))
      ..addListener(() {
        setState(() {
          percentage = lerpDouble(
              percentage, newPercentage, percentageAnimationController.value)!;
          gapPercentage = lerpDouble(gapPercentage, newgapPercentage,
              percentageAnimationController.value)!;
        });
      });

    setState(() {
      percentage = newPercentage;
      newPercentage = (widget.toolScore) / 100;
      toolScore = widget.toolScore;

      double gap = 0.0;
      if (widget.toolScore > widget.oldToolScore) {
        gap = widget.toolScore.toDouble() - widget.oldToolScore.toDouble();
      } else {
        gap = widget.oldToolScore.toDouble() - widget.toolScore.toDouble();
      }
      gapPercentage = newgapPercentage;
      newgapPercentage = gap / 100;
      percentageAnimationController.forward();
    });
  }

  @override
  dispose() {
    percentageAnimationController.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int toolColor;
    if (widget.toolScore < 35) {
      toolColor = 0xFFF16969; //pink
    } else if (widget.toolScore < 70) {
      toolColor = 0xFF6A9DFF; //blue
    } else {
      toolColor = 0xFF4CAF50; //green
    }

    int? gap;
    int gapColor;
    String gapIcon;
    double iconFont = 19;
    String? gapNum;
    String? text;

    if (widget.toolScore == widget.oldToolScore) {
      gap = 0;
      gapNum = "";
      gapIcon = "";
      iconFont = 30;
      gapColor = 0xFF9E9E9E; //grey
      toolText = "변동 없음";
      text = "변동 없음";
    } else if (widget.toolScore > widget.oldToolScore) {
      gap = widget.toolScore - widget.oldToolScore;
      gapNum = "";
      gapIcon = "▲";
      gapColor = 0xFF4CAF50; //green
      toolText = "$gap점 상승";
      text = " 상승";
    } else {
      gap = widget.oldToolScore - widget.toolScore;
      gapNum = "";
      gapIcon = "▼";
      gapColor = 0xFFF16969; //pink
      toolText = "$gap점 하락";
      text = " 하락";
    }

    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            widget.changeIndex(0);
          },
          child: Container(
              height: 80,
              width: mediaWidth(context, 0.9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Stack(children: [
                            Positioned(
                                child: Container(
                                    width: 300,
                                    height: 70,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 70,
                                        ),
                                        Container(
                                            width: 250,
                                            height: 60,
                                            decoration: BoxDecoration(
                                                color: Color(safetyColor),
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(30),
                                                    bottomRight:
                                                        Radius.circular(30))),
                                            child: Container(
                                                width: 230,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '재난대비 도구 점수 변동',
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(gapIcon,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              PercentScore(
                                                                  percent:
                                                                      gapPercentage,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      20.0,
                                                                  width: 35.0),
                                                            ],
                                                          ),

                                                          // 00
                                                        ],
                                                      )
                                                    ])))
                                      ],
                                    ))),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Color(safetyColor), width: 1.5),
                                borderRadius: BorderRadius.circular(20),
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
                              child: Icon(
                                Icons.construction,
                                color: Colors.grey.shade400,
                                size: 40,
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    
                  ]),
                ],
              )),
        ),
      ],
    ));
  }
}

String trainText = "";

class TrainingScoreBox extends StatefulWidget {
  const TrainingScoreBox({
    Key? key,
    required this.trainScore,
    required this.oldTrainScore,
    this.changeIndex,
  }) : super(key: key);

  final trainScore;
  final oldTrainScore;
  final changeIndex;

  @override
  State<TrainingScoreBox> createState() => _TrainingScoreBoxState();
}

class _TrainingScoreBoxState extends State<TrainingScoreBox>
    with TickerProviderStateMixin {
  double percentage = 0.0;
  double newPercentage = 0.0;
  double gapPercentage = 0.0;
  double newgapPercentage = 0.0;
  int trainScore = 0;

  late AnimationController percentageAnimationController;

  void initState() {
    super.initState();

    percentageAnimationController = AnimationController(
        vsync: this, duration: new Duration(milliseconds: 10000))
      ..addListener(() {
        setState(() {
          percentage = lerpDouble(
              percentage, newPercentage, percentageAnimationController.value)!;
          gapPercentage = lerpDouble(gapPercentage, newgapPercentage,
              percentageAnimationController.value)!;
        });
      });

    setState(() {
      percentage = newPercentage;
      newPercentage = (widget.trainScore) / 100;
      trainScore = widget.trainScore;

      double gap = 0.0;
      if (widget.trainScore > widget.oldTrainScore) {
        gap = widget.trainScore.toDouble() - widget.oldTrainScore.toDouble();
      } else {
        gap = widget.oldTrainScore.toDouble() - widget.trainScore.toDouble();
      }
      gapPercentage = newgapPercentage;
      newgapPercentage = gap / 100;
      percentageAnimationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    int trainColor;
    if (widget.trainScore < 35) {
      trainColor = 0xFFF16969; //pink
    } else if (widget.trainScore < 70) {
      trainColor = 0xFF6A9DFF; //blue
    } else {
      trainColor = 0xFF4CAF50; //green
    }

    int? gap;
    int gapColor;
    String gapIcon;
    double iconFont = 19;
    String? gapNum;
    String? text;

    if (widget.trainScore == widget.oldTrainScore) {
      gap = 0;
      gapNum = "";
      gapIcon = "";
      iconFont = 30;
      gapColor = 0xFF9E9E9E; //grey
      trainText = "변동 없음";
      text = "변동 없음";
    } else if (widget.trainScore > widget.oldTrainScore) {
      gap = widget.trainScore - widget.oldTrainScore;
      gapNum = "";
      gapIcon = "▲";
      gapColor = 0xFF4CAF50; //green
      trainText = "$gap점 상승";
      text = " 상승";
    } else {
      gap = widget.oldTrainScore - widget.trainScore;
      gapNum = "";
      gapIcon = "▼";
      gapColor = 0xFFF16969; //pink
      trainText = "$gap점 하락";
      text = " 하락";
    }

    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            widget.changeIndex(1);
          },
          child: Container(
              width: mediaWidth(context, 0.9),
              height: 80,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Stack(
                        children: [
                          Container(
                              width: 300,
                              height: 70,
                              child: Row(
                                children: [
                                  Container(
                                      width: 250,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          color: Color(safetyColor),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(30),
                                              bottomLeft: Radius.circular(30))),
                                      child: Container(
                                          width: 230,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '재난대비 훈련 점수 변동',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(gapIcon,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      PercentScore(
                                                          percent:
                                                              gapPercentage,
                                                          color: Colors.white,
                                                          fontSize: 20.0,
                                                          width: 35.0),
                                                    ],
                                                  ),

                                                  //  Row(
                                                  //    children: [
                                                  //      Text('${trainScore}점',
                                                  //         style: TextStyle(
                                                  //           color: Colors.white,
                                                  //           fontSize: 17,
                                                  //           )),
                                                  //     ]
                                                  //   )
                                                ],
                                              )
                                            ],
                                          ))),
                                  Container(
                                    width: 50,
                                    height: 70,
                                  )
                                ],
                              )),
                          Positioned(
                            right: 0,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Color(safetyColor), width: 1.5),
                                borderRadius: BorderRadius.circular(20),
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
                              child: Icon(
                                Icons.edit_document,
                                color: Colors.grey.shade400,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ])),
        ),
      ],
    ));
  }
}

class FamilyScoreBox extends StatelessWidget {
  const FamilyScoreBox({
    Key? key,
    required this.list,
    this.changeIndex,
  }) : super(key: key);

  final List<familyScore>? list;
  final changeIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7.0,
                offset: Offset(2, 5), // changes position of shadow
              ),
            ],
          ),
          width: mediaWidth(context, 0.95),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, bottom: 20),
                child: Text('구성원 안전 현황',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "homepagePoint",
                    )),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list?.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, i) {
                  int scoreColor;
                  int? score = list?[i].totalScore;
                  String scoreText;

                  if (score != null && score < 35) {
                    scoreColor = 0xFFF16969; //pink
                    scoreText = "위험";
                  } else if (score != null && score < 70) {
                    scoreColor = 0xFF6A9DFF; //blue
                    scoreText = "보통";
                  } else {
                    scoreColor = 0xFF4CAF50; //green
                    scoreText = "안전";
                  }

                  double last = 0;

                  if (i < list!.length - 1) {
                    last = 7;
                  } else {
                    last = 20;
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 35),
                        child: InkWell(
                          onTap: () {
                            changeIndex(3);
                          },
                          child: Container(
                            height: 32,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: Colors.yellow,
                                          shape: BoxShape.circle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text('${list?[i].name}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                  ],
                                ),
                                Text('${scoreText}',
                                    style: TextStyle(
                                      color: Color(scoreColor),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Container(
                          color: Colors.grey.shade400,
                          height: 2,
                        ),
                      ),
                      SizedBox(height: last),
                    ],
                  );
                },
              ),
            ],
          ),
        )
      ],
    ));
  }
}

class SafetyScoreBox extends StatefulWidget {
  const SafetyScoreBox({
    Key? key,
    required this.totalScore,
    required this.oldTotalScore,
    required this.name,
  }) : super(key: key);

  final totalScore;
  final oldTotalScore;
  final name;

  @override
  State<SafetyScoreBox> createState() => _SafetyScoreBoxState();
}

class _SafetyScoreBoxState extends State<SafetyScoreBox>
    with TickerProviderStateMixin {
  double percentage = 0.0;
  double newPercentage = 0.0;

  late AnimationController percentageAnimationController;

  void initState() {
    super.initState();

    percentageAnimationController = AnimationController(
        vsync: this, duration: new Duration(milliseconds: 10000))
      ..addListener(() {
        setState(() {
          percentage = lerpDouble(
              percentage, newPercentage, percentageAnimationController.value)!;
        });
      });

    setState(() {
      percentage = newPercentage;
      newPercentage = (widget.totalScore) / 100;
      percentageAnimationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalScore = widget.totalScore;
    int oldTotalScore = widget.oldTotalScore;
    String image = "assets/image/firefighter.png";

    String safetyText;
    if (totalScore < 35) {
      safetyColor = 0xFFF16969; //pink
      safetyText = 'Bad';
      image = "assets/image/firefighterBad.png";
    } else if (totalScore < 70) {
      safetyColor = 0xFF6A9DFF; //blue
      safetyText = 'Soso';
      image = "assets/image/firefighterSoso.png";
    } else {
      safetyColor = 0xFF4CAF50; //green
      safetyText = 'Good';
      image = "assets/image/firefighterGood.png";
    }

    String text;
    if (oldTotalScore < totalScore) {
      text = "점수가 상승했습니다.";
    } else if (oldTotalScore > totalScore) {
      text = "점수가 하락했습니다.";
    } else {
      text = "점수를 유지 중입니다.";
    }

    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.name} 님',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade600,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: mediaHeight(context, 0.01)),
                    Text(
                      '오늘의 우리집 안전점수는',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                PercentScore(
                  percent: percentage,
                  color: Color(safetyColor),
                  fontSize: 50.0,
                  width: 50.0,
                ),
              ],
            ),
          ),

          SizedBox(height: mediaHeight(context, 0.03)),

          SizedBox(
            height: mediaWidth(context, 0.8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(children: [
                  Positioned(
                    left: mediaWidth(context, 0.25),
                    top: mediaWidth(context, 0.18),
                    child: Image.asset(
                      image,
                      width: mediaWidth(context, 0.35),
                    ),
                  ),
                  PercentDonut(percent: percentage, color: Color(safetyColor)),
                ]),
              ],
            ),
          ),

          SizedBox(height: mediaHeight(context, 0.01)),

          SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Text(
                        '재난대비 도구 점수  ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${realTool}점',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '재난대비 훈련 점수  ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${realTrain}점',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  )
                ],
              )),

          SizedBox(height: mediaHeight(context, 0.03)),
        ],
      ),
    );
  }
}

class ToolBox extends StatelessWidget {
  const ToolBox({
    Key? key,
    this.changeIndex,
  }) : super(key: key);

  final changeIndex;

  @override
  Widget build(BuildContext context) {
    List toolCategories6 = ["화재", "응급", "지진", "생존", "전쟁", "수해"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [

        Container(
          width: mediaWidth(context, 0.95),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7.0,
                offset: Offset(2, 5), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, bottom: 20),
                  child: Text(
                    '보유 재난 키트 현황',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "homepagePoint",
                    ),
                  ),
                ),
              ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: toolCategories6.length,
                itemBuilder: (BuildContext ctx, int idx) {
                  String category = toolCategories6[idx];
                  // List<int> toolItemCount = [
                  //   fireCount,
                  //   emergentCount,
                  //   quakeCount,
                  //   surviveCount,
                  //   warCount,
                  //   floodCount,
                  // ];

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, top: 0.5, bottom: 0.5),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                category + " 용품",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Expanded(
                            //   child: Align(
                            //     alignment: Alignment.centerRight,
                            //     child: Text(
                            //       "${toolItemCount[idx]} 개",
                            //       style: TextStyle(
                            //         fontSize: 15,
                            //         color: Colors.grey,
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<defaultTool>>(
                        //future속성에서 함수 직접 호출
                        future: loadDefaultToolByType(category),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return MySkeletonList();
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else {
                            List<defaultTool>? tools = snapshot.data;

                            if (tools != null && tools.isNotEmpty) {
                              
                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: tools.length,
                                itemBuilder: (BuildContext ctx, int idx) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, right: 20, top: 1, bottom: 1),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                  color: Colors.amber, shape: BoxShape.circle),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 5.0),
                                              child: Text(
                                                tools[idx].name ?? "",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        Divider(
                                          color: Colors.grey[300],
                                          thickness: 1,
                                          indent: 5,
                                          endIndent: 5,
                                        )
                                      ],
                                    ),
                                  );
                                  // 도구의 다른 정보들을 출력하는 부분을 추가하면 됨
                                },
                              );
                            } else {
                              return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, right: 20, top: 1, bottom: 1),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 5.0),
                                              child: Text(
                                                "등록된 물품 없음",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        Divider(
                                          color: Colors.grey[300],
                                          thickness: 1,
                                          indent: 5,
                                          endIndent: 5,
                                        )
                                      ],
                                    ),
                                  );
                            }
                          }
                        },
                      ),
                      // Divider(
                      //   thickness: 2,
                      //   indent: 20,
                      //   endIndent: 20,
                      // )
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );

  }
}

//스켈레톤
class MySkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.white,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 1, // 적절한 개수로 설정
        itemBuilder: (BuildContext ctx, int idx) {
          return ListTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(50)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TrainBox extends StatelessWidget {
  const TrainBox({
    Key? key,
    this.changeIndex,
  }) : super(key: key);

  final changeIndex;

  @override
  Widget build(BuildContext context) {
    List toolCategories7 = ["화재", "응급", "지진", "생존", "전쟁", "수해", "기타"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [

        Container(
          width: mediaWidth(context, 0.95),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7.0,
                offset: Offset(2, 5), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, bottom: 20),
                  child: Text(
                    '훈련 이수 현황',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "homepagePoint",
                    ),
                  ),
                ),
              ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: toolCategories7.length,
                itemBuilder: (BuildContext ctx, int idx) {
                  String category = toolCategories7[idx];

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, top: 0.5, bottom: 0.5),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 0,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      FutureBuilder<List<trainList>>(
                        //future속성에서 함수 직접 호출
                        future: loadDefaultTrainByType(category),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return MySkeletonList();
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else {
                            List<trainList>? trains = snapshot.data;

                            if (trains != null && trains.isNotEmpty) {

                              //이수 완료 조건
                              var completedTrainCount = trains.where((train)
                                  => train.videoComplete == true && train.imgComplete == true).length;
                              //백분율
                              var completionPercentage = (completedTrainCount / trains.length * 100).round();

                              return Padding(
                                padding: const EdgeInsets.only(
                                        left: 20.0, right: 20, top: 0.5, bottom: 0.5),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                  color: Colors.amber, shape: BoxShape.circle),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 5.0),
                                              child: Text(
                                                category,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                              
                                        Text(
                                              "$completedTrainCount / ${trains.length} , $completionPercentage%",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "homepagePoint",
                                              ),
                                        ),
                                      ],
                                    ),
                              
                                    Divider(
                                      color: Colors.grey[300],
                                      thickness: 1,
                                      indent: 5,
                                      endIndent: 5,
                                    )
                                ]
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(
                                        left: 20.0, right: 20, top: 0.5, bottom: 0.5),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                  color: Colors.amber, shape: BoxShape.circle),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 5.0),
                                              child: Text(
                                                category,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                              
                                        Text(
                                              "0 / 0 , 0%",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "homepagePoint",
                                              ),
                                        ),
                                      ],
                                    ),
                              
                                    Divider(
                                      color: Colors.grey[300],
                                      thickness: 1,
                                      indent: 5,
                                      endIndent: 5,
                                    )
                                ]
                                ),
                              );
                            }
                          }
                        },
                      ),
                      // Divider(
                      //   thickness: 2,
                      //   indent: 20,
                      //   endIndent: 20,
                      // )
                    ],
                  );
                },
              ),
            ],
          ),
        )
        
        // Container(
        //   width: mediaWidth(context, 0.95),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     border: Border.all(color: Colors.grey.shade400, width: 1.5),
        //     borderRadius: BorderRadius.circular(20),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.grey.withOpacity(0.5),
        //         spreadRadius: 2,
        //         blurRadius: 7.0,
        //         offset: Offset(2, 5), // changes position of shadow
        //       ),
        //     ],
        //   ),
        //   child: Container(
        //     height: 350,
        //     child:
        //         Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //       Padding(
        //         padding: const EdgeInsets.only(top: 20, left: 20, bottom: 20),
        //         child: Text(
        //           '훈련 이수 현황',
        //           style: TextStyle(
        //               fontSize: 20,
        //               color: Colors.grey.shade600,
        //               fontWeight: FontWeight.bold),
        //         ),
        //       ),
        //       Expanded(
        //         child: ListView.builder(
        //           physics: const NeverScrollableScrollPhysics(),
        //           itemCount: 7,
        //           itemBuilder: (BuildContext ctx, int idx) {
        //             List<int> trainItemCount = [
        //               fireCheckedTr,
        //               emergentCheckedTr,
        //               quakeCheckedTr,
        //               surviveCheckedTr,
        //               warCheckedTr,
        //               floodCheckedTr,
        //               etcCheckedTr,
        //             ];
        //             List<int> trainAllCount = [
        //               fireCountTr,
        //               emergentCountTr,
        //               quakeCountTr,
        //               surviveCountTr,
        //               warCountTr,
        //               floodCountTr,
        //               etcCountTr,
        //             ];
        //             List<int> trainPercent = [
        //               fireCountTrCk,
        //               emergentCountTrCk,
        //               quakeCountTrCk,
        //               surviveCountTrCk,
        //               warCountTrCk,
        //               floodCountTrCk,
        //               etcCountTrCk,
        //             ];

        //             return Column(
        //               children: [
        //                 Padding(
        //                   padding: const EdgeInsets.only(
        //                       left: 20.0, right: 20, top: 1, bottom: 1),
        //                   child: Row(
        //                     children: [
        //                       Container(
        //                         width: 10,
        //                         height: 10,
        //                         decoration: BoxDecoration(
        //                             color: Colors.lime, shape: BoxShape.circle),
        //                       ),
        //                       Padding(
        //                         padding: const EdgeInsets.only(left: 5.0),
        //                         child: Text(
        //                           trainCategories[idx + 1],
        //                           style: TextStyle(
        //                             fontSize: 15,
        //                             color: Colors.grey,
        //                             fontWeight: FontWeight.bold,
        //                           ),
        //                         ),
        //                       ),
        //                       Expanded(
        //                         child: Align(
        //                           alignment: Alignment.centerRight,
        //                           child: Row(
        //                             mainAxisAlignment: MainAxisAlignment.end,
        //                             children: [
        //                               Text(
        //                                 "${trainItemCount[idx]}",
        //                                 style: TextStyle(
        //                                   fontSize: 15,
        //                                   color: Colors.grey,
        //                                   fontWeight: FontWeight.bold,
        //                                 ),
        //                               ),
        //                               Text(
        //                                 " / ",
        //                                 style: TextStyle(
        //                                   fontSize: 15,
        //                                   color: Colors.grey,
        //                                   fontWeight: FontWeight.bold,
        //                                 ),
        //                               ),
        //                               Text(
        //                                 "${trainAllCount[idx]}",
        //                                 style: TextStyle(
        //                                   fontSize: 15,
        //                                   color: Colors.grey,
        //                                   fontWeight: FontWeight.bold,
        //                                 ),
        //                               ),
        //                               Text(
        //                                 " ,  ",
        //                                 style: TextStyle(
        //                                   fontSize: 15,
        //                                   color: Colors.grey,
        //                                   fontWeight: FontWeight.bold,
        //                                 ),
        //                               ),
        //                               Text(
        //                                 "${trainPercent[idx]}%",
        //                                 style: TextStyle(
        //                                   fontSize: 15,
        //                                   color: Colors.grey,
        //                                   fontWeight: FontWeight.bold,
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //                 Divider(
        //                   thickness: 2,
        //                   indent: 20,
        //                   endIndent: 20,
        //                 )
        //               ],
        //             );
        //           },
        //         ),
        //       )
        //     ]),
        //   ),
        // ),

      ],
    );
  }
}

//floating border
class PercentDonut extends StatelessWidget {
  const PercentDonut({Key? key, required this.percent, required this.color})
      : super(key: key);
  final percent;
  final color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mediaWidth(context, 0.8),
      height: mediaWidth(context, 0.8),
      child: CustomPaint(
        // CustomPaint를 그리고 이 안에 차트를 그려줍니다..
        painter: PercentDonutPaint(
          percentage: percent, // 파이 차트가 얼마나 칠해져 있는지 정하는 변수입니다.
          activeColor: color, //색
        ),
      ),
    );
  }
}

////////
class PercentDonutPaint extends CustomPainter {
  double percentage;
  double textScaleFactor = 1.0; // 파이 차트에 들어갈 텍스트 크기를 정합니다.
  Color activeColor;
  PercentDonutPaint({required this.percentage, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint() // 화면에 그릴 때 쓸 Paint를 정의합니다.
      ..color = Color(0xfff3f3f3)
      ..strokeWidth = 35.0 // 선의 길이를 정합니다.
      ..style =
          PaintingStyle.stroke // 선의 스타일을 정합니다. stroke면 외곽선만 그리고, fill이면 다 채웁니다.
      ..strokeCap =
          StrokeCap.round; // stroke의 스타일을 정합니다. round를 고르면 stroke의 끝이 둥글게 됩니다.
    double radius = min(
        size.width / 2 - paint.strokeWidth / 2,
        size.height / 2 -
            paint.strokeWidth / 2); // 원의 반지름을 구함. 선의 굵기에 영향을 받지 않게 보정함.
    Offset center =
        Offset(size.width / 2, size.height / 2); // 원이 위젯의 가운데에 그려지게 좌표를 정함.
    canvas.drawCircle(center, radius, paint); // 원을 그림.
    double arcAngle = 2 * pi * percentage; // 호(arc)의 각도를 정함. 정해진 각도만큼만 그리도록 함.
    paint.color = activeColor; // 호를 그릴 때는 색을 바꿔줌.
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, paint); // 호(arc)를 그림.
  }

  // 화면 크기에 비례하도록 텍스트 폰트 크기를 정함.
  double getFontSize(Size size, String text) {
    return size.width / text.length * textScaleFactor;
  }

  @override
  bool shouldRepaint(PercentDonutPaint oldDelegate) {
    return true;
  }
}

class PercentScore extends StatelessWidget {
  const PercentScore(
      {Key? key,
      required this.percent,
      required this.color,
      required this.fontSize,
      required this.width})
      : super(key: key);
  final percent;
  final color;
  final fontSize;
  final width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      child: CustomPaint(
        painter: PercentScorePaint(
          percentage: percent,
          activeColor: color,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class PercentScorePaint extends CustomPainter {
  double percentage;
  Color activeColor;
  double fontSize;
  PercentScorePaint(
      {required this.percentage,
      required this.activeColor,
      required this.fontSize});

  @override
  void paint(Canvas canvas, Size size) {
    drawText(canvas, size, "${(percentage * 100).round()}");
  }

  // 원의 중앙에 텍스트를 적음.
  void drawText(Canvas canvas, Size size, String text) {
    TextSpan sp = TextSpan(
      children: [
        TextSpan(
            text: "${text}",
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: activeColor)),
      ],
    ); // TextSpan은 Text위젯과 거의 동일하다.
    TextPainter tp = TextPainter(text: sp, textDirection: TextDirection.ltr);

    tp.layout(); // 필수! 텍스트 페인터에 그려질 텍스트의 크기와 방향를 정함.
    double dx = size.width / 2 - tp.width / 2;
    double dy = size.height / 2 - tp.height / 2;

    Offset offset = Offset(dx, dy);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(PercentScorePaint oldDelegate) {
    return true;
  }
}

// 위치정보 받아오는 함수 구현
Future<Position> _getUserLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

Future<void> sendUserLocation(double lat, double lon) async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio
      .patch('/api/v1/user/locate', queryParameters: {'lat': lat, 'lon': lon});

  if (response.statusCode == 200) {

  } else {
    throw Exception('fail');
  }
}
