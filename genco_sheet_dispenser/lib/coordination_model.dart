import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genco_sheet_dispenser/app_config.dart';
import 'package:genco_sheet_dispenser/dispense_sheets.dart';

typedef CoordinatedState = Map<String, dynamic>;

class CoordinationModel extends ChangeNotifier {
  static var random = Random();

  CoordinatedState _coordinatedState = _getCoordinationState();

  static CoordinatedState _getCoordinationState() {
    return AppConfig.getAppConfig().coordinationState;
  }

  dynamic _getKioskInfo() {
    return AppConfig.getAppConfig().kiosk;
  }

  dynamic _getPageInfos() {
    return AppConfig.getAppConfig().pageInfos;
  }

  dynamic _getCurrentFlowPageInfos() {
    return _getState("flowScopedPageInfos");
  }

  void startFlow() {
    update("flowScopedPageInfos", _getPageInfos());
    _fillPageIdsFromCurrentStage();
    update("currentPageId", _popNextPageId());
  }

  void resetFlow() {
    _coordinatedState = _getCoordinationState();
  }

  dynamic _getState(String key) {
    return _coordinatedState[key];
  }

  void update(String key, dynamic value) {
    _coordinatedState[key] = value;
  }

  void _completePendingDispensing() {
    final String selectedSheetType = _getState("selectedSheetType");
    final String configName = "${selectedSheetType}MotorConfig";
    final int channel = int.parse(
        _getKioskInfo()["motorControlConfigId"][configName]["channel"]);
    dispenseSheets(channel);
  }

  void _fillPageIdsFromCurrentStage() {
    int stageIndex = _getState("stageIndex");
    final List<dynamic> pageIdSequence = _getState("pageIdSequence");
    final List<dynamic> upcomingPageIds =
        _extractUpcomingPageIds(pageIdSequence[stageIndex]);
    update("upcomingPageIds", upcomingPageIds);
  }

  List<dynamic> _extractUpcomingPageIds(List<dynamic> possibleSubFlowsInStage) {
    String extractionStrategy = _getState("extractionStrategy") ?? "RANDOM";
    switch (extractionStrategy) {
      case "ROUND_ROBIN_BY_STUDENT_ACTIVITY":
        int totalDispenses =
            _getState("authenticatedUser")["totalDispenses"] ?? 0;
        int numOfSubFlowOptions = possibleSubFlowsInStage.length;
        int chosenSubFlowIndex = totalDispenses % numOfSubFlowOptions;
        return possibleSubFlowsInStage[chosenSubFlowIndex];
      default:
        int numOfSubFlowOptions = possibleSubFlowsInStage.length;
        int randomlyChosenSubFlowIndex = random.nextInt(numOfSubFlowOptions);
        return possibleSubFlowsInStage[randomlyChosenSubFlowIndex];
    }
  }

  String? _popNextPageId() {
    List<dynamic> upcomingPageIds = _getState("upcomingPageIds");
    if (upcomingPageIds.isEmpty) {
      return null;
    }
    return upcomingPageIds.removeAt(0);
  }

  bool _isSpecifyingNewExtractionStrategy(String pageId) {
    return ["RANDOM", "ROUND_ROBIN_BY_STUDENT_ACTIVITY"].contains(pageId);
  }

  dynamic getCurrentPageRenderingInfo() {
    final String currentPageId = _getState("currentPageId");
    return _getCurrentFlowPageInfos()[currentPageId];
  }

  dynamic getPageRenderingInfo(String pageId) {
    return _getCurrentFlowPageInfos()[pageId];
  }

  dynamic nextPage() {
    String? nextPageId = _popNextPageId();
    if (nextPageId == null) {
      final int stageIndex = _getState("stageIndex");
      final List<dynamic> pageIdSequence = _getState("pageIdSequence");
      final int nextStageIndex = (stageIndex + 1) % pageIdSequence.length;
      update("stageIndex", nextStageIndex);
      _fillPageIdsFromCurrentStage();
      return nextPage();
    }

    if (_isSpecifyingNewExtractionStrategy(nextPageId)) {
      update("extractionStrategy", nextPageId);
      return nextPage();
    }

    if (nextPageId == "DISPENSE") {
      // This could be made more cleanly async by moving it to a separate
      // class/handler. The class can use a queue and independently pull
      // information from the shared coordination_model in order to dispense.
      _completePendingDispensing();
      return nextPage();
    }

    update("currentPageId", nextPageId);
    return getPageRenderingInfo(nextPageId);
  }
}
