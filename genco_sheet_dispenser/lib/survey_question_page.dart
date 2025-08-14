import 'dart:core';
import 'package:flutter/material.dart';
import 'package:genco_sheet_dispenser/models/convert_item.dart';
import 'package:provider/provider.dart';
import 'coordination_model.dart';
import 'flow_restart_timer.dart';

class SurveyQuestionPage extends StatefulWidget {
  const SurveyQuestionPage({super.key});

  @override
  _SurveyQuestionPageState createState() => _SurveyQuestionPageState();
}

class _SurveyQuestionPageState extends State<SurveyQuestionPage> {
  List<String>? questionPromptTitle;
  List<String>? questionPromptSubtitle;
  List<bool>? questionAnswer;
  bool isMultiChoiceAnswer = false;
  List<String>? answerChoices;
  List<bool>? selectedChoices;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final coordinationModel = Provider.of<CoordinationModel>(context);
    final pageInfo = coordinationModel.getCurrentPageRenderingInfo();
    final timeUntilRestart = pageInfo["timeUntilRestart"];
    questionPromptTitle = questionPromptTitle ??
        convertDynamicsToString(pageInfo["questionPromptTitle"]);
    questionPromptSubtitle = questionPromptSubtitle ??
        convertDynamicsToString(pageInfo["questionPromptSubtitle"]);
    questionAnswer =
        questionAnswer ?? convertDynamicsToBool(pageInfo["questionAnswer"]);
    isMultiChoiceAnswer = evaluateMultiChoiceAnswer(questionAnswer);
    answerChoices =
        answerChoices ?? convertDynamicsToString(pageInfo["answerChoices"]);
    selectedChoices =
        selectedChoices ?? List.filled(answerChoices!.length, false);

    List<Widget> children = [
      ...questionPromptTitle!.map((title) {
        return Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      }),
      ...questionPromptSubtitle!.map((subTitle) {
        return Text(
          subTitle,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        );
      }),
      SizedBox(
        height: 20,
      ),
      SizedBox(
        height: screenSize.height - 320,
        width: screenSize.width,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: answerChoices!.length,
          itemBuilder: (context, index) {
            return SizedBox(
              height: 100,
              width: screenSize.width / answerChoices!.length,
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: selectedChoices![index]
                            ? Colors.red
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red, // Border color
                          width: 4, // Border width
                        ),
                      ),
                    ),
                    Text(
                      answerChoices![index],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    if (!isMultiChoiceAnswer) {
                      selectedChoices =
                          List.filled(answerChoices!.length, false);
                    }
                    selectedChoices![index] = !selectedChoices![index];
                  });
                },
                selected: selectedChoices![index],
              ),
            );
          },
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        ),
      ),
      ElevatedButton(
        onPressed: anySelectedOptions(selectedChoices!)
            ? () async {
                Map<String, dynamic> surveyInfo =
                    Map<String, dynamic>.from(pageInfo);
                coordinationModel.addSurveyInfo(surveyInfo);

                coordinationModel.completePendingDispensing();

                if (isAnsweredCorrect(questionAnswer!, selectedChoices!)) {
                  Navigator.pushReplacementNamed(
                      context, "/survey_question/correct", arguments: {
                    "correctlyAnsweredQuestionPageId":
                        pageInfo["correctlyAnsweredQuestionPageId"]
                  });
                } else {
                  Navigator.pushReplacementNamed(
                      context, "/survey_question/incorrect",
                      arguments: {
                        "incorrectlyAnsweredQuestionPageId":
                            pageInfo["incorrectlyAnsweredQuestionPageId"],
                        "questionAnswer": questionAnswer,
                        "answerChoices": answerChoices
                      });
                }
              }
            : null,
        style: getSubmitButtonStyle(anySelectedOptions(selectedChoices!)),
        child: Text('ANSWER',
            style: getSubmitButtonTextStyle(
                context, anySelectedOptions(selectedChoices!))),
      ),
      FlowRestartTimer(
          timeUntilRestart: timeUntilRestart,
          coordinationModel: coordinationModel)
    ];

    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/survey_question/background.png'), // Set the background image
              fit: BoxFit
                  .cover, // This will make the image cover the entire screen
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

bool anySelectedOptions(List<bool> selectedOptions) {
  return selectedOptions.any((element) => element);
}

dynamic getSubmitButtonStyle(activated) {
  return ElevatedButton.styleFrom(
      backgroundColor: activated ? Colors.red : Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 50),
      shape: OvalBorder(
          eccentricity: 1, side: BorderSide(color: Colors.red, width: 2)));
}

TextStyle? getSubmitButtonTextStyle(context, activated) {
  if (!activated) {
    return Theme.of(context).textTheme.bodyLarge;
  }
  return TextStyle(
    color: Colors.white,
    fontSize: 48,
    fontWeight: FontWeight.bold,
  );
}

bool isAnsweredCorrect(List<bool> questionAnswer, List<bool> submittedAnswer) {
  return questionAnswer.length == submittedAnswer.length &&
      List.generate(questionAnswer.length,
          (i) => questionAnswer[i] == submittedAnswer[i]).every((e) => e);
}

bool evaluateMultiChoiceAnswer(List<bool>? questionAnswer) {
  if (questionAnswer == null) {
    return false;
  }

  List<bool> enabledAnswers = questionAnswer.fold([], (enabledAnswers, answer) {
    if (answer) {
      enabledAnswers.add(answer);
    }
    return enabledAnswers;
  });
  return enabledAnswers.length >= 2;
}
