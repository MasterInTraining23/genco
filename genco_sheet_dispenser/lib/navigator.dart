import 'package:flutter/material.dart';
import 'coordination_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void navigateToNextCoordinatedPage(
    BuildContext context, CoordinationModel coordinationModel) async {
  String route = (await coordinationModel.nextPage())["route"];
  Navigator.pushReplacementNamed(
    context,
    route,
  );
}

void restartFlow(BuildContext context, CoordinationModel coordinationModel) {
  coordinationModel.resetFlow();
  coordinationModel.startFlow();
  Navigator.pushReplacementNamed(
    context,
    coordinationModel.getCurrentPageRenderingInfo()["route"],
  );
}
