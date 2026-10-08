class Question {
  String questionSpanish;
  String questionKichwa;
  String questionType;
  late dynamic correctAnswer; // ahora puede ser String o List<String>
  String selectedOption = 'Skipped';
  bool isCorrect = false;
  String audioPath;
  String imagePath;
  List<dynamic> optionList = [];
  List<dynamic>? words;
  List<dynamic>? correctOrder;

  static String _readPath(dynamic v) {
    if (v == null) return '';
    if (v is List) return v.isNotEmpty ? v.first.toString() : '';
    return v.toString();
  }

  Question.fromJson(Map<String, dynamic> json)
      : questionSpanish = json['questionSpanish']?.toString() ?? '',
        questionKichwa = json['questionKichwa']?.toString() ?? '',
        questionType = json['questionType']?.toString() ?? '',
        // normaliza todo a String: en unidad 2 'translate' usa correctOrder como List<bool>
        // y en unidad 6 'flashcard' trae imagePath como List.
        correctAnswer = json['correctAnswer'] is List
            ? (json['correctAnswer'] as List).map((e) => e.toString()).toList()
            : (json['correctAnswer']?.toString() ?? ''),
        optionList = json['optionList'] != null
            ? (json['optionList'] as List).map((e) => e.toString()).toList()
            : [],
        audioPath = _readPath(json['audioPath']),
        imagePath = _readPath(json['imagePath']),
        words = json['words'] != null
            ? (json['words'] as List).map((e) => e.toString()).toList()
            : null,
        correctOrder = json['correctOrder'] != null
            ? (json['correctOrder'] as List).map((e) => e.toString()).toList()
            : null;

  // Comprueba la respuesta del usuario, soportando correctAnswer como String o List<String>
  bool checkAnswer(dynamic userAnswer) {
    if (correctAnswer is List) {
      final List<String> correct = (correctAnswer as List).map((e) => e.toString().trim().toLowerCase()).toList();
      List<String> given;
      if (userAnswer is List) {
        given = userAnswer.map((e) => e.toString().trim().toLowerCase()).toList();
      } else {
        // si el usuario envía una oración en String la dividimos por espacios
        given = userAnswer.toString().split(RegExp(r'\s+')).map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toList();
      }
      return _listEquals(correct, given);
    } else {
      return correctAnswer.toString().trim().toLowerCase() == userAnswer.toString().trim().toLowerCase();
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
