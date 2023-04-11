import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data/database.dart';
import 'data/diaryreview.dart';

class DiaryWritePage extends StatefulWidget {
  final Diary diaryreview;
  DiaryWritePage({Key key, this.diaryreview}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DiaryWritePageState();
  }
}

class _DiaryWritePageState extends State<DiaryWritePage> {
  List<String> images = [
    "assets/img/d1.jpg",
    "assets/img/d2.jpg",
    "assets/img/d3.jpg",
    "assets/img/d4.jpg",
  ];
  List<String> statusImg = [
    "assets/img/ico-weather.png",
    "assets/img/ico-weather_2.png",
    "assets/img/ico-weather_3.png",
  ];
  int imgIndex = 0;

  final dbHelper = DatabaseHelper.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.diaryreview.title;
    memoController.text = widget.diaryreview.memo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              widget.diaryreview.title = nameController.text;
              widget.diaryreview.memo = memoController.text;
              await dbHelper.insertDiary(widget.diaryreview);
              Navigator.of(context).pop();
            },
            child: const Text("저장", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (ctx, idx) {
          if (idx == 0) {
            return InkWell(
              child: Container(
                width: 100,
                height: 100,
                child: Image.asset(widget.diaryreview.image, fit: BoxFit.cover),
              ),
              onTap: () {
                setState(() {
                  widget.diaryreview.image = images[imgIndex];
                  imgIndex++;
                  imgIndex = imgIndex % images.length;
                });
              },
            );
          } else if (idx == 1) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(statusImg.length, (_idx) {
                  return InkWell(
                    child: Container(
                      width: 70,
                      height: 70,
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _idx == widget.diaryreview.status
                              ? Colors.blue
                              : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Image.asset(statusImg[_idx], fit: BoxFit.contain),
                    ),
                    onTap: () {
                      setState(() {
                        widget.diaryreview.status = _idx;
                      });
                    },
                  );
                }),
              ),
            );
          } else if (idx == 2) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text("제목", style: TextStyle(fontSize: 20)),
            );
          } else if (idx == 3) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: TextField(
                controller: nameController,
              ),
            );
          } else if (idx == 4) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text("내용", style: TextStyle(fontSize: 20)),
            );
          } else if (idx == 5) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 1, horizontal: 16),
              child: TextField(
                controller: memoController,
                minLines: 10,
                maxLines: 20,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
            );
          }
          return Container();
        },
        itemCount: 6,
      ),
    );
  }
}
