# genco_sheet_dispenser

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Running the Kiosk

1. If the motor control is not already running, start it by running `genco_motor_control/server.sh`
2. If code changes have been need to be applied, run `flutter build linux` from within the `genco_sheet_dispenser` directory.
3. run `genco_sheet_dispenser/build/linux/arm64/release/bundle/genco_sheet_dispenser` to start the user interface in kiosk mode

## Configuring a Raspberry Pi (temporary process) for deployment

1. If there have been changes, pull the latest code from Github into `~/workspace/Github/genco`, and overwrite changed files in `~/workspace`
2. Configure `institutionId` by changing `denverUniversityId` in `~/workspace/lib/models/institutions.dart` to the ID of the correct institution. 
3. Configure the `kioskId` by changing `denverUniversityKioskId` to the correct kiosk ID in `~/workspace/lib/models/kiosks.dart`.
  - Check to ensure that the kiosk with `institutionId` and `kioskId` exists in the DynamoDB `kiosks` table, otherwise you'll encounter a runtime error. If no kiosk exists in the table, create one.
4. Build the app by running `flutter build linux`.

## DynamoDB Tables

Tables described with existing attributes, and their DynamoDB data types as `name:Type`

### dispensing_flows

* `id:S`
* `pageIdSequence:L`
* `stageIndex:N`

### institutions

* `dispensingFlowId:S`
* `id:S`
* `name:S`

### kiosk_dispense_activity

* `institutionId-kioskId:S`
* `sheetType:S`
* `timestampInMs:S`
* `userId:S`

### kiosk_page_infos

* `answerChoices:L`
* `correctlyAnsweredQuestionPageId:S`
* `errorLabels:L`
* `id:S`
* `incorrectAnswerTitle:L`
* `incorrectlyAnsweredQuestionPageId:S`
* `infoLabels:L`
* `informationalId:S`
* `navigationCriteria:S`
* `prefaceToShownAnswers:L`
* `questionAnswer:L`
* `questionFollowupNote:L`
* `questionPromptSubtitle:L`
* `questionPromptTitle:L`
* `refillErrorPageId:S`
* `refillErrorPageRoute:S`
* `route:S`
* `timeUntilProceed:N`
* `timeUntilRestart:N`

### kiosks

* `institutionId:S`
* `kioskId:S`
* `minDispenseAmount:N`
* `motorControlConfigId:S`
* `remainingScentedSheets:N`
* `remainingUnscentedSheets:N`
* `sheetInfo:M`

### motor_control_configs

* `id:S`
* `scentedMotorConfig:M`
* `unscentedMotorConfig:M`

### user_dispense_activity

* `institutionId-userId:S`
* `sheetType:S`
* `surveys:L`
* `timestampInMs:S`
* `userId:S`

### users

* `id:S`
* `institutionId:S`
* `remainingRefillsThisPeriod:N`
* `totalDispenses:N`
