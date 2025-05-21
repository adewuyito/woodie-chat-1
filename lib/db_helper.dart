import "package:sqflite/sqflite.dart";
import "package:path/path.dart";

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("chatbot.db");
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 3, onCreate: _createDB);
  }

  static Future _createDB(Database db, int version) async {
    await db.execute("""
      CREATE TABLE qa(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT,
        answer TEXT
      )
    """);
    await db.insert('qa', {
      'question': 'what smart speakers do you have?',
      'answer':
          'We offer several smart speakers including the Echo series from Amazon (Echo Dot, Echo Show, Echo Studio), Google Nest speakers, and Apple HomePod models.',
    });

    await db.insert('qa', {
      'question': 'what is the cheapest smart speaker?',
      'answer':
          'Our most affordable smart speaker is the Echo Dot 5th generation at \$49.99, but we often have special promotions bringing the price down to \$29.99.',
    });

    await db.insert('qa', {
      'question': 'which smart speaker has the best sound quality?',
      'answer':
          'For premium sound quality, the Sonos One and Apple HomePod deliver exceptional audio performance. The Echo Studio is also excellent for its price range.',
    });

    await db.insert('qa', {
      'question': 'do you sell smart bulbs?',
      'answer':
          'Yes, we carry a wide selection of smart bulbs including Philips Hue, LIFX, Wyze, and TP-Link Kasa smart bulbs in various colors and configurations.',
    });

    await db.insert('qa', {
      'question': 'what is the price of philips hue?',
      'answer':
          'Philips Hue starter kits begin at \$99.99 for the basic white kit (including hub and 2 bulbs). Individual color bulbs start at \$49.99, while white bulbs start at \$19.99.',
    });

    await db.insert('qa', {
      'question': 'which smart bulbs work without a hub?',
      'answer':
          'LIFX, TP-Link Kasa, and Wyze bulbs connect directly to your WiFi without requiring a separate hub. These are great options for beginners or smaller setups.',
    });

    await db.insert('qa', {
      'question': 'what smart thermostats do you sell?',
      'answer':
          'We offer Google Nest Learning Thermostat, ecobee SmartThermostat, Amazon Smart Thermostat, and Honeywell Home T9 Smart Thermostat.',
    });

    await db.insert('qa', {
      'question': 'which is the best smart thermostat?',
      'answer':
          'The Google Nest Learning Thermostat and ecobee SmartThermostat are our top-rated models. Nest is known for its learning capabilities, while ecobee offers superior room sensors.',
    });
  }

  static Future<String?> getAnswer(String question) async {
    final db = await database;
    final result = await db.query(
      "qa",
      where: "LOWER(question) = ?",
      whereArgs: [question.toLowerCase()],
    );
    if (result.isNotEmpty) {
      return result.first["answer"] as String;
    }
    return "Sorry, I don't understand that question.";
  }

  static Future<void> deleteAllData() async {
    final db = await database;
    await db.delete("qa");
  }

  static Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "chatbot.db");
    await databaseFactory.deleteDatabase(path);
  }

  static Future<void> resetDatabase() async {
    await deleteDatabaseFile();
    _database = await _initDB("chatbot.db");
  }
}
