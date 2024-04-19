import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:elib_project/auth_dio.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'membermanagement_page.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

double appBarHeight = 40;
double mediaHeight(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.height - appBarHeight) * scale;
double mediaWidth(BuildContext context, double scale) =>
    (MediaQuery.of(context).size.width) * scale;

class trainList {
  int? id;
  String? name;
  List? imgUrl;
  List? videoUrl;
  bool? imgComplete;
  bool? videoComplete;

  trainList({
    this.id,
    this.name,
    this.imgUrl,
    this.videoUrl,
    this.imgComplete,
    this.videoComplete,
  });

  factory trainList.fromJson(Map<String, dynamic> json) {
    return trainList(
      id: json['id'],
      name: json['name'],
      imgUrl: json['imgUrl'],
      videoUrl: json['videoUrl'],
      imgComplete: json['imgComplete'],
      videoComplete: json['videoComplete'],
    );
  }
}

class trainInfo {
  final int trains_id;
  final int? year;
  final int? videoCount;
  final int? imgCount;
  final int? totalCount;
  final bool? imgComplete;
  final bool? videoComplete;
  final String? updated;

  trainInfo({
    required this.trains_id,
    this.year,
    this.videoCount,
    this.imgCount,
    this.totalCount,
    required this.imgComplete,
    required this.videoComplete,
    this.updated,
  });

  factory trainInfo.fromJson(Map<String, dynamic> json) {
    return trainInfo(
      trains_id: json['trains_id'],
      year: json['year'],
      videoCount: json['videoCount'],
      imgCount: json['imgCount'],
      totalCount: json['totalCount'],
      imgComplete: json['imgComplete'],
      videoComplete: json['videoComplete'],
      updated: json['updated'],
    );
  }
}

Future<trainInfo> loadTrainInfo(train) async {
  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'ACCESS_TOKEN');

  var dio = await authDio();
  dio.options.headers['Authorization'] = '$accessToken';
  final response = await dio.get('/api/v1/user/train/${train.id}');

  if (response.statusCode == 200) {
    return trainInfo.fromJson(response.data);
  } else {
    throw Exception('Failed to Load');
  }
}

void toastmessage(int type) {
  Fluttertoast.showToast(
    msg: type == 1 ? '갤러리 저장 완료' : "다운로드 완료",
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.grey,
    fontSize: 15,
    textColor: Colors.white,
    toastLength: Toast.LENGTH_SHORT,
  );
}

class trainRegistpage extends StatefulWidget {
  trainRegistpage({
    Key? key,
    this.train,
  }) : super(key: key);
  dynamic train;

  @override
  State<trainRegistpage> createState() => _trainRegistPageState();
}

class _trainRegistPageState extends State<trainRegistpage>
    with TickerProviderStateMixin {
  late TabController trainController;
  late Future<trainInfo> futureTrainInfo;
  late List imgList;
  late List videoList;
  late List pdfList;
  @override
  void initState() {
    super.initState();
    trainController = TabController(length: 2, vsync: this);
    futureTrainInfo = loadTrainInfo(widget.train);
    // FlutterDownloader.registerCallback(downloadCallback);
    imgList = loadTrainImage(widget.train.imgUrl);
    videoList = loadTrainVideo(widget.train.videoUrl);
    pdfList = loadTrainPdf(widget.train.pdfUrl);
  }

  @override
  void dispose() {
    super.dispose();
    trainController.dispose();
  }

  _showBottomSortSheet(BuildContext context) async {
    //   videoList = [
    //   'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    //   'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
    // ];
    print(videoList);
    Future<void> downloadAndSaveImage() async {
      for (String imageUrl in imgList) {
        try {
          await GallerySaver.saveImage(imageUrl);
          print('Image saved: $imageUrl');
        } catch (e) {
          print('Error saving image: $imageUrl - $e');
        }
      }
    }

    Future<void> downloadAndSaveVideo() async {
      for (String videoUrl in videoList) {
        try {
          await GallerySaver.saveVideo(videoUrl);
          print('Image saved: $videoUrl');
        } catch (e) {
          print('Error saving image: $videoUrl - $e');
        }
      }
    }

    Future<void> downloadAndSavePdf() async {
      final directory = await getApplicationDocumentsDirectory();
      var savedDirPath = directory.path;
      for (String pdfUrl in pdfList) {
        try {
          await FlutterDownloader.enqueue(
            url: pdfUrl,
            savedDir: savedDirPath,
            saveInPublicStorage: true,
            showNotification: true,
            openFileFromNotification: true,
          );
        } catch (e) {
          print('Error saving image:');
        }
      }
    }

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
                      "다운로드",
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
                  await downloadAndSaveImage();
                  Navigator.pop(context, 1);
                  toastmessage(1);
                  // String dir = (await getApplicationDocumentsDirectory())
                  //     .path; //path provider로 저장할 경로 가져오기
                  // try {
                  //   await FlutterDownloader.enqueue(
                  //     url:
                  //         "https://elib.elib-app-service.o-r.kr:8080/api/v1/media/train/img/download?name=fire_1.png", // file url
                  //     savedDir: '$dir/', // 저장할 dir
                  //     fileName: 'test', // 파일명
                  //     saveInPublicStorage: true, // 동일한 파일 있을 경우 덮어쓰기 없으면 오류발생함!
                  //   );

                  //   print("파일 다운로드 완료");
                  // } catch (e) {
                  //   print("eerror :::: $e");
                  // }
                },
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Icon(
                        Icons.image,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '훈련 이미지 다운로드',
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
                onTap: () async {
                  await downloadAndSaveVideo();
                  Navigator.pop(context, 1);
                  toastmessage(1);
                },
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Icon(
                        Icons.video_file_rounded,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '훈련 영상 다운로드',
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
                onTap: () async {
                  await downloadAndSavePdf();
                  Navigator.pop(context);
                  toastmessage(2);
                },
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'PDF 자료 다운로드',
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

  // static void downloadCallback(String id, int status, int progress) {
  //   print(
  //       'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
  //   final SendPort send =
  //       IsolateNameServer.lookupPortByName('downloader_send_port')!;
  //   send.send([id, status, progress]);
  // }

  @override
  Widget build(BuildContext context) {
    GlobalData.queryHeight = MediaQuery.of(context).size.height;
    GlobalData.queryWidth = MediaQuery.of(context).size.width;
    dynamic train = widget.train;

    String? name = train.name;

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
                  backgroundColor: Color.fromARGB(255, 250, 250, 250),
                  centerTitle: true,
                  title: Title(
                      color: Color.fromRGBO(87, 87, 87, 1),
                      child: Text(
                        '훈련 관리',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () {
                      Navigator.pop(context); // 뒤로가기 버튼 클릭 이벤트 처리
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.download),
                      onPressed: () {
                        _showBottomSortSheet(context);
                      },
                    ),
                  ],
                ),
                body: SafeArea(
                    top: true,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                TabBar(
                                  controller: trainController,
                                  indicatorColor: Colors.green,
                                  indicatorWeight: 3,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  labelColor: Colors.black,
                                  unselectedLabelColor: Colors.grey,
                                  tabs: const [
                                    Tab(
                                      child: Text(
                                        '자료',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Tab(
                                      child: Text(
                                        '영상',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: mediaHeight(context, 1),
                                  child: FutureBuilder<trainInfo>(
                                      future: futureTrainInfo,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError)
                                          return Text('${snapshot.error}');
                                        else if (snapshot.hasData) {
                                          return Container(
                                              width: mediaWidth(context, 1),
                                              child: TabBarView(
                                                controller: trainController,
                                                children: [
                                                  ImageBox(
                                                    train: train,
                                                    trainInfo: snapshot.data,
                                                  ),
                                                  VideoBox(
                                                    train: train,
                                                    trainInfo: snapshot.data,
                                                  ),
                                                ],
                                              ));
                                        }
                                        return Visibility(
                                            visible: false,
                                            child: CircularProgressIndicator());
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )))));
  }
}

List loadTrainImage(imgurl) {
  String baseUrl =
      "https://elib.elib-app-service.o-r.kr:8080/api/v1/media/train/img?name=";

  List imageList = [];
  for (var img in imgurl) {
    imageList.add(baseUrl + img);
  }

  return imageList;
}

List loadTrainPdf(pdfurl) {
  String baseUrl =
      "https://elib.elib-app-service.o-r.kr:8080/api/v1/media/train/pdf/download?name=";

  List pdfList = [];
  for (var pdf in pdfurl) {
    pdfList.add(baseUrl + pdf);
  }

  return pdfList;
}

class ImageBox extends StatefulWidget {
  ImageBox({
    Key? key,
    this.train,
    this.trainInfo,
  }) : super(key: key);

  dynamic train;
  dynamic trainInfo;

  @override
  State<ImageBox> createState() => _ImageBoxState();
}

class _ImageBoxState extends State<ImageBox> {
  late List? imageList;
  PageController controller = PageController();

  final CarouselController _controller = CarouselController();
  int _current = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    imageList = loadTrainImage(widget.train.imgUrl);
  }

  @override
  Widget build(BuildContext context) {
    String imgText = ' 자료훈련 미이수';
    Color imgTextColor = Colors.grey;

    String videoText = ' 영상훈련 미이수';
    Color videoTextColor = Colors.grey;

    if (widget.train.imgComplete == true) {
      imgText = ' 자료훈련 이수완료';
      imgTextColor = Colors.green;
    }

    if (widget.train.videoComplete == true) {
      videoText = ' 영상훈련 이수완료';
      videoTextColor = Colors.green;
    }

    bool trainDate = false;
    double boxHeight = 5;
    if (widget.train.imgComplete == true &&
        widget.train.videoComplete == true) {
      trainDate = true;
      boxHeight = 0;
    }

    return Center(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: imgTextColor,
                    size: 20,
                  ),
                  Text(
                    imgText,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: videoTextColor,
                    size: 20,
                  ),
                  Text(
                    videoText,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        //SizedBox(height: 10),

        Container(
          width: mediaWidth(context, 1),
          height: mediaWidth(context, 1),
          child: imageSlide(),
        ),

        Visibility(
          visible: trainDate,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '이수날짜  ${widget.trainInfo.updated} ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: boxHeight),
        imageIndicator(),

        SizedBox(height: 20),
      ],
    ));
  }

  onchanged(int index) {
    setState(() async {
      _current = index + 1;

      if (_current == imageList!.length && widget.trainInfo.imgCount < 1) {
        print("----------");

        final storage = FlutterSecureStorage();
        final accessToken = await storage.read(key: 'ACCESS_TOKEN');
        var dio = await authDio();
        dio.options.headers['Authorization'] = '$accessToken';
        final response = await dio
            .post('/api/v1/user/train/${widget.trainInfo.trains_id}/image');

        dynamic newTrain = widget.train;
        newTrain.imgComplete = true;

        if (response.statusCode == 200) {
          setState(() {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => trainRegistpage(
                          train: newTrain,
                        )));
          });
        } else {
          throw Exception('Failed to Load');
        }
      }
    });
  }

  Widget imageSlide() {
    return PageView.builder(
      onPageChanged: onchanged,
      scrollDirection: Axis.horizontal,
      controller: controller,
      itemCount: imageList!.length,
      itemBuilder: (context, index) {
        return Container(
            width: mediaWidth(context, 1),
            height: mediaWidth(context, 1),
            child: InteractiveViewer(
              child: Image(
                fit: BoxFit.fill,
                image: NetworkImage(
                  imageList![index],
                ),
              ),
            ));
      },
    );
  }

  Widget imageIndicator() {
    return SmoothPageIndicator(
        controller: controller, // PageController
        count: imageList!.length,
        effect: SwapEffect(
          activeDotColor: Colors.green,
          dotColor: Colors.grey.shade400,
          radius: 10,
          dotHeight: 10,
          dotWidth: 10,
        ), // your preferred effect
        onDotClicked: (index) {});
  }
}

List loadTrainVideo(videourl) {
  String baseUrl =
      "https://elib.elib-app-service.o-r.kr:8080/api/v1/media/train/video?name=";

  List videoList = [];
  for (var video in videourl) {
    videoList.add(baseUrl + video);
  }

  print(videoList);

  return videoList;
}

//Video 리스트뷰
class VideoBox extends StatefulWidget {
  VideoBox({
    Key? key,
    this.train,
    this.trainInfo,
  }) : super(key: key);

  dynamic train;
  dynamic trainInfo;

  @override
  State<VideoBox> createState() => _VideoBoxState();
}

int videoNumber = 0;
var count;

class _VideoBoxState extends State<VideoBox> {
  //late List? videoList;

  List? videoList = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
  ];

  @override
  void initState() {
    super.initState();
    //init();
    videoNumber = videoList!.length;
    count = List.generate(videoNumber, (index) => 0);
  }

  void init() async {
    videoList = loadTrainVideo(widget.train.videoUrl);
  }

  @override
  Widget build(BuildContext context) {
    //dynamic train = widget.train;

    String imgText = ' 자료훈련 미이수';
    Color imgTextColor = Colors.grey;

    String videoText = ' 영상훈련 미이수';
    Color videoTextColor = Colors.grey;

    if (widget.train.imgComplete == true) {
      imgText = ' 자료훈련 이수완료';
      imgTextColor = Colors.green;
    }

    if (widget.train.videoComplete == true) {
      videoText = ' 영상훈련 이수완료';
      videoTextColor = Colors.green;
    }

    bool trainDate = false;
    double boxHeight = 5;
    if (widget.train.imgComplete == true &&
        widget.train.videoComplete == true) {
      trainDate = true;
      boxHeight = 0;
    }

    return Center(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: imgTextColor,
                    size: 20,
                  ),
                  Text(
                    imgText,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: videoTextColor,
                    size: 20,
                  ),
                  Text(
                    videoText,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: mediaWidth(context, 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '한 번에 모든 영상을 시청하여야 이수완료됩니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Container(
          height: mediaHeight(context, 0.8),
          child: ListView.builder(
              itemCount: videoList?.length,
              itemBuilder: (_, index) {
                return VideoPage(
                  videoUrl: videoList?[index],
                  index: index,
                  trainInfo: widget.trainInfo,
                  train: widget.train,
                );
              }),
        ),
      ],
    ));
    //return VideoPage(videoUrl: videoList?[0]);
  }
}

// //videoPage 띄우는
// class VideoPage extends StatefulWidget {
//   final String videoUrl;

//   VideoPage({Key? key, required this.videoUrl}) : super(key: key);

//   @override
//   State<VideoPage> createState() => _VideoPageState();
// }

// class _VideoPageState extends State<VideoPage> {
//   late VideoPlayerController _controller;
//   late Future<void> _initailizedController;

//   Future initializeVideo() async {
//     Uri videoUri = Uri.parse(widget.videoUrl);
//     _controller = VideoPlayerController.networkUrl(videoUri);
//     _initailizedController = _controller.initialize();

//     setState(() { });
//   }

//   @override
//   void initState() {
//     initializeVideo();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _initailizedController,
//       builder: (_, snapshot) {
//         return AspectRatio(
//             aspectRatio: _controller.value.aspectRatio,
//             child: GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     if (_controller.value.isPlaying) {
//                       _controller.pause();
//                     } else {
//                       _controller.play();
//                     }
//                   });
//                 },
//                 child: VideoPlayer(_controller)));
//       },
//     );
//   }
// }

//videoPage 띄우는
class VideoPage extends StatefulWidget {
  final String videoUrl;
  final int index;
  dynamic trainInfo;
  dynamic train;

  VideoPage({
    Key? key,
    required this.videoUrl,
    required this.index,
    required this.trainInfo,
    required this.train,
  }) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  Future initializeVideo() async {
    Uri videoUri = Uri.parse(widget.videoUrl);
    videoPlayerController = VideoPlayerController.networkUrl(videoUri);
    await videoPlayerController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      looping: false,
    );

    videoPlayerController.addListener(() async {
      if (videoPlayerController.value.position ==
          videoPlayerController.value.duration) {
        count[widget.index] = 1;

        if (widget.trainInfo.videoCount < 1) {
          if (count.any((e) => e == 0) == true) {
            return;
          } else {
            //widget.train말고 새로 통신하기, imagebox도!!
            final storage = FlutterSecureStorage();
            final accessToken = await storage.read(key: 'ACCESS_TOKEN');
            var dio = await authDio();
            dio.options.headers['Authorization'] = '$accessToken';

            final response = await dio
                .post('/api/v1/user/train/${widget.trainInfo.trains_id}/video');

            dynamic newTrain = widget.train;
            newTrain.videoComplete = true;

            if (response.statusCode == 200) {
              setState(() {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => trainRegistpage(
                              train: newTrain,
                            )));
              });
            } else {
              throw Exception('Failed to Load');
            }
          }
        }
      }
    });

    setState(() {});
  }

  @override
  void initState() {
    initializeVideo();
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (chewieController == null) {
      return Visibility(
        visible: false,
        child: CircularProgressIndicator(),
      );
    } else
      return Column(
        children: [
          Container(
            height: mediaHeight(context, 0.3),
            child: Chewie(
              controller: chewieController!,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${widget.index + 1} / $videoNumber',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
        ],
      );
  }
}
