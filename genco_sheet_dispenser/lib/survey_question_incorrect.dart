import 'dart:core';
import 'package:flutter/material.dart';
import 'package:genco_sheet_dispenser/flow_delayed_proceed_timer.dart';
import 'package:genco_sheet_dispenser/models/convert_item.dart';
import 'package:provider/provider.dart';
import 'coordination_model.dart';
import 'navigator.dart';

class InorrectlyAnsweredSurveyQuestionPage extends StatefulWidget {
  final dynamic pageArguments;

  const InorrectlyAnsweredSurveyQuestionPage(
      {super.key, required this.pageArguments});

  @override
  _InorrectlyAnsweredSurveyQuestionPageState createState() =>
      _InorrectlyAnsweredSurveyQuestionPageState();
}

class _InorrectlyAnsweredSurveyQuestionPageState
    extends State<InorrectlyAnsweredSurveyQuestionPage> {
  List<String>? incorrectAnswerTitle;
  List<String>? questionFollowupNote;
  List<String>? prefaceToShownAnswers;
  List<String>? answerChoices;
  List<bool>? questionAnswer;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final coordinationModel = Provider.of<CoordinationModel>(context);
    final pageInfo = coordinationModel.getPageRenderingInfo(
        widget.pageArguments["incorrectlyAnsweredQuestionPageId"]);
    final timeUntilProceed = pageInfo["timeUntilProceed"];
    incorrectAnswerTitle =
        convertDynamicsToString(pageInfo["incorrectAnswerTitle"]);
    questionFollowupNote =
        convertDynamicsToString(pageInfo["questionFollowupNote"]);
    prefaceToShownAnswers =
        convertDynamicsToString(pageInfo["prefaceToShownAnswers"]);
    questionAnswer = widget.pageArguments["questionAnswer"];
    answerChoices = widget.pageArguments["answerChoices"];

    List<Widget> children = [
      ...incorrectAnswerTitle!.map((title) {
        return Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 60,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );
      }),
      ...questionFollowupNote!.map((note) {
        return Text(
          note,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );
      }),
      SizedBox(
        height: 100,
      ),
      ...prefaceToShownAnswers!.map((note) {
        return Text(
          note,
          style: TextStyle(
            color: Colors.black,
            fontSize: 60,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        );
      }),
      SizedBox(
        height: screenSize.height - 400,
        width: screenSize.width,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: questionAnswer!.length,
          itemBuilder: (context, index) {
            return SizedBox(
              height: 70,
              width: screenSize.width / questionAnswer!.length,
              child: ListTile(
                enabled: false,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: questionAnswer![index]
                            ? Colors.black
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black, // Border color
                          width: 4, // Border width
                        ),
                      ),
                    ),
                    Text(
                      answerChoices![index],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                selected: questionAnswer![index],
              ),
            );
          },
          padding: EdgeInsets.symmetric(horizontal: 5),
        ),
      ),
      FlowDelayedProceedTimer(
          timeUntilProceed: timeUntilProceed,
          coordinationModel: coordinationModel)
    ];
    FlowDelayedProceedTimer? _timerWidget;
    Widget buildContent() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          ...children,
        ],
      );
    }
    return Scaffold(
      backgroundColor: Colors.red,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _timerWidget = null;
          });
          navigateToNextCoordinatedPage(context, coordinationModel);
        },
        child: Center(
          child: buildContent(),
        ),
      ),
    );
  }
}
