class QuestionModel {
  String question;
  String firstAnswer;
  String secondAnswer;
  String thirdAnswer;
  String fourthAnswer;
  String rightAnswer;
  bool isAsked;

  QuestionModel(this.question, this.rightAnswer, this.firstAnswer,
      this.secondAnswer, this.thirdAnswer, this.fourthAnswer, this.isAsked);
}