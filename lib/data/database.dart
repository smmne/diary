import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'diaryreview.dart';

class DatabaseHelper {
  static final _databaseName = "diaryreview.db";
  static final _databaseVersion = 1;
  static final diaryTable = "diaryreview";

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();

    return _database;
  }

  _initDatabase() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $diaryTable (
        date INTEGER DEFAULT 0,
        status INTEGER DEFAULT 0,
        title String,
        memo String,
        image String
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // diary 입력, 수정 불러오기 기능
  Future<int> insertDiary(Diary diaryreview) async {
    Database db = await instance.database;

    List<Diary> d = await getDiaryByDate(diaryreview.date);

    if (d.isEmpty) {
      Map<String, dynamic> row = {
        // 새로 추가
        "title": diaryreview.title,
        "date": diaryreview.date,
        "status": diaryreview.status,
        "memo": diaryreview.memo,
        "image": diaryreview.image,
      };
      print(row);
      return await db.insert(diaryTable, row);
    } else {
      Map<String, dynamic> row = {
        // 수정
        "title": diaryreview.title,
        "date": diaryreview.date,
        "status": diaryreview.status,
        "memo": diaryreview.memo,
        "image": diaryreview.image,
      };

      return await db.update(diaryTable, row,
          where: "date = ?", whereArgs: [diaryreview.date]);
    }
  }

  // diary 리스트 전체를 불러오는 기능
  Future<List<Diary>> getAllDiary() async {
    Database db = await instance.database;
    List<Diary> diaries = [];

    var queries = await db.query(diaryTable);

    for (var q in queries) {
      diaries.add(Diary(
        title: q["title"],
        date: q["date"],
        status: q["status"],
        memo: q["memo"],
        image: q["image"],
      ));
    }

    return diaries;
  }

  Future<List<Diary>> getDiaryByDate(int date) async {
    Database db = await instance.database;
    List<Diary> diaries = [];

    var queries =
        await db.query(diaryTable, where: "date = ?", whereArgs: [date]);

    for (var q in queries) {
      diaries.add(Diary(
        title: q["title"],
        date: q["date"],
        status: q["status"],
        memo: q["memo"],
        image: q["image"],
      ));
    }

    return diaries;
  }
}
