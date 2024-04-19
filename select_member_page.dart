import 'package:elib_project/auth_dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

late List<familyName> selectedIds;
bool buttonenable = false;

class GlobalData {
  static double queryWidth = 0.0;
  static double queryHeight = 0.0;
}

class SelectMember extends StatefulWidget {
  const SelectMember({super.key});

  @override
  State<SelectMember> createState() => _SelectMemberState();
}

late Future<List<familyName>> myFuture1;
late Future<List<familyName>> myFuture2;

class _SelectMemberState extends State<SelectMember> {
  @override
  void initState() {
    buttonenable = false;
    selectedIds = [];
    super.initState();

    myFuture1 = getEntries();
  }

  void updateState(bool check) {
    setState(() {
      buttonenable = check;
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context, true); // 뒤로가기 버튼 클릭 이벤트 처리
            },
          ),
          title: Title(
              color: const Color.fromRGBO(87, 87, 87, 1),
              child: const Text(
                "그룹원 선택",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              )),
        ),
        body: SafeArea(
            child: Column(
          children: [
            Expanded(
                child: Stack(children: [
              ListBuild(context),
            ])),
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
              onPressed: buttonenable
                  ? () {
                      Navigator.pop(context, selectedIds);
                    }
                  : null,
              child: Text('추가완료'),
            ),
          ),
        ),
        extendBodyBehindAppBar: true, // AppBar가 배경 이미지를 가리지 않도록 설정
      ),
    );
  }

  Widget ListBuild(
    BuildContext context,
  ) {
    return FutureBuilder<List<familyName>>(
      future: myFuture1, // entries를 얻기 위해 Future를 전달
      builder:
          (BuildContext context, AsyncSnapshot<List<familyName>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 데이터를 아직 받아오는 중이면 로딩 표시를 보여줌
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // 데이터를 받아오는 도중 에러가 발생하면 에러 메시지를 보여줌
          return Text('Error: ${snapshot.error}');
        } else {
          // 데이터를 정상적으로 받아왔을 경우
          List<familyName> entries = snapshot.data!; // 해결된 데이터를 얻음
          buttonenable = selectedIds.isNotEmpty;

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
            child: ListView.builder(
              key: PageStorageKey(UniqueKey()),
              padding: const EdgeInsets.all(8),
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  //color: const Color.fromARGB(255, 230, 229, 228),
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: SizedBox(
                      width: GlobalData.queryWidth,
                      // height: GlobalData.queryHeight * 0.1,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (selectedIds.contains(entries[index])) {
                              selectedIds.remove(entries[index]); // 선택 해제
                              // isSelected = false;
                            } else {
                              selectedIds.add(entries[index]); // 선택
                              // isSelected = true;
                            }
                          });

                          if (selectedIds.length > 0) {
                            updateState(true);
                          } else {
                            updateState(false);
                          }

                          print(selectedIds);
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 20, 10),
                              child: entries[index].imgUrl == null
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
                                      child:
                                          selectedIds.contains(entries[index])
                                              ? Center(
                                                  child: Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                  ),
                                                )
                                              : Center(
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
                                        border: Border.all(
                                            width: 2, color: Colors.grey),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                entries[index].imgUrl!),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                entries[index].nickname == null
                                    ? Text(
                                        '${entries[index].name}님 ',
                                        style: const TextStyle(
                                            color: Color.fromRGBO(
                                                131, 131, 131, 1),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      )
                                    : Text(
                                        '${entries[index].nickname}님 ',
                                        style: const TextStyle(
                                            color: Color.fromRGBO(
                                                131, 131, 131, 1),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                Text(
                                  '${entries[index].phone.substring(0, 3)}-${entries[index].phone.substring(3, 7)}-${entries[index].phone.substring(7, 11)}',
                                  style: const TextStyle(
                                      color: Color.fromRGBO(131, 131, 131, 1),
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            const Spacer(), // Adds flexible space
                          ],
                        ),
                      ),
                    ),
                  )
                      // child: OutlinedCardExample(
                      //   username: index,
                      //   entries: entries, // entries 전달
                      //   updateState: updateState,
                      // ),
                      ),
                );
              },
              // separatorBuilder: (BuildContext context, int index) =>
              //     const Divider(),
            ),
          );
        }
      },
    );
  }
}

Future<List<familyName>> getEntries() async {
  List<familyName> entries = await loadFamilyInfo();
  return entries;
}

Future<List<familyName>> loadFamilyInfo() async {
  // 헤더에 access토큰 첨부를 위해 토큰 불러오기
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');
  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/family/category/null');

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

class familyName {
  final String name;
  final int id;
  final String phone;
  final String? imgUrl;
  final String? nickname;
  familyName(
      {required this.name,
      required this.id,
      required this.phone,
      required this.imgUrl,
      required this.nickname});

  factory familyName.fromJson(Map<String, dynamic> json) {
    return familyName(
        name: json['name'],
        id: json['id'],
        phone: json['phone'],
        imgUrl: json['image'],
        nickname: json['nickname']);
  }
}

// class OutlinedCardExample extends StatefulWidget {
//   final int username;
//   final List<familyName> entries; // entries 변수 추가
//   const OutlinedCardExample({
//     Key? key,
//     required this.username,
//     required this.entries,
//     this.updateState, // 생성자에 entries 추가
//   }) : super(key: key);
//   final updateState;

//   @override
//   State<OutlinedCardExample> createState() => _OutlinedCardExampleState();
// }

// class _OutlinedCardExampleState extends State<OutlinedCardExample>
//     with AutomaticKeepAliveClientMixin {
//   bool isSelected = false; // Add isSelected state
//   @override
//   bool get wantKeepAlive => true;

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//         child: SizedBox(
//           width: GlobalData.queryWidth,
//           // height: GlobalData.queryHeight * 0.1,
//           child: InkWell(
//             onTap: () {
//               setState(() {
//                 if (selectedIds.contains(widget.entries[widget.username].id)) {
//                   selectedIds
//                       .remove(widget.entries[widget.username].id); // 선택 해제
//                   isSelected = false;
//                 } else {
//                   selectedIds.add(widget.entries[widget.username].id); // 선택
//                   isSelected = true;
//                 }
//               });

//               if (selectedIds.length > 0) {
//                 widget.updateState(true);
//               } else {
//                 widget.updateState(false);
//               }

//               print(selectedIds);
//             },
//             child: Row(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
//                   child: widget.entries[widget.username].imgUrl == null
//                       ? Container(
//                           width: 50,
//                           height: 50,
//                           padding: const EdgeInsets.all(5.0),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.grey,
//                               width: 1.0,
//                             ),
//                           ),
//                           child: isSelected
//                               ? Center(
//                                   child: Icon(
//                                     Icons.check_circle,
//                                     color: Colors.green,
//                                   ),
//                                 )
//                               : Center(
//                                   child: Icon(
//                                     Icons.person,
//                                     size: 40,
//                                     color: Colors.grey,
//                                   ),
//                                 ))
//                       : Container(
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(width: 2, color: Colors.grey),
//                             image: DecorationImage(
//                                 image: NetworkImage(
//                                     widget.entries[widget.username].imgUrl!),
//                                 fit: BoxFit.cover),
//                           ),
//                         ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     widget.entries[widget.username].nickname == null
//                         ? Text(
//                             '${widget.entries[widget.username].name}님 ',
//                             style: const TextStyle(
//                                 color: Color.fromRGBO(131, 131, 131, 1),
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 20),
//                           )
//                         : Text(
//                             '${widget.entries[widget.username].nickname}님 ',
//                             style: const TextStyle(
//                                 color: Color.fromRGBO(131, 131, 131, 1),
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 20),
//                           ),
//                     Text(
//                       '${widget.entries[widget.username].phone.substring(0, 3)}-${widget.entries[widget.username].phone.substring(3, 7)}-${widget.entries[widget.username].phone.substring(7, 11)}',
//                       style: const TextStyle(
//                           color: Color.fromRGBO(131, 131, 131, 1),
//                           fontSize: 14),
//                     ),
//                   ],
//                 ),
//                 const Spacer(), // Adds flexible space
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
