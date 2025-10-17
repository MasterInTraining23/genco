import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genco_sheet_dispenser/app_config.dart';
import 'package:genco_sheet_dispenser/dispense_sheets.dart';
import 'package:genco_sheet_dispenser/models/kiosk_dispense_activity.dart';
import 'package:genco_sheet_dispenser/models/kiosks.dart';
import 'package:genco_sheet_dispenser/models/user_dispense_activity.dart';
import 'package:genco_sheet_dispenser/models/users.dart';
import 'package:genco_sheet_dispenser/sheet_type.dart';

typedef CoordinatedState = Map<String, dynamic>;

class CoordinationModel extends ChangeNotifier {
  static var random = Random();

  CoordinatedState _coordinatedState = _getCoordinationState();

  static CoordinatedState _getCoordinationState() {
    return AppConfig.getAppConfig().coordinationState;
  }

  dynamic _getMotorControlConfig() {
    return AppConfig.getAppConfig().motorControlConfig;
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
    update("kiosk", getKiosk());
  }

  void resetFlow() {
    _coordinatedState = _getCoordinationState();
  }

  dynamic getKiosk() {
    return AppConfig.getAppConfig().kiosk;
  }

  dynamic getUser() {
    return _coordinatedState["user"];
  }

  dynamic _getState(String key) {
    return _coordinatedState[key];
  }

  void update(String key, dynamic value) {
    _coordinatedState[key] = value;
  }

  void setUser(dynamic user) {
    _coordinatedState["user"] = user;
  }

  Future<void> _loginAnonymousUser() async {
    update("user", await Users.get("anonymous"));
  }

  Future<void> completePendingDispensing() async {
    final SheetType selectedSheetType =
        _getState("selectedSheetType") as SheetType;
    final String configName = "${selectedSheetType.name}MotorConfig";
    final int channel = _getMotorControlConfig()[configName]["channel"];
    final String deviceName = _getMotorControlConfig()[configName]["deviceName"];
    dispenseSheets(channel);
    Map<String, dynamic> kiosk = getKiosk();
    Map<String, dynamic> user = getUser();
    Users.successfullyDispensed(user: user);
    UserDispenseActivity.successfullyDispensed(
      user: user,
      sheetType: selectedSheetType,
      surveyInfos: _getState("surveyInfos"),
    );
    KioskDispenseActivity.successfullyDispensed(
      user: user,
      sheetType: selectedSheetType,
    );
    Kiosks.successfullyDispensed(kiosk: kiosk);
    // Verify number of dispenses remaining for kiosk
    // say that it's out of refills when both are out
  }

void _addPageForNoMoreRefillsAtKiosk() {
  
}

  void _fillPageIdsFromCurrentStage() {
    int stageIndex = _getState("stageIndex");
    final List<dynamic> pageIdSequence = _getState("pageIdSequence");
    final List<dynamic> upcomingPageIds =
        _extractUpcomingPageIds(pageIdSequence[stageIndex]);
    update("upcomingPageIds", upcomingPageIds.toList());
  }

  List<dynamic> _extractUpcomingPageIds(List<dynamic> possibleSubFlowsInStage) {
    String extractionStrategy =
        _getState("extractionStrategy") ?? "RANDOM_SELECTION";
    switch (extractionStrategy) {
      case "ROUND_ROBIN_SELECTION_BY_STUDENT_ACTIVITY":
        int totalDispenses = _getState("user")["totalDispenses"] ?? 0;
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

  dynamic getCurrentPageRenderingInfo() {
    final String currentPageId = _getState("currentPageId");
    return _getCurrentFlowPageInfos()[currentPageId];
  }

  dynamic getPageRenderingInfo(String pageId) {
    return _getCurrentFlowPageInfos()[pageId];
  }

  dynamic nextPage() async {
    String? nextPageId = _popNextPageId();
    if (nextPageId == null) {
      final int stageIndex = _getState("stageIndex");
      final List<dynamic> pageIdSequence = _getState("pageIdSequence");
      final int nextStageIndex = (stageIndex + 1) % pageIdSequence.length;
      update("stageIndex", nextStageIndex);
      _fillPageIdsFromCurrentStage();
      return nextPage();
    }

    switch (nextPageId) {
      case "RANDOM_SELECTION":
      case "ROUND_ROBIN_SELECTION_BY_STUDENT_ACTIVITY":
        update("extractionStrategy", nextPageId);
        return nextPage();
      case "ANONYMOUS_AUTHORIZATION":
        // Purposely choosing not to wait since downstream processes should not
        // require user info if this is an anonymous flow. The only information
        // we need is for logging and we should not block or error on failed logging.
        await _loginAnonymousUser();
        return nextPage();
      case "DISPENSE":
        // This could be made more cleanly async by moving it to a separate
        // class/handler. The class can use a queue and independently pull
        // information from the shared coordination_model in order to dispense.
        completePendingDispensing();
        return nextPage();
      default:
        break;
    }

    update("currentPageId", nextPageId);
    return getPageRenderingInfo(nextPageId);
  }

  void addSurveyInfo(Map<String, dynamic> surveyInfo) {
    List<Map<String, dynamic>> infos = _getState("surveyInfos") ?? [];
    infos.add(surveyInfo);
    update("surveyInfos", infos);
  }
}
