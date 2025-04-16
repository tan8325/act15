import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _loading = true;
  String _selected = '';
  bool get _isAnswered => _selected.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final q = await ApiService.fetchQuestions();
      setState(() {
        _questions = q;
        _loading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void _select(String option) {
    if (_isAnswered) return;
    final correct = _questions[_currentIndex].correctAnswer;
    setState(() {
      _selected = option;
      if (option == correct) _score++;
    });
  }

  void _next() {
    setState(() {
      _currentIndex++;
      _selected = '';
    });
  }

  Color _buttonColor(String option) {
    final correct = _questions[_currentIndex].correctAnswer;
    if (!_isAnswered) return Colors.blue.shade600;
    if (option == correct) return Colors.green;
    if (option == _selected) return Colors.red;
    return Colors.grey.shade300;
  }

  Widget _option(String option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: () => _select(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: _buttonColor(option),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(option, textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentIndex >= _questions.length) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉 Quiz Completed!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Score: $_score / ${_questions.length}', style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivia Quiz'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Question ${_currentIndex + 1} of ${_questions.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(q.question, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),
            ...q.options.map(_option),
            const SizedBox(height: 24),
            if (_isAnswered)
              Text(
                _selected == q.correctAnswer ? '✅ Correct!' : '❌ Correct: ${q.correctAnswer}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _selected == q.correctAnswer ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            if (_isAnswered)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Next Question', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
