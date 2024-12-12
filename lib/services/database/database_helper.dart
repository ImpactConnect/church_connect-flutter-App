import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'church_connect.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE Notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        markdown_content TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Sermons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        preacher TEXT NOT NULL,
        category TEXT NOT NULL,
        topics TEXT,
        description TEXT,
        audio_url TEXT NOT NULL,
        is_local INTEGER NOT NULL,
        date TEXT NOT NULL,
        duration INTEGER NOT NULL
      )
    ''');

    // Add these categories for initial data
    await db.execute('''
      INSERT INTO Sermons (title, preacher, category, topics, description, audio_url, is_local, date, duration)
      VALUES 
        ('Sample Sermon 1', 'Pastor John', 'Sunday Service', 'Faith,Prayer', 'Description here', 'path/to/audio1.mp3', 0, '2024-03-10T10:00:00.000Z', 1800),
        ('Sample Sermon 2', 'Pastor Mike', 'Bible Study', 'Love,Grace', 'Description here', 'path/to/audio2.mp3', 0, '2024-03-09T18:30:00.000Z', 3600)
    ''');

    // Add more tables as needed

    await db.execute('''
      CREATE TABLE Events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        location TEXT NOT NULL,
        image_url TEXT,
        category TEXT NOT NULL,
        is_recurring INTEGER NOT NULL DEFAULT 0,
        recurrence_rule TEXT,
        requires_registration INTEGER NOT NULL DEFAULT 0,
        max_attendees INTEGER,
        current_attendees INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Add sample events
    await db.execute('''
      INSERT INTO Events (
        title, description, start_date, end_date, location, category,
        is_recurring, requires_registration
      )
      VALUES 
        ('Sunday Service', 'Weekly Sunday worship service', 
         '2024-03-17 09:00:00', '2024-03-17 11:00:00', 'Main Sanctuary', 
         'Worship Service', 1, 0),
        ('Youth Bible Study', 'Weekly youth Bible study and fellowship', 
         '2024-03-20 18:00:00', '2024-03-20 19:30:00', 'Youth Room', 
         'Bible Study', 1, 0),
        ('Easter Service', 'Special Easter Sunday celebration', 
         '2024-03-31 09:00:00', '2024-03-31 12:00:00', 'Main Sanctuary', 
         'Special Service', 0, 0)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add markdown_content column to existing Notes table
      await db.execute('ALTER TABLE Notes ADD COLUMN markdown_content TEXT');
    }
  }
}
