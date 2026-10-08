class Question {
  final String questionSpanish;
  final String questionKichwa;
  final String correctAnswer;
  final String audioPath;
  final String imagePath;
  final String questionType;
  final List<String> optionList;
  final List<String> words;
  final List<String> correctOrder;

  Question({
    required this.questionSpanish,
    required this.questionKichwa,
    required this.correctAnswer,
    required this.audioPath,
    required this.imagePath,
    required this.questionType,
    required this.optionList,
    required this.words,
    required this.correctOrder,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> strList(dynamic v) {
      if (v == null) return <String>[];
      if (v is List) return v.map((e) => e.toString()).toList();
      return <String>[v.toString()];
    }

    String readPath(dynamic v) {
      if (v == null) return '';
      if (v is List) return v.isNotEmpty ? v.first.toString() : '';
      return v.toString();
    }

    return Question(
      questionSpanish: json['questionSpanish']?.toString() ?? '',
      questionKichwa: json['questionKichwa']?.toString() ?? '',
      correctAnswer: json['correctAnswer'] is List
          ? (json['correctAnswer'] as List).map((e) => e.toString()).join(' ')
          : (json['correctAnswer']?.toString() ?? ''),
      audioPath: readPath(json['audioPath']),
      imagePath: readPath(json['imagePath']),
      questionType: json['questionType']?.toString() ?? '',
      optionList: strList(json['optionList']),
      words: strList(json['words']),
      correctOrder: strList(json['correctOrder']),
    );
  }

  set shuffledOptions(List<String> shuffledOptions) {}

  set correctAnswerIndex(int correctAnswerIndex) {}
}
