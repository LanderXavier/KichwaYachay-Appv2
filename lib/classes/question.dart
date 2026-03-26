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

  Question.fromJson(Map<String, dynamic> json)
      : questionSpanish = json['questionSpanish'],
        questionKichwa = json['questionKichwa'],
        questionType = json['questionType'],
        // normaliza correctAnswer: si viene como lista la convertimos a List<String>, si viene como String la dejamos así
        correctAnswer = json['correctAnswer'] is List
            ? List<String>.from(json['correctAnswer'])
            : (json['correctAnswer']?.toString() ?? ''),
        optionList = json['optionList'] != null ? List<String>.from(json['optionList']) : [],
        audioPath = json['audioPath'] ?? '',
        imagePath = json['imagePath'] ?? '',
        words = json['words'] != null ? List<String>.from(json['words']) : null,
        correctOrder = json['correctOrder'] != null ? List<String>.from(json['correctOrder']) : null;

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
