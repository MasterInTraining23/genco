import 'package:flutter/material.dart';
import 'package:genco_sheet_dispenser/flow_restart_timer.dart';
import 'package:provider/provider.dart';
import 'coordination_model.dart';

class ErrorPage extends StatelessWidget {
  final dynamic pageArguments;

  static const TextStyle textStyle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  const ErrorPage({super.key, required this.pageArguments});

  @override
  Widget build(BuildContext context) {
    final coordinationModel = Provider.of<CoordinationModel>(context);
    dynamic pageInfo;

    if (pageArguments != null) {
      final errorPageId = pageArguments["errorPageId"];
      pageInfo = coordinationModel.getPageRenderingInfo(errorPageId);
    } else {
      pageInfo = coordinationModel.getCurrentPageRenderingInfo();
    }

    final timeUntilRestart = pageInfo["timeUntilRestart"];
    final errorLabels = pageInfo["errorLabels"] as List;
    final infoLabels = pageInfo["infoLabels"] as List;

    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...errorLabels
                .map((errorLabel) => Text(errorLabel, style: textStyle)),
            SizedBox(height: 10),
            ...infoLabels.map((infoLabel) => Text(infoLabel, style: textStyle)),
            FlowRestartTimer(
                timeUntilRestart: timeUntilRestart,
                coordinationModel: coordinationModel)
          ],
        ),
      ),
    );
  }
}
