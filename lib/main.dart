import 'package:diaryreview/data/database.dart';
import 'package:diaryreview/data/util.dart';
import 'package:diaryreview/write.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'data/diaryreview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectIndex = 0;
  final dbHelper = DatabaseHelper.instance;
  Diary todayDiary;
  Diary historyDiary;
  List<Diary> allDiaries = [];
  List<String> statusImg = [
    "assets/img/ico-weather.png",
    "assets/img/ico-weather_2.png",
    "assets/img/ico-weather_3.png",
  ];
  DateTime time = DateTime.now();

  final calendarController = CalendarController();

  void getTodayDiary() async {
    List<Diary> diaryreview =
        await dbHelper.getDiaryByDate(Utils.getFormatTime(DateTime.now()));
    if (diaryreview.isNotEmpty) {
      todayDiary = diaryreview.first;
    }

    setState(() {});
  }

  void getAllDiary() async {
    allDiaries = await dbHelper.getAllDiary();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getTodayDiary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (selectIndex == 0) {
            Diary _d;
            if (todayDiary != null) {
              _d = todayDiary;
            } else {
              _d = Diary(
                date: Utils.getFormatTime(DateTime.now()),
                title: "",
                memo: "",
                status: 0,
                image: "assets/img/d4.jpg",
              );
            }
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => DiaryWritePage(diaryreview: _d)));
            getTodayDiary();
          } else {
            Diary _d;
            if (historyDiary != null) {
              _d = historyDiary;
            } else {
              _d = Diary(
                date: Utils.getFormatTime(time),
                title: "",
                memo: "",
                status: 0,
                image: "assets/img/d4.jpg",
              );
            }
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => DiaryWritePage(diaryreview: _d)));
            getDiaryByDate(time);
          }
        },
        tooltip: "increment",
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: "오늘"),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined), label: "기록"),
          BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart_outlined), label: "통계"),
        ],
        currentIndex: selectIndex,
        onTap: (idx) {
          setState(() {
            selectIndex = idx;
            if (selectIndex == 1) {
              getDiaryByDate(time);
            } else if (selectIndex == 2) {
              getAllDiary();
            }
          });
        },
      ),
    );
  }

  Widget getPage() {
    if (selectIndex == 0) {
      return getTodayPage();
    } else if (selectIndex == 1) {
      return getHistoryPage();
    } else {
      return getChartPage();
    }
  }

  Widget getTodayPage() {
    if (todayDiary == null) {
      return const Text("일기 작성 해줘요 ~~~~");
    }
    return Stack(
      children: [
        Positioned.fill(
            child: Image.asset(
          todayDiary.image,
          fit: BoxFit.cover,
        )),
        Positioned.fill(
          child: ListView(
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${DateTime.now().year}.${Utils.makeTwoDigit(DateTime.now().month)}.${Utils.makeTwoDigit(DateTime.now().day)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Image.asset(
                      statusImg[todayDiary.status],
                    )
                  ],
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(todayDiary.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(todayDiary.memo, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void getDiaryByDate(DateTime date) async {
    List<Diary> d = await dbHelper.getDiaryByDate(Utils.getFormatTime(date));
    setState(() {
      if (d.isEmpty) {
        historyDiary = null;
      } else {
        historyDiary = d.first;
      }
    });
  }

  Widget getHistoryPage() {
    return ListView.builder(
      itemBuilder: (ctx, idx) {
        if (idx == 0) {
          return TableCalendar(
            calendarController: calendarController,
            onDaySelected: (date, events, holidays) {
              time = date;
              getDiaryByDate(date);
            },
          );
        } else if (idx == 1) {
          if (historyDiary == null) {
            return Container();
          }
          return Column(
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${time.year}.${Utils.makeTwoDigit(time.month)}.${Utils.makeTwoDigit(time.day)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Image.asset(
                      statusImg[historyDiary.status],
                      fit: BoxFit.contain,
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      historyDiary.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      historyDiary.memo,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Image.asset(
                      historyDiary.image,
                      fit: BoxFit.cover,
                    )
                  ],
                ),
              ),
            ],
          );
        }
        return Container();
      },
      itemCount: 2,
    );
  }

  Widget getChartPage() {
    return ListView.builder(
      itemBuilder: (ctx, idx) {
        if (idx == 0) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(statusImg.length, (_idx) {
                return Column(
                  children: [
                    Image.asset(statusImg[_idx],
                        fit: BoxFit.contain, width: 60, height: 60),
                    Text(
                        "${allDiaries.where((element) => element.status == _idx).length}개"),
                  ],
                );
              }),
            ),
          );
        } else if (idx == 1) {
          return SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: List.generate(allDiaries.length, (_idx) {
                return Container(
                  height: 100,
                  width: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Image.asset(
                    allDiaries[_idx].image,
                    fit: BoxFit.cover,
                  ),
                );
              }),
            ),
          );
        }
        return Container();
      },
      itemCount: 5,
    );
  }
}
