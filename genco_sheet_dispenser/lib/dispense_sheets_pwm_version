import 'dart:convert';
import 'dart:io';

Future<void> dispenseSheets(channel) async {
  const String pythonExecutable =
      "/home/genco/workspace/genco/genco_motor_control/.venv/bin/python";
  const String toggleMotorScript =
      "/home/genco/workspace/genco/genco_sheet_dispenser/lib/toggle_motor.py";

  var startMotor = await Process.start(
    pythonExecutable,
    [toggleMotorScript, 'true', '$channel'],
    mode: ProcessStartMode.normal,
  );
  watchProcess(startMotor);

  await Future.delayed(Duration(seconds: 6));

  var stopMotor = await Process.start(
    pythonExecutable,
    [toggleMotorScript, 'false', '$channel'],
    mode: ProcessStartMode.normal,
  );
  watchProcess(stopMotor);
  await stopMotor.exitCode;
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
