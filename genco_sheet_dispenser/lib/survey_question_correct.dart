import 'package:flutter/material.dart';
import 'package:genco_sheet_dispenser/flow_delayed_proceed_timer.dart';
import 'package:provider/provider.dart';
import 'coordination_model.dart';

class CorrectlyAnsweredSurveyQuestionPage extends StatelessWidget {
  final dynamic pageArguments;

  const CorrectlyAnsweredSurveyQuestionPage(
      {super.key, required this.pageArguments});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final coordinationModel = Provider.of<CoordinationModel>(context);
    final correctlyAnsweredQuestionPageId =
        pageArguments["correctlyAnsweredQuestionPageId"];
    final pageInfo =
        coordinationModel.getPageRenderingInfo(correctlyAnsweredQuestionPageId);
    final timeUntilProceed = pageInfo["timeUntilProceed"];

    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/survey_question/background.png'), // Set the background image
            fit: BoxFit
                .cover, // This will make the image cover the entire screen
          ),
        ),
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
            FlowDelayedProceedTimer(
                timeUntilProceed: timeUntilProceed,
                coordinationModel: coordinationModel)
          ],
        ),
      ),
    );
  }
}
