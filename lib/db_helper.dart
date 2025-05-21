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
        answer TEXT,
        keywords TEXT
      )
    """);
    
    // Smart Speakers
    await db.insert('qa', {
      'question': 'what smart speakers do you have?',
      'answer': 'We offer several smart speakers including the Echo series from Amazon (Echo Dot, Echo Show, Echo Studio), Google Nest speakers, and Apple HomePod models.',
      'keywords': 'smart speakers,echo,google nest,homepod,alexa,what speakers,which speakers,available speakers,speaker options'
    });
    
    await db.insert('qa', {
      'question': 'what is the cheapest smart speaker?',
      'answer': 'Our most affordable smart speaker is the Echo Dot 5th generation at \$49.99, but we often have special promotions bringing the price down to \$29.99.',
      'keywords': 'cheapest speaker,affordable speaker,budget speaker,lowest price speaker,cheap smart speaker,inexpensive speaker,price'
    });
    
    await db.insert('qa', {
      'question': 'which smart speaker has the best sound quality?',
      'answer': 'For premium sound quality, the Sonos One and Apple HomePod deliver exceptional audio performance. The Echo Studio is also excellent for its price range.',
      'keywords': 'best sound quality,best audio,premium sound,high quality sound,sound quality,audio quality,best speaker sound'
    });
    
    // Smart Bulbs
    await db.insert('qa', {
      'question': 'do you sell smart bulbs?',
      'answer': 'Yes, we carry a wide selection of smart bulbs including Philips Hue, LIFX, Wyze, and TP-Link Kasa smart bulbs in various colors and configurations.',
      'keywords': 'smart bulbs,light bulbs,smart lights,philips hue,lifx,wyze,tp-link,kasa,smart lighting,bulbs available'
    });
    
    await db.insert('qa', {
      'question': 'what is the price of philips hue?',
      'answer': 'Philips Hue starter kits begin at \$99.99 for the basic white kit (including hub and 2 bulbs). Individual color bulbs start at \$49.99, while white bulbs start at \$19.99.',
      'keywords': 'philips hue price,hue cost,philips hue cost,hue pricing,how much philips hue,philips hue starter kit price'
    });
    
    await db.insert('qa', {
      'question': 'which smart bulbs work without a hub?',
      'answer': 'LIFX, TP-Link Kasa, and Wyze bulbs connect directly to your WiFi without requiring a separate hub. These are great options for beginners or smaller setups.',
      'keywords': 'bulbs without hub,no hub required,wifi bulbs,direct wifi bulbs,hub-free bulbs,bulbs no hub needed'
    });
    
    // Smart Thermostats
    await db.insert('qa', {
      'question': 'what smart thermostats do you sell?',
      'answer': 'We offer Google Nest Learning Thermostat, ecobee SmartThermostat, Amazon Smart Thermostat, and Honeywell Home T9 Smart Thermostat.',
      'keywords': 'smart thermostats,nest thermostat,ecobee,honeywell,amazon thermostat,thermostats available,what thermostats'
    });
    
    await db.insert('qa', {
      'question': 'which is the best smart thermostat?',
      'answer': 'The Google Nest Learning Thermostat and ecobee SmartThermostat are our top-rated models. Nest is known for its learning capabilities, while ecobee offers superior room sensors.',
      'keywords': 'best thermostat,top thermostat,recommended thermostat,best smart thermostat,which thermostat,thermostat recommendation'
    });
    
    // General/Greeting responses
    await db.insert('qa', {
      'question': 'hello',
      'answer': 'Hello! Welcome to our Smart Home Assistant. I can help you find information about smart speakers, bulbs, thermostats, and other smart home devices. What would you like to know?',
      'keywords': 'hello,hi,hey,greetings,good morning,good afternoon,good evening'
    });
    
    await db.insert('qa', {
      'question': 'help',
      'answer': 'I can help you with information about:\n• Smart speakers (Echo, Google Nest, HomePod)\n• Smart bulbs (Philips Hue, LIFX, Wyze)\n• Smart thermostats (Nest, ecobee, Honeywell)\n• Pricing and product comparisons\n\nJust ask me anything about these products!',
      'keywords': 'help,assistance,what can you do,how can you help,support,guide'
    });
  }
  
  static Future<String?> getAnswer(String question) async {
    final db = await database;
    
    // Clean and normalize the input question
    String normalizedQuestion = _normalizeText(question);
    
    // Strategy 1: Try exact match first
    final exactResult = await db.query(
      "qa",
      where: "LOWER(question) = ?",
      whereArgs: [normalizedQuestion],
    );
    
    if (exactResult.isNotEmpty) {
      return exactResult.first["answer"] as String;
    }
    
    // Strategy 2: Try keyword matching
    final keywordResult = await _findByKeywords(db, normalizedQuestion);
    if (keywordResult != null) {
      return keywordResult;
    }
    
    // Strategy 3: Try partial matching
    final partialResult = await _findByPartialMatch(db, normalizedQuestion);
    if (partialResult != null) {
      return partialResult;
    }
    
    // Strategy 4: Try similarity matching
    final similarityResult = await _findBySimilarity(db, normalizedQuestion);
    if (similarityResult != null) {
      return similarityResult;
    }
    
    return "Sorry, I don't understand that question. I can help you with information about smart speakers, bulbs, thermostats, and their pricing. Try asking about specific products or saying 'help' for more options.";
  }
  
  static String _normalizeText(String text) {
    return text.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();
  }
  
  static Future<String?> _findByKeywords(Database db, String question) async {
    final allRows = await db.query("qa");
    
    for (final row in allRows) {
      final keywords = row["keywords"] as String?;
      if (keywords != null) {
        final keywordList = keywords.split(',').map((k) => k.trim().toLowerCase()).toList();
        
        // Check if any keyword is contained in the question
        for (final keyword in keywordList) {
          if (question.contains(keyword) || keyword.contains(question)) {
            return row["answer"] as String;
          }
        }
      }
    }
    
    return null;
  }
  
  static Future<String?> _findByPartialMatch(Database db, String question) async {
    final allRows = await db.query("qa");
    
    for (final row in allRows) {
      final dbQuestion = _normalizeText(row["question"] as String);
      
      // Check if question words are in the database question
      final questionWords = question.split(' ');
      final dbQuestionWords = dbQuestion.split(' ');
      
      int matchCount = 0;
      for (final word in questionWords) {
        if (word.length > 2 && dbQuestionWords.contains(word)) { // Only count words longer than 2 chars
          matchCount++;
        }
      }
      
      // If more than 60% of words match, consider it a match
      if (questionWords.length > 0 && matchCount / questionWords.length > 0.6) {
        return row["answer"] as String;
      }
    }
    
    return null;
  }
  
  static Future<String?> _findBySimilarity(Database db, String question) async {
    final allRows = await db.query("qa");
    
    // Define key terms for different categories
    final Map<String, List<String>> categories = {
      'speakers': ['speaker', 'echo', 'alexa', 'google', 'nest', 'homepod', 'apple', 'audio', 'sound'],
      'bulbs': ['bulb', 'light', 'lighting', 'hue', 'lifx', 'wyze', 'kasa', 'philips'],
      'thermostats': ['thermostat', 'temperature', 'heating', 'cooling', 'nest', 'ecobee', 'honeywell'],
      'price': ['price', 'cost', 'cheap', 'expensive', 'affordable', 'budget', 'money'],
      'best': ['best', 'top', 'recommend', 'good', 'quality', 'better']
    };
    
    // Find which category the question belongs to
    String? detectedCategory;
    for (final category in categories.keys) {
      for (final term in categories[category]!) {
        if (question.contains(term)) {
          detectedCategory = category;
          break;
        }
      }
      if (detectedCategory != null) break;
    }
    
    if (detectedCategory != null) {
      // Find the best matching question in that category
      for (final row in allRows) {
        final dbQuestion = _normalizeText(row["question"] as String);
        final keywords = row["keywords"] as String? ?? '';
        
        // Check if this row relates to the detected category
        bool isRelevant = false;
        for (final term in categories[detectedCategory]!) {
          if (dbQuestion.contains(term) || keywords.toLowerCase().contains(term)) {
            isRelevant = true;
            break;
          }
        }
        
        if (isRelevant) {
          return row["answer"] as String;
        }
      }
    }
    
    return null;
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