import "dart:convert";
import "package:async/async.dart";
import "package:elib_project/pages/alarm_page.dart";
import "package:elib_project/pages/edit_family_name.dart";
import "package:elib_project/pages/enter_code_page.dart";
import "package:elib_project/pages/group_add_page.dart";
import "package:elib_project/pages/member_info_page.dart";
import "package:elib_project/pages/member_invite_page.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:flutter/material.dart";
import "package:kakao_flutter_sdk/kakao_flutter_sdk_share.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../auth_dio.dart";
import "../models/bottom_app_bar.dart";
import 'package:indexed/indexed.dart';

class GlobalData {
  static double queryWidth = 0.0;
  static double queryHeight = 0.0;
}

class MemberManagementPage extends StatefulWidget {
  const MemberManagementPage({
    Key? key,
  }) : super(key: key);

  @override
  _MemberManagementPageState createState() => _MemberManagementPageState();
}

class _MemberManagementPageState extends State<MemberManagementPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _navigateToAddGroupPage() {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => GroupAddPage()))
        .then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    GlobalData.queryHeight = MediaQuery.of(context).size.height;
    GlobalData.queryWidth = MediaQuery.of(context).size.width;
    // 여기에 위젯을 구성하는 코드를 작성합니다.
    // 예: Scaffold, Column, ListView 등을 사용하여 화면을 구성합니다.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 250, 250, 250),
          colorSchemeSeed: const Color.fromARGB(0, 241, 241, 241),
          useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: const Color.fromARGB(255, 250, 250, 250),
          title: Title(
              color: const Color.fromRGBO(87, 87, 87, 1),
              child: const Text(
                "구성원관리",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              )),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: () async {
                    _navigateToAddGroupPage();
                  },
                  child: Text(
                    "그룹추가",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                )),
            // IconButton(
            //   icon: const Icon(Icons.notifications_none),
            //   onPressed: () {
            //     _navigateToAlarmPage(context);
            //   },
            // ),
          ],
        ),
        body: SafeArea(
            child: Column(
          children: [
            Expanded(
                child: Stack(children: [
              VerticalTabBarLayout(
                  navigateToAddGroupPage: _navigateToAddGroupPage),
              Positioned(
                right: 20,
                bottom: 10,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  width: 60,
                  height: 60,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 40,
                      ),
                      color: Colors.white,
                      onPressed: () {
                        _showBottomSheet();
                      },
                    ),
                  ),
                ),
              ),
            ])),
          ],
        )),
        extendBodyBehindAppBar: true, // AppBar가 배경 이미지를 가리지 않도록 설정
      ),
    );
  }

  _showBottomSheet() async {
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
                      "초대",
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
            InkWell(
              onTap: () {
                _navigateToInvitePage(context);
              },
              child: const SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Icon(
                        Icons.send,
                        size: 30,
                        color: Colors.lightBlue,
                      ),
                    ),
                    Text(
                      '전화번호로 구성원 초대',
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
                int templateId = 97413;
                String code = await creatInviteCode();
                String url = "http://test.elibtest.r-e.kr:8080";
                // final defaultText = await texttemplate();
                bool isKakaoTalkSharingAvailable =
                    await ShareClient.instance.isKakaoTalkSharingAvailable();
                if (isKakaoTalkSharingAvailable) {
                  try {
                    Uri uri = await ShareClient.instance.shareScrap(
                        templateId: templateId,
                        url: url,
                        templateArgs: {'code': code});
                    await ShareClient.instance.launchKakaoTalk(uri);
                    print('카카오톡 공유 완료');
                  } catch (error) {
                    print('카카오톡 공유 실패 $error');
                  }
                } else {
                  try {
                    Uri shareUrl = await WebSharerClient.instance.makeScrapUrl(
                        url: url,
                        templateId: templateId,
                        templateArgs: {'code': code});
                    await launchBrowserTab(shareUrl, popupOpen: true);
                  } catch (error) {
                    print('카카오톡 공유 실패 $error');
                  }
                }
              },
              child: Container(
                height: 50,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Image.asset(
                        'assets/image/talkicon.png',
                        width: 30,
                      ),
                    ),
                    const Text(
                      '카카오톡으로 구성원 초대',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 3,
            ),
            InkWell(
              onTap: () {
                _navigateToEnterCodePage(context);
              },
              child: Container(
                height: 50,
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Icon(Icons.add_box_outlined,
                          size: 30, color: Colors.green),
                    ),
                    Text(
                      '초대코드 입력',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

_showBottomViewSheet(BuildContext context) async {
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
                    "조회",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              onTap: () {
                Navigator.pop(context, 1);
              },
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10),
                    child: Icon(
                      Icons.list,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '간략히 보기',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: InkWell(
              onTap: () {
                Navigator.pop(context, 2);
              },
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10),
                    child: Icon(
                      Icons.menu,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '상세히 보기',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
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

_showBottomSortSheet(BuildContext context) async {
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
                    "정렬",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              onTap: () {
                Navigator.pop(context, 1);
              },
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10),
                    child: Icon(
                      Icons.calendar_month,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '등록일순',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: InkWell(
              onTap: () {
                Navigator.pop(context, 2);
              },
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10),
                    child: Icon(
                      Icons.abc,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '이름순',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
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

_showBottomGroupSheet(BuildContext context) {
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
                    "관리",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              onTap: () {
                Navigator.pop(context, 1);
              },
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10),
                    child: Icon(
                      Icons.list,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '그룹 추가하기',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: InkWell(
              onTap: () {
                Navigator.pop(context, 2);
              },
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10),
                    child: Icon(
                      Icons.menu,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '그룹 삭제하기',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
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

class ListBuild extends StatefulWidget {
  @override
  _ListBuildState createState() => _ListBuildState();
}

class _ListBuildState extends State<ListBuild>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  AsyncMemoizer<List<familyName>> _memoizer_family = AsyncMemoizer();
  int sorttype = 1;
  int viewtype = 1;
  String selectedSort = "등록일순";
  String selectedView = "간단히 보기";
  late List<familyName> entries;
  late SharedPreferences prefs;

  Future<void> recacheEntries() async {
    _memoizer_family = AsyncMemoizer(); // 다시 초기화
  }

  Future<List<familyName>> getEntries(bool type) async {
    return this._memoizer_family.runOnce(() async {
      List<familyName> entries = await loadFamilyInfo();
      return entries;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    return this._memoizer.runOnce(() async {
      prefs = await SharedPreferences.getInstance();
      if (prefs.getInt('sorttype') != null &&
          prefs.getInt('viewtype') != null) {
        sorttype = prefs.getInt('sorttype')!;
        viewtype = prefs.getInt('viewtype')!;
        if (sorttype == 1) {
          selectedSort = "등록일순";
        } else {
          selectedSort = "이름순";
        }

        if (viewtype == 1) {
          selectedView = "간단히 보기";
        } else {
          selectedView = "상세히 보기";
        }
      }
    });
  }

  // Define a callback function to update selectedSort
  void updateSelectedSort(String newSort, StateSetter setState, int sortnum) {
    setState(() {
      selectedSort = newSort;
      sorttype = sortnum;
    });
    prefs.setInt('sorttype', sortnum);
  }

  void updateSelectedView(String viewtext, StateSetter setState, int viewnum) {
    setState(() {
      selectedView = viewtext;
      viewtype = viewnum;
    });
    prefs.setInt('viewtype', viewnum);
  }

  // Define your updateSelectedSort and updateSelectedView functions here

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: RefreshIndicator(
      onRefresh: () async {
        recacheEntries();
        setState(() {
          _memoizer_family;
        });
      },
      child: FutureBuilder<List<familyName>>(
        future: getEntries(true), // entries를 얻기 위해 Future를 전달
        builder:
            (BuildContext context, AsyncSnapshot<List<familyName>> snapshot) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 데이터를 아직 받아오는 중이면 로딩 표시를 보여줌
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // 데이터를 받아오는 도중 에러가 발생하면 에러 메시지를 보여줌
                return Text('Error: ${snapshot.error}');
              } else {
                // 데이터를 정상적으로 받아왔을 경우
                entries = snapshot.data!; // 해결된 데이터를 얻음
                if (sorttype == 1) {
                  entries.sort((a, b) => a.id.compareTo(b.id));
                } else if (sorttype == 2) {
                  entries.sort((a, b) => a.name.compareTo(b.name));
                }
                return Container(
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 20),
                              ),
                              onPressed: () async {
                                final result =
                                    await _showBottomSortSheet(context);
                                if (result == 1) {
                                  updateSelectedSort("등록일순", setState, 1);
                                } else if (result == 2) {
                                  updateSelectedSort("이름순", setState, 2);
                                }
                              },
                              child: Row(
                                children: [
                                  Text(
                                    selectedSort,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Icon(
                                    Icons.swap_vert,
                                    size: 25,
                                  ),
                                ],
                              )),
                          TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 20),
                              ),
                              onPressed: () async {
                                final result =
                                    await _showBottomViewSheet(context);
                                if (result == 1) {
                                  updateSelectedView("간단히 보기", setState, 1);
                                } else if (result == 2) {
                                  updateSelectedView("상세히 보기", setState, 2);
                                }
                              },
                              child: Row(
                                children: [
                                  Text(
                                    selectedView,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Icon(
                                    Icons.list,
                                    size: 25,
                                  ),
                                ],
                              )),
                        ],
                      ),
                      Expanded(
                        child: entries.length == 0
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Text(
                                      '등록된 구성원이 없습니다.',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    "우측 하단의 + 버튼을 탭하여\n 구성원을 등록해 보세요.",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  )
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: entries.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      Center(
                                        child: OutlinedCardExample(
                                            username: index,
                                            entries: entries, // entries 전달
                                            type: 1,
                                            viewtype: viewtype),
                                      ),
                                    ],
                                    //color: const Color.fromARGB(255, 230, 229, 228),
                                  );
                                },
                                // separatorBuilder: (BuildContext context, int index) =>
                                //     const Divider(),
                              ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    ));
  }
}

class ListGroupBuild extends StatefulWidget {
  final String type;
  const ListGroupBuild({
    Key? key,
    // 생성자에 entries 추가
    required this.type,
  }) : super(key: key);
  @override
  _ListGroupBuildState createState() => _ListGroupBuildState();
}

class _ListGroupBuildState extends State<ListGroupBuild>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  AsyncMemoizer<List<familyName>> _memoizer_family = AsyncMemoizer();
  int sorttype = 1;
  int viewtype = 1;
  String selectedSort = "등록일순";
  String selectedView = "간략히 보기";
  // late List<familyName> entries;
  late SharedPreferences prefs;

  Future<void> recacheEntries() async {
    _memoizer_family = AsyncMemoizer(); // 다시 초기화
  }

  Future<List<familyName>> getGroupEntries(String type) async {
    return this._memoizer_family.runOnce(() async {
      List<familyName> groupentries = await inquireGroupList(type);
      return groupentries;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('sorttype') != null && prefs.getInt('viewtype') != null) {
      sorttype = prefs.getInt('sorttype')!;
      viewtype = prefs.getInt('viewtype')!;
      if (sorttype == 1) {
        selectedSort = "등록일순";
      } else {
        selectedSort = "이름순";
      }

      if (viewtype == 1) {
        selectedView = "간략히 보기";
      } else {
        selectedView = "상세히 보기";
      }
    }
    // List<familyName> data = await getEntries();
    // setState(() {
    //   entries = data;
    // });
  }

  void updateSelectedSort(String newSort, StateSetter setState, int sortnum) {
    setState(() {
      selectedSort = newSort;
      sorttype = sortnum;
    });
    prefs.setInt('sorttype', sortnum);
  }

  void updateSelectedView(String viewtext, StateSetter setState, int viewnum) {
    setState(() {
      selectedView = viewtext;
      viewtype = viewnum;
    });
    prefs.setInt('viewtype', viewnum);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: RefreshIndicator(
      onRefresh: () async {
        recacheEntries();
        setState(() {
          _memoizer_family;
        });
      },
      child: FutureBuilder<List<familyName>>(
        future: getGroupEntries(widget.type), // entries를 얻기 위해 Future를 전달
        builder:
            (BuildContext context, AsyncSnapshot<List<familyName>> snapshot) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 데이터를 아직 받아오는 중이면 로딩 표시를 보여줌
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // 데이터를 받아오는 도중 에러가 발생하면 에러 메시지를 보여줌
                return Text('Error: ${snapshot.error}');
              } else {
                // 데이터를 정상적으로 받아왔을 경우
                List<familyName> entries = snapshot.data!; // 해결된 데이터를 얻음
                if (sorttype == 1) {
                  entries.sort((a, b) => a.id.compareTo(b.id));
                } else if (sorttype == 2) {
                  entries.sort((a, b) => a.name.compareTo(b.name));
                }
                return Container(
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 20),
                              ),
                              onPressed: () async {
                                final result =
                                    await _showBottomSortSheet(context);
                                print(result);
                                if (result == 1) {
                                  updateSelectedSort("등록일순", setState, 1);
                                } else if (result == 2) {
                                  updateSelectedSort("이름순", setState, 2);
                                }
                              },
                              child: Row(
                                children: [
                                  Text(
                                    selectedSort,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Icon(
                                    Icons.swap_vert,
                                    size: 25,
                                  ),
                                ],
                              )),
                          TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 20),
                              ),
                              onPressed: () async {
                                final result =
                                    await _showBottomViewSheet(context);
                                if (result == 1) {
                                  updateSelectedView("간략히 보기", setState, 1);
                                } else if (result == 2) {
                                  updateSelectedView("상세히 보기", setState, 2);
                                }
                              },
                              child: Row(
                                children: [
                                  Text(
                                    selectedView,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Icon(
                                    Icons.list,
                                    size: 25,
                                  ),
                                ],
                              )),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: entries.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                Center(
                                  child: OutlinedCardExample(
                                    username: index,
                                    entries: entries, // entries 전달
                                    type: 2,
                                    viewtype: viewtype,
                                  ),
                                ),
                              ],
                              //color: const Color.fromARGB(255, 230, 229, 228),
                            );
                          },
                          // separatorBuilder: (BuildContext context, int index) =>
                          //     const Divider(),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    ));
  }
}

// Future<FutureBuilder<List<familyName>>> ListBuild(
//     BuildContext context, int sorttype, int viewtype) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String selectedSort = "등록일순"; // 1번
//   String selectedView = "간단히 보기"; //1번

//   if (prefs.getInt('sorttype') != null && prefs.getInt('viewtype') != null) {
//     sorttype = prefs.getInt('sorttype')!;
//     viewtype = prefs.getInt('viewtype')!;
//     if (sorttype == 1) {
//       selectedSort = "등록일순";
//     } else {
//       selectedSort = "이름순";
//     }

//     if (viewtype == 1) {
//       selectedView = "간단히 보기";
//     } else {
//       selectedView = "상세히 보기";
//     }
//   }

//   // Define a callback function to update selectedSort
//   void updateSelectedSort(String newSort, StateSetter setState, int sortnum) {
//     setState(() {
//       selectedSort = newSort;
//       sorttype = sortnum;
//     });
//     prefs.setInt('sorttype', sortnum);
//   }

//   void updateSelectedView(String viewtext, StateSetter setState, int viewnum) {
//     setState(() {
//       selectedView = viewtext;
//       viewtype = viewnum;
//     });
//     prefs.setInt('viewtype', viewnum);
//   }

//   return FutureBuilder<List<familyName>>(
//     future: getEntries(), // entries를 얻기 위해 Future를 전달
//     builder: (BuildContext context, AsyncSnapshot<List<familyName>> snapshot) {
//       return StatefulBuilder(
//         builder: (BuildContext context, StateSetter setState) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // 데이터를 아직 받아오는 중이면 로딩 표시를 보여줌
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             // 데이터를 받아오는 도중 에러가 발생하면 에러 메시지를 보여줌
//             return Text('Error: ${snapshot.error}');
//           } else {
//             // 데이터를 정상적으로 받아왔을 경우
//             List<familyName> entries = snapshot.data!; // 해결된 데이터를 얻음
//             if (sorttype == 1) {
//               entries.sort((a, b) => a.id.compareTo(b.id));
//             } else if (sorttype == 2) {
//               entries.sort((a, b) => a.name.compareTo(b.name));
//             }
//             return Container(
//               width: GlobalData.queryWidth,
//               height: GlobalData.queryHeight,
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/image/eliblogo.png'),
//                   colorFilter: ColorFilter.matrix([
//                     // 희미한 효과를 주는 컬러 매트릭스
//                     0.1, 0, 0, 0, 0,
//                     0, 0.9, 0, 0, 0,
//                     0, 0, 0.1, 0, 0,
//                     0, 0, 0, 0.1, 0,
//                   ]),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                           style: TextButton.styleFrom(
//                             textStyle: const TextStyle(fontSize: 20),
//                           ),
//                           onPressed: () async {
//                             final result = await _showBottomSortSheet(context);
//                             if (result == 1) {
//                               updateSelectedSort("등록일순", setState, 1);
//                             } else if (result == 2) {
//                               updateSelectedSort("이름순", setState, 2);
//                             }
//                           },
//                           child: Row(
//                             children: [
//                               Text(
//                                 selectedSort,
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                 ),
//                               ),
//                               Icon(
//                                 Icons.swap_vert,
//                                 size: 25,
//                               ),
//                             ],
//                           )),
//                       TextButton(
//                           style: TextButton.styleFrom(
//                             textStyle: const TextStyle(fontSize: 20),
//                           ),
//                           onPressed: () async {
//                             final result = await _showBottomViewSheet(context);
//                             if (result == 1) {
//                               updateSelectedView("간단히 보기", setState, 1);
//                             } else if (result == 2) {
//                               updateSelectedView("상세히 보기", setState, 2);
//                             }
//                           },
//                           child: Row(
//                             children: [
//                               Text(
//                                 selectedView,
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                 ),
//                               ),
//                               Icon(
//                                 Icons.list,
//                                 size: 25,
//                               ),
//                             ],
//                           )),
//                     ],
//                   ),
//                   Expanded(
//                     child: entries.length == 0
//                         ? const Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.person,
//                                 size: 80,
//                                 color: Colors.grey,
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(bottom: 10.0),
//                                 child: Text(
//                                   '등록된 구성원이 없습니다.',
//                                   style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                               Text(
//                                 "우측 하단의 + 버튼을 탭하여\n 구성원을 등록해 보세요.",
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                 ),
//                               )
//                             ],
//                           )
//                         : ListView.builder(
//                             padding: const EdgeInsets.all(8),
//                             itemCount: entries.length,
//                             itemBuilder: (BuildContext context, int index) {
//                               return Column(
//                                 children: [
//                                   Center(
//                                     child: OutlinedCardExample(
//                                         username: index,
//                                         entries: entries, // entries 전달
//                                         type: 1,
//                                         viewtype: viewtype),
//                                   ),
//                                 ],
//                                 //color: const Color.fromARGB(255, 230, 229, 228),
//                               );
//                             },
//                             // separatorBuilder: (BuildContext context, int index) =>
//                             //     const Divider(),
//                           ),
//                   ),
//                 ],
//               ),
//             );
//           }
//         },
//       );
//     },
//   );
// }

// Future<FutureBuilder<List<familyName>>> ListGroupBuild(
//     BuildContext context, String type, int sorttype, int viewtype) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String selectedSort = "등록일순"; // 1번
//   String selectedView = "간단히 보기"; //1번

//   if (prefs.getInt('sorttype') != null && prefs.getInt('viewtype') != null) {
//     sorttype = prefs.getInt('sorttype')!;
//     viewtype = prefs.getInt('viewtype')!;
//     if (sorttype == 1) {
//       selectedSort = "등록일순";
//     } else {
//       selectedSort = "이름순";
//     }

//     if (viewtype == 1) {
//       selectedView = "간단히 보기";
//     } else {
//       selectedView = "상세히 보기";
//     }
//   }

//   // Define a callback function to update selectedSort
//   void updateSelectedSort(String newSort, StateSetter setState, int sortnum) {
//     setState(() {
//       selectedSort = newSort;
//       sorttype = sortnum;
//     });
//     prefs.setInt('sorttype', sortnum);
//   }

//   void updateSelectedView(String viewtext, StateSetter setState, int viewnum) {
//     setState(() {
//       selectedView = viewtext;
//       viewtype = viewnum;
//     });
//     prefs.setInt('viewtype', viewnum);
//   }

//   return FutureBuilder<List<familyName>>(
//     future: getGroupEntries(type), // entries를 얻기 위해 Future를 전달
//     builder: (BuildContext context, AsyncSnapshot<List<familyName>> snapshot) {
//       return StatefulBuilder(
//         builder: (BuildContext context, StateSetter setState) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // 데이터를 아직 받아오는 중이면 로딩 표시를 보여줌
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             // 데이터를 받아오는 도중 에러가 발생하면 에러 메시지를 보여줌
//             return Text('Error: ${snapshot.error}');
//           } else {
//             // 데이터를 정상적으로 받아왔을 경우
//             List<familyName> entries = snapshot.data!; // 해결된 데이터를 얻음
//             if (sorttype == 1) {
//               entries.sort((a, b) => a.id.compareTo(b.id));
//             } else if (sorttype == 2) {
//               entries.sort((a, b) => a.name.compareTo(b.name));
//             }
//             return Container(
//               width: GlobalData.queryWidth,
//               height: GlobalData.queryHeight,
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/image/eliblogo.png'),
//                   colorFilter: ColorFilter.matrix([
//                     // 희미한 효과를 주는 컬러 매트릭스
//                     0.1, 0, 0, 0, 0,
//                     0, 0.9, 0, 0, 0,
//                     0, 0, 0.1, 0, 0,
//                     0, 0, 0, 0.1, 0,
//                   ]),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                           style: TextButton.styleFrom(
//                             textStyle: const TextStyle(fontSize: 20),
//                           ),
//                           onPressed: () async {
//                             final result = await _showBottomSortSheet(context);
//                             print(result);
//                             if (result == 1) {
//                               updateSelectedSort("등록일순", setState, 1);
//                             } else if (result == 2) {
//                               updateSelectedSort("이름순", setState, 2);
//                             }
//                           },
//                           child: Row(
//                             children: [
//                               Text(
//                                 selectedSort,
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                 ),
//                               ),
//                               Icon(
//                                 Icons.swap_vert,
//                                 size: 25,
//                               ),
//                             ],
//                           )),
//                       TextButton(
//                           style: TextButton.styleFrom(
//                             textStyle: const TextStyle(fontSize: 20),
//                           ),
//                           onPressed: () async {
//                             final result = await _showBottomViewSheet(context);
//                             if (result == 1) {
//                               updateSelectedView("간략히 보기", setState, 1);
//                             } else if (result == 2) {
//                               updateSelectedView("상세히 보기", setState, 2);
//                             }
//                           },
//                           child: Row(
//                             children: [
//                               Text(
//                                 selectedView,
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                 ),
//                               ),
//                               Icon(
//                                 Icons.list,
//                                 size: 25,
//                               ),
//                             ],
//                           )),
//                     ],
//                   ),
//                   Expanded(
//                     child: ListView.builder(
//                       padding: const EdgeInsets.all(8),
//                       itemCount: entries.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         return Column(
//                           children: [
//                             Center(
//                               child: OutlinedCardExample(
//                                 username: index,
//                                 entries: entries, // entries 전달
//                                 type: 2,
//                                 viewtype: viewtype,
//                               ),
//                             ),
//                           ],
//                           //color: const Color.fromARGB(255, 230, 229, 228),
//                         );
//                       },
//                       // separatorBuilder: (BuildContext context, int index) =>
//                       //     const Divider(),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//         },
//       );
//     },
//   );
// }

class OutlinedCardExample extends StatefulWidget {
  final int username;
  final List<familyName> entries; // entries 변수 추가
  final int type;
  final int viewtype;
  const OutlinedCardExample(
      {Key? key,
      required this.username,
      required this.entries, // 생성자에 entries 추가
      required this.type,
      required this.viewtype})
      : super(key: key);

  @override
  State<OutlinedCardExample> createState() => _OutlinedCardExampleState();
}

class _OutlinedCardExampleState extends State<OutlinedCardExample> {
  late int scoreColor;
  @override
  Widget build(BuildContext context) {
    if (widget.entries[widget.username].score != null &&
        widget.entries[widget.username].score < 35) {
      scoreColor = 0xFFF16969; //pink
    } else if (widget.entries[widget.username].score != null &&
        widget.entries[widget.username].score < 70) {
      scoreColor = 0xFF6A9DFF; //blue
    } else {
      scoreColor = 0xFF4CAF50; //green
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: SizedBox(
          width: GlobalData.queryWidth,
          // height: GlobalData.queryHeight * 0.1,
          child: InkWell(
            onTap: () async {
              showDetail(context);
            },
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                  child: widget.entries[widget.username].imgUrl == null
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
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: Colors.grey),
                            image: DecorationImage(
                                image: NetworkImage(
                                    widget.entries[widget.username].imgUrl!),
                                fit: BoxFit.cover),
                          ),
                        ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        widget.entries[widget.username].nickname == null
                            ? Text(
                                '${widget.entries[widget.username].name}님 ',
                                style: const TextStyle(
                                    color: Color.fromRGBO(131, 131, 131, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              )
                            : Text(
                                '${widget.entries[widget.username].nickname}님 ',
                                style: const TextStyle(
                                    color: Color.fromRGBO(131, 131, 131, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                        Container(
                          height: widget.viewtype == 2 &&
                                  widget.entries[widget.username].category !=
                                      null
                              ? null
                              : 0.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.blue[100]),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: Text(
                              "${widget.entries[widget.username].category}",
                              // '${widget.entries[widget.username].phone.substring(0, 3)}-${widget.entries[widget.username].phone.substring(3, 7)}-${widget.entries[widget.username].phone.substring(7, 11)}',
                              style: const TextStyle(
                                  // color: Color.fromRGBO(131, 131, 131, 1),
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Container(
                    //   height: widget.viewtype == 2 ? null : 0.0,
                    //   child: Text(
                    //     "안전 점수: ${widget.entries[widget.username].score}",
                    //     style: TextStyle(
                    //         fontSize: 15,
                    //         fontWeight: FontWeight.bold,
                    //         color: Colors.grey),
                    //   ),
                    // ),
                    Container(
                      height: widget.viewtype == 2 ? null : 0.0,
                      child: Text(
                        "재난키트/훈련 : ${widget.entries[widget.username].toolscore}/${widget.entries[widget.username].trainscore}",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Container(
                    //       height: widget.viewtype == 2 ? null : 0.0,
                    //       child: Text(
                    //         "훈련이수현황: ${widget.entries[widget.username].score}",
                    //         style: TextStyle(
                    //             fontSize: 12,
                    //             fontWeight: FontWeight.bold,
                    //             color: Colors.grey),
                    //       ),
                    //     ),
                    //     Container(
                    //       height: widget.viewtype == 2 ? null : 0.0,
                    //       child: Text(
                    //         "도구보유 현황: ${widget.entries[widget.username].score}",
                    //         style: TextStyle(
                    //             fontSize: 12,
                    //             fontWeight: FontWeight.bold,
                    //             color: Colors.grey),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                    //   child: Container(
                    //     height: widget.viewtype == 2 &&
                    //             widget.entries[widget.username].category != null
                    //         ? null
                    //         : 0.0,
                    //     decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(5),
                    //         color: Colors.blue[100]),
                    //     child: Padding(
                    //       padding: const EdgeInsets.only(left: 5, right: 5),
                    //       child: Text(
                    //         "${widget.entries[widget.username].category}",
                    //         // '${widget.entries[widget.username].phone.substring(0, 3)}-${widget.entries[widget.username].phone.substring(3, 7)}-${widget.entries[widget.username].phone.substring(7, 11)}',
                    //         style: const TextStyle(
                    //             // color: Color.fromRGBO(131, 131, 131, 1),
                    //             color: Colors.white,
                    //             fontSize: 14,
                    //             fontWeight: FontWeight.w600),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    //   height: 20,
                    //   width: 35,
                    //   decoration: BoxDecoration(
                    //     border: Border.all(
                    //       width: 1,
                    //       color: Color(countColor),
                    //     ),
                    //     borderRadius: BorderRadius.circular(5),
                    //     color: Color(countColor),
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(left: 5, right: 5),
                    //     child: Text(
                    //       '${snapshot.data?[i].count}개',
                    //       style: TextStyle(
                    //         color: Color(countText),
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //       textAlign: TextAlign.center,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 5,
                    ),
                    child: Container(
                      // color: Colors.amber,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("${widget.entries[widget.username].score}",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(scoreColor),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                // const Spacer(), // Adds flexible space
                InkWell(
                  onTap: () {
                    groupChange(context);
                  },
                  child: const Icon(
                    Icons.more_vert_outlined,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  groupChange(BuildContext context) {
    return showDialog(
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
                "${widget.entries[widget.username].name}",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      viewGrouplist(
                        context,
                      );
                    },
                    child: Text(
                      "그룹 변경하기 ",
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    height: widget.type == 2
                        ? null
                        : 0.0, // Set the height to 0 if not visible
                    child: Visibility(
                      visible: widget.type == 2,
                      child: TextButton(
                        onPressed: () async {
                          await deleteGroupsendData(
                              widget.entries[widget.username].id);
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      BulidBottomAppBar(
                                        index: 3,
                                      )),
                              (route) => false);
                        },
                        child: Text(
                          "그룹에서 삭제하기",
                          style: TextStyle(fontSize: 15, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  // TextButton(
                  //   onPressed: () async {
                  //     await deleteGroupsendData(
                  //         widget.entries[widget.username].id);
                  //     Navigator.pop(context);
                  //   },
                  //   child: Visibility(
                  //     visible: widget.type == 2,
                  //     child: Text(
                  //       "그룹에서 삭제하기 ",
                  //       style: TextStyle(fontSize: 15, color: Colors.red),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        });
  }

  Future<String?> showDetail(BuildContext context) {
    return showDialog<String>(
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
            backgroundColor: Colors.white, // 배경색 지정
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                Column(
                  children: [
                    widget.entries[widget.username].imgUrl == null
                        ? Container(
                            width: 60,
                            height: 60,
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
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 2, color: Colors.grey),
                              image: DecorationImage(
                                  image: NetworkImage(
                                      widget.entries[widget.username].imgUrl!),
                                  fit: BoxFit.cover),
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: widget.entries[widget.username].nickname == null
                          ? Text(
                              '${widget.entries[widget.username].name}님 ',
                              style: const TextStyle(
                                  color: Color.fromRGBO(131, 131, 131, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24),
                            )
                          : Text(
                              '${widget.entries[widget.username].nickname}님 ',
                              style: const TextStyle(
                                  color: Color.fromRGBO(131, 131, 131, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24),
                            ),
                    )
                  ],
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              // height: MediaQuery.sizeOf(context).height * 0.33,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      _navigateToMemberInfoPage(
                          context,
                          0,
                          widget.entries[widget.username].id,
                          widget.entries[widget.username].phone);
                    },
                    child: const ListTile(
                      //leading. 타일 앞에 표시되는 위젯. 참고로 타일 뒤에는 trailing 위젯으로 사용 가능
                      leading: Icon(Icons.construction),
                      title: Text(
                        '재난도구 보유 현황',
                        style: TextStyle(
                          color: Color.fromRGBO(131, 131, 131, 1),
                          fontSize: 20,
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _navigateToMemberInfoPage(
                          context,
                          1,
                          widget.entries[widget.username].id,
                          widget.entries[widget.username].phone);
                    },
                    child: const ListTile(
                      leading: Icon(
                        Icons.edit_document,
                      ),
                      title: Text(
                        '재난훈련 이수 현황',
                        style: TextStyle(
                          color: Color.fromRGBO(131, 131, 131, 1),
                          fontSize: 20,
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _navigateToMemberInfoPage(
                          context,
                          2,
                          widget.entries[widget.username].id,
                          widget.entries[widget.username].phone);
                    },
                    child: const ListTile(
                      leading: Icon(Icons.place_outlined),
                      title: Text(
                        '최근 위치 정보',
                        style: TextStyle(
                          color: Color.fromRGBO(131, 131, 131, 1),
                          fontSize: 20,
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _navigateToMemberInfoPage(
                          context,
                          3,
                          widget.entries[widget.username].id,
                          widget.entries[widget.username].phone);
                    },
                    child: const ListTile(
                      leading: Icon(Icons.phone),
                      title: Text(
                        '긴급연락',
                        style: TextStyle(
                          color: Color.fromRGBO(131, 131, 131, 1),
                          fontSize: 20,
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     ElevatedButton(
                  //       onPressed: () {
                  //         widget.entries[widget.username].nickname == null
                  //             ? _navigateToEditFamilyNamePage(
                  //                 context,
                  //                 widget.entries[widget.username].name,
                  //                 widget.entries[widget.username].id)
                  //             : _navigateToEditFamilyNamePage(
                  //                 context,
                  //                 widget.entries[widget.username].nickname!,
                  //                 widget.entries[widget.username].id);
                  //       },
                  //       style: ElevatedButton.styleFrom(
                  //         foregroundColor: Colors.white,
                  //         backgroundColor: Colors.grey,
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(10.0),
                  //         ),
                  //         elevation: 0.0,
                  //       ),
                  //       child: const Text('구성원 이름 변경'),
                  //     ),
                  //     ElevatedButton(
                  //       onPressed: () {
                  //         _showdialog(
                  //             context, widget.entries[widget.username].id);
                  //       },
                  //       style: ElevatedButton.styleFrom(
                  //         foregroundColor: Colors.white,
                  //         backgroundColor: Color.fromRGBO(255, 92, 92, 1.0),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(10.0),
                  //         ),
                  //         elevation: 0.0,
                  //       ),
                  //       child: const Text('구성원 삭제'),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.entries[widget.username].nickname == null
                          ? _navigateToEditFamilyNamePage(
                              context,
                              widget.entries[widget.username].name,
                              widget.entries[widget.username].id)
                          : _navigateToEditFamilyNamePage(
                              context,
                              widget.entries[widget.username].nickname!,
                              widget.entries[widget.username].id);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0.0,
                    ),
                    child: const Text('구성원 이름 변경'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showdialog(context, widget.entries[widget.username].id);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromRGBO(255, 92, 92, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0.0,
                    ),
                    child: const Text('구성원 삭제'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  viewGrouplist(BuildContext context) async {
    List<dynamic> grouplist = await inquireGroupName();
    // ignore: use_build_context_synchronously
    return showDialog(
        barrierDismissible: true,
        barrierColor: Colors.white.withOpacity(0),
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
                title: const Text(
                  "그룹 목록",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                content: SizedBox(
                  height: 100,
                  child: grouplist.length == 0 ||
                          (grouplist.length == 1 &&
                              grouplist.contains(
                                  widget.entries[widget.username].category))
                      ? Text("변경 가능한 그룹이 없습니다")
                      : SingleChildScrollView(
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: grouplist.map((groupName) {
                            return InkWell(
                              onTap: () async {
                                List<int> userid = [];
                                userid.add(widget.entries[widget.username].id);
                                await patchGroupsendData(groupName, userid);
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            BulidBottomAppBar(
                                              index: 3,
                                            )),
                                    (route) => false);
                              },
                              child: Row(
                                children: [
                                  groupName !=
                                          widget
                                              .entries[widget.username].category
                                      ? Text(
                                          groupName,
                                        )
                                      : Container(
                                          height: 0,
                                        )
                                ],
                              ),
                            );
                          }).toList(),
                        )),
                ),
              ));
        });
  }
}

Future<List<familyName>> loadFamilyInfo() async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/family');

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<familyName> list =
        data.map((dynamic e) => familyName.fromJson(e)).toList();
    return list;
    // print(list?[i].name);
  } else {
    throw Exception('fail');
  }
}

Future<void> deleteMember(int id) async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.delete('/api/v1/family/$id');

  if (response.statusCode == 200) {
  } else {
    throw Exception('fail');
  }
}

class familyName {
  final String name;
  final int id;
  final String phone;
  final String? imgUrl;
  final String? nickname;
  final String? category;
  final String birth;
  final int score;
  final int toolscore;
  final int trainscore;
  familyName({
    required this.name,
    required this.id,
    required this.phone,
    required this.imgUrl,
    required this.nickname,
    required this.category,
    required this.birth,
    required this.score,
    required this.toolscore,
    required this.trainscore,
  });

  factory familyName.fromJson(Map<String, dynamic> json) {
    return familyName(
        name: json['name'],
        id: json['id'],
        phone: json['phone'],
        imgUrl: json['image'],
        nickname: json['nickname'],
        category: json['category'],
        birth: json['birth'],
        score: json['score'],
        toolscore: json['toolScore'],
        trainscore: json['trainScore']);
  }
}

void _navigateToInvitePage(BuildContext context) {
  // TODO: 더보기 페이지로 화면 전환
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MemberInvitePage(),
    ),
  );
}

void _navigateToMemberInfoPage(
    BuildContext context, int pageNum, int id, String phone) {
  // TODO: 더보기 페이지로 화면 전환
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          MemberInfoPage(pageNum: pageNum, userId: id, phone: phone),
    ),
  );
}

Future<dynamic> _showdialog(BuildContext context, int id) {
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
                borderRadius: BorderRadius.circular(0.0)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "구성원을 삭제 하시겠습니까?",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  '취소',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await deleteMember(id);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => BulidBottomAppBar(
                                index: 3,
                              )),
                      (route) => false);
                },
                child: const Text(
                  '삭제',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      });
}

Future<String> creatInviteCode() async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/family/code');

  if (response.statusCode == 200) {
    return response.data;
  } else {
    throw Exception('fail');
  }
}

void _navigateToEnterCodePage(BuildContext context) {
  // TODO: 더보기 페이지로 화면 전환
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EnterCodePage()),
  );
}

void _navigateToEditFamilyNamePage(
    BuildContext context, String currentname, int familyid) {
  // TODO: 더보기 페이지로 화면 전환
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          EditFamilyNamePage(currentname: currentname, familyid: familyid),
    ),
  );
}

class VerticalTabBarLayout extends StatefulWidget {
  const VerticalTabBarLayout({super.key, this.navigateToAddGroupPage});
  final navigateToAddGroupPage;

  @override
  _VerticalTabBarLayoutState createState() => _VerticalTabBarLayoutState();
}

class _VerticalTabBarLayoutState extends State<VerticalTabBarLayout>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> tabNames = ['모든인원'];
  int _selectedIndex = 0; // Track the selected index
  late List<dynamic>? grouplist;
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabNames.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    getgrouplist();
  }

  Future<void> getgrouplist() async {
    return this._memoizer.runOnce(() async {
      final fetchedList = await inquireGroupName();

      setState(() {
        grouplist = fetchedList;
      });
      if (grouplist == null) {
      } else {
        addTab();
      }
    });
  }

  void _handleTabChange() {
    setState(() {
      _selectedIndex = _tabController.index;
    });
  }

  void addTab() {
    setState(() {
      for (String tabName in grouplist!) {
        tabNames.add(tabName);
      }
      _tabController = TabController(length: tabNames.length, vsync: this);
      if (_selectedIndex == 0) {
        _tabController.index = 0; // 초기 선택은 첫 번째 탭
      } else {
        _tabController.index = tabNames.length - 1; // 나머지 경우는 마지막 탭
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: ListView(
            // Wrap with ListView to make the tab area scrollable
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int index = 0; index < tabNames.length; index++)
                    ListTile(
                      contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                      title: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: _selectedIndex == index
                                ? Colors.grey.shade400
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1,
                            )),
                        child: Center(
                          child: Text(
                            tabNames[index],
                            style: TextStyle(
                              fontSize: 15,
                              color: _selectedIndex == index
                                  ? Colors.white
                                  : Colors.grey.shade400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      splashColor: Colors.transparent, //클릭시 원형 이펙트
                      onTap: () {
                        _tabController.animateTo(index);
                        setState(() {
                          _selectedIndex = index; // Update the selected index
                        });
                      },
                    ),

                  // Ink(
                  //   decoration: const ShapeDecoration(
                  //     color: Colors.grey,
                  //     shape: CircleBorder(),
                  //   ),
                  //   child: Center(
                  //     child: IconButton(
                  //       icon: const Icon(
                  //         Icons.add,
                  //         size: 30,
                  //       ),
                  //       color: Colors.white,
                  //       onPressed: () {
                  //         widget.navigateToAddGroupPage();
                  //         // _showBottomSheet();
                  //       },
                  //     ),
                  //   ),
                  // ),
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     shape: RoundedRectangleBorder(
                  //         //모서리를 둥글게
                  //         borderRadius: BorderRadius.circular(0)),
                  //   ),
                  //   onPressed: () {
                  //     widget.navigateToAddGroupPage();
                  //     // addTab();
                  //   },
                  //   child: Text('그룹\n추가'),
                  // ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              // The first tab with ListBuild
              ListBuild(),
              if (tabNames.length > 1)
                for (int index = 1; index < tabNames.length; index++)
                  ListGroupBuild(type: tabNames[index]),
            ],
          ),
        ),
      ],
    );
  }
}

Future<List<dynamic>> inquireGroupName() async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/family/category');
  if (response.statusCode == 200) {
    print(response.data);
    return response.data;
  } else {
    throw Exception('fail');
  }
}

Future<List<familyName>> inquireGroupList(String type) async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/family/category/$type');
  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    List<familyName> list =
        data.map((dynamic e) => familyName.fromJson(e)).toList();
    return list;
    // print(list?[i].name);
  } else {
    throw Exception('fail');
  }
}

deleteGroupsendData(int id) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio
      .delete('/api/v1/family/category', queryParameters: {'familyId': id});
  if (response.statusCode == 200) {
    print(response.data);
    return response.statusCode;
  }
}

patchGroupsendData(String category, List<int> id) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.patch('/api/v1/family/category',
      data: jsonEncode(id), queryParameters: {'category': category});
  if (response.statusCode == 200) {
    print(response.data);
    return response.statusCode;
  }
}
