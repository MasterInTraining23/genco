import 'package:flutter/material.dart';
import 'package:genco_sheet_dispenser/flow_restart_timer.dart';
import 'package:provider/provider.dart';
import 'coordination_model.dart';

class EcoInformationalPage extends StatelessWidget {
  const EcoInformationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final coordinationModel = Provider.of<CoordinationModel>(context);
    final pageInfo = coordinationModel.getCurrentPageRenderingInfo();
    final timeUntilRestart = pageInfo["timeUntilRestart"];
    final informationalId = pageInfo["informationalId"];

    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: AssetImage(
                'assets/images/eco_informational/$informationalId.png'), // Set the background image
            fit: BoxFit
                .cover, // This will make the image cover the entire screen
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlowRestartTimer(
                timeUntilRestart: timeUntilRestart,
                coordinationModel: coordinationModel)
          ],
        ),
      ),
    );
  }
}
