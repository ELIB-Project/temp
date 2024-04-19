import 'dart:convert';

import 'package:elib_project/pages/home_page.dart';
import 'package:elib_project/pages/train_category.dart';
import 'package:elib_project/pages/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shimmer/shimmer.dart';

double appBarHeight = 40;
double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height - appBarHeight) * scale;
double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

double topFontSize = 10;

//Color tileColor = Colors.grey.shade300;
Color categoryText = Colors.grey;

const storage = FlutterSecureStorage();

class trainList {
  final int id;
  final String? name;
  final List? imgUrl;
  final List? videoUrl;
  final List? pdfUrl;
  bool? imgComplete;
  bool? videoComplete;
  final String? type;

  trainList({
    required this.id,
    required this.name,
    required this.imgUrl,
    required this.videoUrl,
    required this.pdfUrl,
    required this.imgComplete,
    required this.videoComplete,
    required this.type,
  });

  factory trainList.fromJson(Map<String, dynamic> json) {
    return trainList(
      id: json['id'],
      name: json['name'],
      imgUrl: json['imgUrl'],
      videoUrl: json['videoUrl'],
      pdfUrl: json['pdfUrl'],
      imgComplete: json['imgComplete'],
      videoComplete: json['videoComplete'],
      type: json['type'],
    );
  }
}

class trainPage extends StatefulWidget {
  const trainPage({super.key});

  @override
  State<trainPage> createState() => _trainPageState();
}

class _trainPageState extends State<trainPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void viewTrain(trainList) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => trainRegistpage(
                  train: trainList,
                ))).then((value) {
      setState(() {
        //주석
        //futureTrainList = loadTrainList();
      });
    });
  }

  @override
  void initState() {
    loadCategoryTr = initTr();
    //주석
    //futureTrainList = loadTrainList();

    super.initState();
  }

  void updateCategoriesTr(int oldIndex, int newIndex) {
    const storage = FlutterSecureStorage();

    setState(() {
      if (oldIndex < newIndex) {
        newIndex--;
      }

      //움직이는 카테고리
      final category = trainCategories.removeAt(oldIndex);

      //카테고리의 새 위치
      trainCategories.insert(newIndex, category);
    });

    storage.write(key: 'Category_Train', value: jsonEncode(trainCategories));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 250, 250, 250),
          colorSchemeSeed: Color.fromARGB(0, 241, 241, 241),
          useMaterial3: true),
      home: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Title(
                color: Color.fromRGBO(87, 87, 87, 1),
                child: Text(
                  '훈련',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 5),
                child: IconButton(
                  icon: Icon(
                    Icons.visibility_outlined,
                    size: 30,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => trainCategoryPage()))
                        .then((value) {
                      setState(() {
                        loadCategoryTr = initTr();
                        //주석
                        //futureTrainList = loadTrainList();
                      });
                    });
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => toolRegistPage()));
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            top: true,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: mediaHeight(context, 0.01),
              ),

              //카테고리
              Container(
                //color: Colors.grey.shade300,
                height: 50,
                width: mediaWidth(context, 1),
                child: Row(
                  children: [

                    Expanded(
                      //height: mediaHeight(context, 1) - 10,
                      child: FutureBuilder<void>(
                          future: loadCategoryTr,
                          builder: (context, snapshot) {
                            return ReorderableListView.builder(
                              scrollDirection: Axis.horizontal,
                                onReorder: (oldIndex, newIndex) =>
                                    updateCategoriesTr(
                                        oldIndex, newIndex),
                                itemCount: trainCategories.length,
                                itemBuilder: (context, i) {
                                  var category = trainCategories[i];

                                  if (category == selectedCategoryTr) {
                                    //tileColor = Colors.grey.shade400;
                                    categoryText = Colors.black;
                                  } else {
                                    //tileColor = Colors.white;
                                    categoryText = Colors.grey;
                                  }

                                  return Container(
                                    //color: tileColor,
                                    //color: Colors.white,
                                    key: Key(category),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                          left: 5,
                                          right: 5),
                                      child: Container(
                                        width: 50,
                                        height: 30,
                                        // decoration: BoxDecoration(
                                        //   color: tileColor,
                                        //   borderRadius:
                                        //       BorderRadius.circular(20),
                                        //   border: Border.all(
                                        //     color: categoryText,
                                        //     width: 1,
                                        //   ),
                                        // ),
                                        child: Stack(children: [
                                          Center(
                                            child: Text(
                                              category,
                                              style: TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: categoryText,
                                                fontSize: 15,
                                              ),
                                              textAlign:
                                                  TextAlign.center,
                                            ),
                                          ),
                                          ListTile(
                                            //tileColor: tileColor,
                                            // title: Text(
                                            //   category,
                                            //   style: TextStyle(
                                            //     fontWeight: FontWeight.normal,
                                            //     color: categoryText,
                                            //     fontSize: 15,
                                            //   ),
                                            // ),
                                            onTap: () {
                                              selectedCategoryTr =category;
                                              
                                              print(selectedCategoryTr);

                                              setState(() {});
                                            },
                                          ),
                                        ]),
                                      ),
                                    ),
                                  );
                                });
                          }),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: mediaHeight(context, 0.01),
              ),



              //미이수 내역
              Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    width: mediaWidth(context, 1),
                    height: mediaHeight(context, 0.07),
                    decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color:
                                Theme.of(context).shadowColor.withOpacity(0.3),
                            offset: const Offset(0, 3),
                            blurRadius: 5.0)
                      ],
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Color(0xFFFFF3B2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<List<trainList>>(
                          future: (selectedCategoryTr == "전체")
                            ? loadAllDefaultTrain()
                            : loadDefaultTrainByType(selectedCategoryTr!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              // 로딩 중에 스켈레톤 표시
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[600]!,
                                highlightColor: Colors.white,
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: "Loading...",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ])),
                              );
                            } else if (snapshot.hasError) {
                              // 에러 처리
                              return Text('Error: ${snapshot.error}');
                            } else {
                              // 데이터가 있을 때 실제 데이터 표시
                              return Text.rich(TextSpan(children: [
                                TextSpan(
                                  text: textA,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: textB,
                                  style: TextStyle(
                                    color: colorB,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: textC,
                                  style: TextStyle(
                                    color: colorC,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: textD,
                                  style: TextStyle(
                                    color: colorD,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: textE,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ]));
                            }
                          },
                        )
                      ],
                    ),
                  )),

              SizedBox(
                height: mediaHeight(context, 0.01),
              ),

              

              //훈련 리스트 출력부분
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      FutureBuilder<List<trainList>>(
                        future: (selectedCategoryTr == "전체")
                          ? loadAllDefaultTrain()
                          : loadDefaultTrainByType(selectedCategoryTr!),
                        builder: (context, snapshot) {

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return TrainSkeletonList();
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          } else {
                            List<trainList>? trains = snapshot.data;

                            if (trains != null && trains.isNotEmpty) {
                              return Column(
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 20, right: 20),
                                          child: ListView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: trains.length,
                                            itemBuilder: (BuildContext ctx, int idx) {
                                              String? name;
                                              if (trains[idx].name == null || trains[idx].name == "") {
                                                name = "test";
                                              } else {
                                                name = trains[idx].name;
                                              }

                                              List? videoUrl = trains[idx].videoUrl;
                                              List? imgUrl = trains[idx].imgUrl;

                                              bool videoVisible = true;
                                              if (videoUrl!.isEmpty == true) {
                                                videoVisible = false;
                                              }

                                              bool imgVisible = true;
                                              if (imgUrl!.isEmpty == true) {
                                                imgVisible = false;
                                              }

                                              IconData? iconName;
                                              int iconColor;

                                              bool? imgComplete = trains[idx].imgComplete;
                                              bool? videoComplete = trains[idx].videoComplete;
                                              if (imgComplete == true && videoComplete == true) {
                                                iconName = Icons.check_circle;
                                                iconColor = 0xFF38AE5D;
                                              } else {
                                                iconName = Icons.report_outlined;
                                                iconColor = 0xFFF16969;
                                              }

                                              return InkWell(
                                                onTap: () {
                                                  viewTrain(trains[idx]);
                                                },
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(
                                                              top: 15, bottom: 15),
                                                          child: Text(
                                                            '$name ',
                                                            style: TextStyle(
                                                              color: Colors.grey.shade600,
                                                              fontSize: 17,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: imgVisible,
                                                          child: Icon(
                                                            Icons.description,
                                                            color: Colors.grey.shade400,
                                                            size: 20,
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: videoVisible,
                                                          child: Icon(
                                                            Icons.videocam,
                                                            color: Colors.grey.shade400,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Icon(
                                                      iconName,
                                                      color: Color(iconColor),
                                                      size: 25,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  SizedBox(height: mediaHeight(context, 0.3)),

                                  Center(
                                    child: Text(
                                      "등록된 훈련 없음",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),


            ]),
          ),
        ),
      ),
    );
  }
}

//스켈레톤
class TrainSkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.white,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 10, // 적절한 개수로 설정
        itemBuilder: (BuildContext ctx, int idx) {
          return ListTile(
            title: Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 200,
                    height: 25,
                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10)),
                  ),
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

