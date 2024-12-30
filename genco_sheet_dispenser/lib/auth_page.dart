import 'package:flutter/material.dart';
import 'package:genco_sheet_dispenser/flow_restart_timer.dart';
import 'package:genco_sheet_dispenser/models/users.dart';
import 'package:provider/provider.dart';
import 'coordination_model.dart';
import 'navigator.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Text controller to manage input text
  final TextEditingController _controller = TextEditingController();
  String invalidIdErrorMsg = "";
  dynamic renderedCountdown;

  // This function will be called when a key is pressed
  void _onKeyPress(String value) {
    setState(() {
      invalidIdErrorMsg = "";
      _controller.text += value; // Append value to the text controller
    });
  }

  void _onClearAllText() {
    setState(() {
      invalidIdErrorMsg = "";
      _controller.clear();
    });
  }

  // Backspace function to delete the last character
  void _onBackspace() {
    setState(() {
      invalidIdErrorMsg = "";
      _controller.text = _controller.text.isNotEmpty
          ? _controller.text.substring(0, _controller.text.length - 1)
          : _controller.text;
    });
  }

  void _onSubmitId(BuildContext context, CoordinationModel coordinationModel,
      String refillErrorPageRoute, String refillErrorPageId) async {
    Map<String, dynamic>? user = await Users.get(_controller.text);

    if (user == null) {
      setState(() {
        invalidIdErrorMsg = '''
        PLEASE CHECK YOUR DETAILS AND TRY AGAIN
        IF YOU THINK IT'S AN ERROR TEXT 516-619-6174''';
        renderedCountdown = null;
      });
    } else {
      if (!context.mounted) {
        return;
      }
      if (user["remainingRefillsThisPeriod"] as int <= 0) {
        Navigator.pushReplacementNamed(context, refillErrorPageRoute,
            arguments: {"errorPageId": refillErrorPageId});
      } else {
        coordinationModel.update("user", user);
        navigateToNextCoordinatedPage(context, coordinationModel);
      }
    }
  }

  final keyboardKeys = [
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "←"],
    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
    ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
    ["Z", "X", "C", "V", "B", "N", "M", "clear", "enter"]
  ];

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double spaceForErrorMsg = invalidIdErrorMsg == "" ? 0 : 100;
    double maxKeyboardHeight = screenSize.height - 235 - spaceForErrorMsg;
    final coordinationModel = Provider.of<CoordinationModel>(context);
    final pageInfo = coordinationModel.getCurrentPageRenderingInfo();
    final refillErrorPageId = pageInfo["refillErrorPageId"];
    final refillErrorPageRoute =
        coordinationModel.getPageRenderingInfo(refillErrorPageId)["route"];
    final timeUntilRestart = pageInfo["timeUntilRestart"];

renderedCountdown = renderedCountdown ??
        FlowRestartTimer(
            timeUntilRestart: timeUntilRestart,
            coordinationModel: coordinationModel);
    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/background/generic.png'), // Set the background image
            fit: BoxFit
                .cover, // This will make the image cover the entire screen
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: TextField(
                controller: _controller,
                readOnly: true, // Prevent direct typing in TextField
                decoration: InputDecoration(
                  labelText: "ENTER YOUR STUDENT ID",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
            Text(
              invalidIdErrorMsg,
              style: TextStyle(color: Colors.black, fontSize: 28),
            ),
            IgnorePointer(
              ignoring: false, // This allows the button to receive events
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxKeyboardHeight),
                child: ListView.builder(
                  itemCount: keyboardKeys.length, // Number of rows
                  itemBuilder: (context, rowIndex) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: keyboardKeys[rowIndex].map((keyText) {
                        final requiresExtraLength =
                            keyText == "clear" || keyText == "enter";
                        return SizedBox(
                          width: requiresExtraLength
                              ? 120
                              : 70, // Most elements are square except for "clear" and "enter"
                          height:
                              70, // Height value can match common width in order to make it square
                          child: Container(
                            margin: EdgeInsets.all(5),
                            child: ElevatedButton(
                              onPressed: () {
                                if (keyText == "←") {
                                  _onBackspace();
                                } else if (keyText == "clear") {
                                  _onClearAllText();
                                } else if (keyText == "enter") {
                                  _onSubmitId(context, coordinationModel,
                                      refillErrorPageRoute, refillErrorPageId);
                                } else {
                                  _onKeyPress(
                                      keyText); // Append number to input
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 5,
                                ),
                              ),
                              child: Text(
                                keyText,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
            renderedCountdown
          ],
        ),
      ),
    );
  }
}
