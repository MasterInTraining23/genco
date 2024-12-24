import 'dart:async';

import 'package:genco_sheet_dispenser/models/dispensing_flows.dart';
import 'package:genco_sheet_dispenser/models/kiosk_page_infos.dart';
import 'package:genco_sheet_dispenser/models/kiosks.dart';

class AppConfig {
  static AppConfig? _singletonAppConfig;

  late Timer _timer;
  Map<String, dynamic>? _coordinationState;
  Map<String, dynamic>? _pageInfos;
  Map<String, dynamic>? _kiosk;

  AppConfig._();

  Future<void> startPolling() async {
    _timer = Timer.periodic(const Duration(hours: 1), _fetchData);
    await _fetchData(_timer);
  }

  Future<void> _fetchData(Timer timer) async {
    _coordinationState = await DispensingFlows.get();
    _pageInfos = await KioskPageInfos.get();
    _kiosk = await Kiosks.get();
  }

  dynamic get coordinationState =>
      _coordinationState!.map((key, value) => MapEntry(key, value));
  dynamic get pageInfos =>
      _pageInfos!.map((key, value) => MapEntry(key, value));
  dynamic get kiosk => _kiosk!.map((key, value) => MapEntry(key, value));

  void stopFetching() async {
    _timer.cancel();
  }

  static AppConfig getAppConfig() {
    _singletonAppConfig ??= AppConfig._();
    return _singletonAppConfig!;
  }
}
