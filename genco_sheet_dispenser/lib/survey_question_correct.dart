import 'package:flutter/material.dart';
import 'package:genco_sheet_dispenser/flow_delayed_proceed_timer.dart';
import 'package:provider/provider.dart';
import 'coordination_model.dart';
import 'navigator.dart';

class CorrectlyAnsweredSurveyQuestionPage extends StatefulWidget {
  final dynamic pageArguments;

  const CorrectlyAnsweredSurveyQuestionPage({super.key, required this.pageArguments});

  @override
  State<CorrectlyAnsweredSurveyQuestionPage> createState() => _CorrectlyAnsweredSurveyQuestionPageState();
}

class _CorrectlyAnsweredSurveyQuestionPageState extends State<CorrectlyAnsweredSurveyQuestionPage> {
  FlowDelayedProceedTimer? _timerWidget;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final coordinationModel = Provider.of<CoordinationModel>(context);
    final correctlyAnsweredQuestionPageId =
        widget.pageArguments["correctlyAnsweredQuestionPageId"];
    final pageInfo =
        coordinationModel.getPageRenderingInfo(correctlyAnsweredQuestionPageId);
    final timeUntilProceed = pageInfo["timeUntilProceed"];

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Cancel the timer by disposing the FlowDelayedProceedTimer widget
          setState(() {
            _timerWidget = null;
          });
          navigateToNextCoordinatedPage(context, coordinationModel);
        },
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/survey_question/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "CORRECT!",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _timerWidget ??= FlowDelayedProceedTimer(
                        timeUntilProceed: timeUntilProceed,
                        coordinationModel: coordinationModel)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
