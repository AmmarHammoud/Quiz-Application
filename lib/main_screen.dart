import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/gifts_model.dart';
import 'data/questions_bank.dart';
import 'package:flutter_app/shared/components/components.dart';
import 'package:flutter_app/shared/components/constants.dart';
import 'package:flutter_app/shared/styles/colors.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:video_player/video_player.dart';
import 'models/questions_model.dart';
import 'dart:math';
import 'data/gift_bank.dart';
import 'package:restart_app/restart_app.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  static Random randomFirstQuestion = new Random();
  ///Choose first question appears randomly.
  int currentQuestionIndex = randomFirstQuestion.nextInt(Q.length);

  double sliderValue = 0;

  bool correctAnswer = false;

  ///Holding the answers of the current question randomly.
  ///The function [chooseRandomAnswers(list)] returns [answers],
  ///and put it in [randomAnswersList].
  ///The function [chooseRandomAnswers(list)] is called more than one time for same question
  ///when highlighting the answer, but we do not want to show the answers randomly more than
  ///one time for the same question, so it depends on [isCalled].
  ///And that is why [answers] is defined here.
  ///[randomAnswersList] is used for highlighting the correct answer when user chooses incorrect answer.
  bool isCalled = false;
  late List<String> answers;
  late List<String> randomAnswersList;

  final audioPlayer = AssetsAudioPlayer();

  ///This funny video will be played when user makes a mistake at the question before last.
  late VideoPlayerController controller;

  ///Playing video depending on [isNinety].
  bool isNinety = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.asset('assets/videos/hand.mp4')
      ..initialize().then((value) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    if (isNinety) controller.play();
    return Center(
      child: Stack(children: [
        defaultAppBorderDecoration(),
        Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            questionDecoration(),
            buildQuestionWidget(),
            SizedBox(height: 40),
            placingAnswersRandomly(Q[currentQuestionIndex]),
            SizedBox(height: 25),
            Container(width: 125, height: 125, child: buildSlider()),
          ]),
        ),
        if (isNinety)
          Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: VideoPlayer(controller),
                ),
              ))
      ]),
    );
  }

  Widget questionDecoration() => Image.asset(
        'assets/images/decoration/question decoration.png',
        width: 400,
        height: 100,
      );

  Widget buildQuestionWidget() => Container(
        width: 350,
        height: 75,
        color: Colors.blue,
        child: Center(
            child: Text(
          Q[currentQuestionIndex].question,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.bodyText1,
        )),
      );

  Widget placingAnswersRandomly(QuestionModel currentQuestion) {
    print(currentQuestion.rightAnswer);
    randomAnswersList = chooseRandomAnswers([
      currentQuestion.firstAnswer,
      currentQuestion.secondAnswer,
      currentQuestion.thirdAnswer,
      currentQuestion.fourthAnswer
    ]);
    return Column(
      children: [
        buildAnswersWidget(1, firstAnswerColor, randomAnswersList[0]),
        SizedBox(height: 25),
        buildAnswersWidget(2, secondAnswerColor, randomAnswersList[1]),
        SizedBox(height: 25),
        buildAnswersWidget(3, thirdAnswerColor, randomAnswersList[2]),
        SizedBox(height: 25),
        buildAnswersWidget(4, fourthAnswerColor, randomAnswersList[3]),
      ],
    );
  }

  Widget buildSlider() => SleekCircularSlider(
        appearance: CircularSliderAppearance(
            customWidths: CustomSliderWidths(progressBarWidth: 10),
            startAngle: 270,
            angleRange: 360,
            size: 100,
            customColors: CustomSliderColors(progressBarColor: Colors.blue)),
        min: 0,
        max: 100,
        initialValue: sliderValue,
        innerWidget: (double progressValue) {
          return Padding(
              padding: const EdgeInsets.all(15.0),
              child: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/gifts/gift.jpg'),
                  radius: 70));
        },
      );

  List<String> chooseRandomAnswers(List<String> list) {
    if (!isCalled) {
      answers = [];
      list.shuffle();
      answers = list;
      return answers;
    }
    isCalled = false;
    return answers;
  }

  Widget buildAnswersWidget(
          int chosenAnswer, MaterialColor color, String answer) =>
      Container(
        height: 50,
        width: 300,
        child: MaterialButton(
            color: color,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            child: defaultText(context: context, text: answer),
            onPressed: () {
              checkAnswer(Q[currentQuestionIndex], answer, chosenAnswer);
            }),
      );

  Future<void> checkAnswer(QuestionModel currentQuestion, String userAnswer,
      int chosenAnswer) async {
    print(sliderValue);
    if ((userAnswer == currentQuestion.rightAnswer) && (sliderValue == 95)) {
      correctAnswer = true;
      handleHighlighting(currentQuestion, chosenAnswer);
      audioPlayer.open(Audio("assets/audios/right userAnswer.mp3"));
      setState(() {
        sliderValue = sliderValue + 5;
      });
      await Future.delayed(Duration(seconds: 1));
      winningDialog(gifts[Random().nextInt(gifts.length)]);
    } else if ((userAnswer == currentQuestion.rightAnswer) &&
        (sliderValue >= 0) &&
        (sliderValue < 100)) {
      correctAnswer = true;
      handleHighlighting(currentQuestion, chosenAnswer);
      audioPlayer.open(Audio("assets/audios/right answer.mp3"));
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        firstAnswerColor = secondAnswerColor =
            thirdAnswerColor = fourthAnswerColor = Colors.blue;
        sliderValue = sliderValue + 5;
        currentQuestionIndex = makingRandomQuestions();
      });
    } else if ((userAnswer != currentQuestion.rightAnswer) &&
        (sliderValue > 0)) {
      correctAnswer = false;
      handleHighlighting(currentQuestion, chosenAnswer);
      audioPlayer.open(Audio("assets/audios/wrong answer.mp3"));
      await Future.delayed(Duration(seconds: 1));
      if (sliderValue == 95) {
        setState(() {
          isNinety = true;
        });
        await Future.delayed(
            Duration(seconds: controller.value.duration.inSeconds));
        setState(() {
          isNinety = false;
        });
      }
      setState(() {
        firstAnswerColor = secondAnswerColor =
            thirdAnswerColor = fourthAnswerColor = Colors.blue;
        sliderValue = sliderValue - 5;
        currentQuestionIndex = makingRandomQuestions();
      });
    } else {
      correctAnswer = false;
      handleHighlighting(currentQuestion, chosenAnswer);
      audioPlayer.open(Audio("assets/audios/wrong answer.mp3"));
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        firstAnswerColor = secondAnswerColor =
            thirdAnswerColor = fourthAnswerColor = Colors.blue;
        currentQuestionIndex = makingRandomQuestions();
      });
    }
  }

  void handleHighlighting(QuestionModel answer, chosenAnswer) {
    isCalled = true;
    if (correctAnswer)
      switch (chosenAnswer) {
        case 1:
          setState(() {
            firstAnswerColor = Colors.green;
          });
          break;
        case 2:
          setState(() {
            secondAnswerColor = Colors.green;
          });
          break;
        case 3:
          setState(() {
            thirdAnswerColor = Colors.green;
          });
          break;
        case 4:
          setState(() {
            fourthAnswerColor = Colors.green;
          });
          break;
        default:
          return null;
      }
    else
      switch (chosenAnswer) {
        case 1:
          setState(() {
            firstAnswerColor = Colors.red;
          });
          highlightingRightAnswer(answer);
          break;
        case 2:
          setState(() {
            secondAnswerColor = Colors.red;
          });
          highlightingRightAnswer(answer);
          break;
        case 3:
          setState(() {
            thirdAnswerColor = Colors.red;
          });
          highlightingRightAnswer(answer);
          break;
        case 4:
          setState(() {
            fourthAnswerColor = Colors.red;
          });
          highlightingRightAnswer(answer);
          break;
        default:
          return null;
      }
  }

  ///When user chooses incorrect answer.
  void highlightingRightAnswer(QuestionModel answer) {
    if (randomAnswersList[0] == answer.rightAnswer)
      setState(() {
        firstAnswerColor = Colors.green;
      });
    else if (randomAnswersList[1] == answer.rightAnswer)
      setState(() {
        secondAnswerColor = Colors.green;
      });
    else if (randomAnswersList[2] == answer.rightAnswer)
      setState(() {
        thirdAnswerColor = Colors.green;
      });
    else
      setState(() {
        fourthAnswerColor = Colors.green;
      });
  }

  void winningDialog(MakingGifts gift) {
    showGeneralDialog(
        barrierLabel: 'label',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 300),
        context: context,
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position:
                Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
            child: child,
          );
        },
        pageBuilder: (context, anim1, anim2) {
          return Align(
            alignment: Alignment.center,
            child: Container(
              height: 350,
              width: 350,
              child: Material(
                child: Container(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'تهانينا لقد فزت بـ' + gift.giftName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                      ),
                      Image.asset(
                        gift.photoLocation,
                        height: 200,
                      ),
                      Text(gift.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blue)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                SystemNavigator.pop();
                              },
                              child:
                                  defaultText(context: context, text: 'خروج')),
                          ElevatedButton(
                              onPressed: () {
                                Restart.restartApp();
                              },
                              child: defaultText(
                                  context: context, text: 'اللعب مرة أخرى'))
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

  int makingRandomQuestions() {
    bool allAsked = true;
    for (int i = 0; i < Q.length; i++) {
      if (!Q[i].isAsked) {
        allAsked = false;
        break;
      }
    }
    if (allAsked)
      for (int i = 0; i < Q.length; i++) {
        Q[i].isAsked = false;
      }
    int randomIndex = Random().nextInt(Q.length);
    if (!Q[randomIndex].isAsked) {
      Q[randomIndex].isAsked = true;
      return randomIndex;
    } else {
      return makingRandomQuestions();
    }
  }
}
