import 'dart:convert';
import 'dart:io';

Future<void> startMotorControlService() async {
  const String motorControlService =
      "/home/genco/workspace/genco_motor_control/server.sh";

  var startMotor = await Process.start(
    motorControlService,
    [],
    mode: ProcessStartMode.normal,
  );
  watchProcess(startMotor);

  await Future.delayed(Duration(seconds: 6));
}

void watchProcess(process) {
  // Capture the output from the process
  process.stdout.transform(Utf8Decoder()).listen((data) {
    print(data.trim());
  });

  // Capture errors (if any)
  process.stderr.transform(Utf8Decoder()).listen((data) {
    print('Error: $data');
  });
}
