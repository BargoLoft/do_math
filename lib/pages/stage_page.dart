import 'dart:async';

import 'package:do_math/const/const.dart';
import 'package:do_math/problems/1-1.dart';
import 'package:do_math/widgets/count_down.dart';
import 'package:flutter/material.dart';
import '../problems/1-1.dart';

// ignore: must_be_immutable
class StagePage extends StatefulWidget {
  String type;
  int digital;

  StagePage({
    required this.type,
    required this.digital,
    Key? key,
  }) : super(key: key);

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  late AnimationController _countController;

  late List<int> questions;
  String question = '';
  late int answer;
  int currentNumber = 0;
  int currentAnswer = 0;

  Duration duration = Duration();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    _countController = AnimationController(vsync: this, duration: Duration(seconds: limitTime));
    _countController.addListener(() {
      if (_countController.isCompleted) {
        Next(false);
      }
    });
    _countController.forward();
    getNewQuestion();
  }

  @override
  void dispose() {
    if (_countController.isAnimating || _countController.isCompleted) {
      _countController.dispose();
    }
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    const addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  void refreshStage() {
    currentNumber = 0;
    currentAnswer = 0;
    duration = const Duration(seconds: 0);
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
    getNewQuestion();
    _countController.forward();
    setState(() {});
  }

  void Next(bool OX) {
    _textController.clear();
    _countController.reset();
    _countController.forward();
    currentNumber += 1;
    if (OX) currentAnswer++;
    if (currentNumber == 10) {
      _countController.stop();
      timer?.cancel();
      showResultPopup();
    } else {
      getNewQuestion();
    }
    // modal 팝업으로 기록이랑 다시하기, 나가기, 랭킹 화면 보여주기
    //Navigator.pop(context);
    setState(() {});
  }

  void getNewQuestion() {
    if (widget.type == '+') {
      getPlusQuestion();
    } else if (widget.type == '-') {
      getMinusQuestion();
    } else if (widget.type == '×') {
      getMultiQuestion();
    } else if (widget.type == '÷') {
      getDivideQuestion();
    }
  }

  void getPlusQuestion() {
    questions = PlusQuestion(count: 2, digital: widget.digital).getQuestion();
    question = '';
    for (int i = 0; i < questions.length; i++) {
      question += questions[i].toString();
      if (i != questions.length - 1) {
        question += '+';
      }
      answer = questions.fold(0, (total, element) {
        return total + element;
      });
    }
    print('${questions.toString()} $answer');
  }

  void getMinusQuestion() {
    questions = MinusQuestion(count: 2, digital: widget.digital).getQuestion();
    question = '';
    for (int i = 0; i < questions.length; i++) {
      question += questions[i].toString();
      if (i != questions.length - 1) {
        question += '-';
      }
      answer = questions.fold(questions[0] + questions[0], (total, element) {
        return total - element;
      });
    }
    print('${questions.toString()} $answer');
  }

  void getMultiQuestion() {
    questions = MultiQuestion(count: 2, digital: widget.digital).getQuestion();
    question = '';
    for (int i = 0; i < questions.length; i++) {
      question += questions[i].toString();
      if (i != questions.length - 1) {
        question += '×';
      }
      answer = questions.fold(1, (total, element) {
        return total * element;
      });
    }
    print('${questions.toString()} $answer');
  }

  void getDivideQuestion() {
    questions = DivideQuestion(count: 2, digital: widget.digital).getQuestion();
    question = '';
    for (int i = 0; i < questions.length; i++) {
      question += questions[i].toString();
      if (i != questions.length - 1) {
        question += '÷';
      }
      answer = questions.fold(questions[0] * questions[0], (total, element) {
        return total ~/ element;
      });
    }
    print('${questions.toString()} $answer');
  }

  void showResultPopup() {
    showDialog(
        context: context,
        barrierColor: Colors.white.withOpacity(0.6),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50.0))),
            child: AspectRatio(
              aspectRatio: 10 / 11,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: currentAnswer.toString(),
                          style: TextStyle(
                            fontSize: 100,
                            color: currentAnswer >= 4 ? Colors.blue : Colors.red,
                          ),
                          children: const [
                            TextSpan(
                                text: '/10',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.grey,
                                )),
                          ],
                        ),
                      ),
                      Text(
                          '걸린 시간 : ${duration.inMinutes.toString().padLeft(2, '0')}\'${duration.inSeconds.toString().padLeft(2, '0')}\'\'${(duration.inMicroseconds ~/ 1000).toString().padLeft(2, '0')}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            iconSize: 40,
                            onPressed: () {
                              _countController.dispose();
                              timer?.cancel();
                              Navigator.pop(context); // pushNamed로 한 번에 가도록 변경
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.home_rounded),
                          ),
                          IconButton(
                            iconSize: 60,
                            onPressed: () {
                              Navigator.pop(context); // pushNamed로 한 번에 가도록 변경
                              refreshStage();
                            },
                            icon: const Icon(Icons.refresh_rounded),
                          ),
                          IconButton(
                            iconSize: 30,
                            onPressed: () {
                              Navigator.pop(context); // pushNamed로 한 번에 가도록 변경
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.leaderboard_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {});
                  },
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            Stack(
              children: [
                Container(
                  height: 2,
                  color: Colors.grey.shade200,
                ),
                Container(
                  width: (MediaQuery.of(context).size.width) * 0.1 * currentNumber,
                  height: 2,
                  color: Colors.green,
                ),
                Countdown(animation: StepTween(begin: limitTime, end: 0).animate(_countController)),
                Text('${duration.inSeconds}'),
              ],
            ),
            Expanded(
              flex: 4,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      question,
                      style: const TextStyle(fontSize: 40, letterSpacing: 2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        '= ',
                        style: TextStyle(fontSize: 40),
                      ),
                      SizedBox(
                        height: 60,
                        width: 150,
                        child: TextField(
                          enabled: false,
                          controller: _textController,
                          maxLines: 1,
                          //textAlign: TextAlign.center,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          //expands: true,
                          //textCapitalization: TextCapitalization.words,
                          //maxLength: 10,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      ),
                      Text(
                        ' =',
                        style: TextStyle(fontSize: 40, color: Colors.grey.shade50),
                      ),
                    ],
                  ),
                ],
              )),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        buildNumber('1'),
                        buildNumber('2'),
                        buildNumber('3'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildNumber('4'),
                        buildNumber('5'),
                        buildNumber('6'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildNumber('7'),
                        buildNumber('8'),
                        buildNumber('9'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildNumber('←'),
                        buildNumber('0'),
                        buildNumber('C'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNumber(String num) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (num == '←' && _textController.text.isNotEmpty) {
            _textController.text =
                _textController.text.substring(0, _textController.text.length - 1);
          } else if (num == 'C') {
            _textController.clear();
          } else if (num != '←') {
            _textController.text += num;
            if (_textController.text == answer.toString()) {
              Next(true);
            }
          }
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * (1 / 3),
          height: MediaQuery.of(context).size.height * (0.11),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 30,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
