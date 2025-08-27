import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'coordination_model.dart';
import 'navigator.dart';
import 'colors.dart';
import 'models/institutions.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    String inputPrompt = (denverUniversityId == "1")  
    ? "INPUT\nYOUR STUDENT ID" 
    : "INPUT\nYOUR EMAIL";
    Size screenSize = MediaQuery.of(context).size;
    final coordinationModel = Provider.of<CoordinationModel>(context);

    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            navigateToNextCoordinatedPage(context, coordinationModel);
          },
          child: Container(
            width: screenSize.width,
            height: screenSize.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "FREE ZERO WASTE\nLAUNDRY DETERGENT!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 70,
                    fontFamily: "Arial",
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        inputPrompt,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 50,
                          fontFamily: "Arial",
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Container(
                        height: 124,
                        width: 629,
                        decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          "TOUCH TO START",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 42,
                          color: AppColors.lightRed,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                  ),
                    ],
                    )
                  ),
              ],
            ),
          ),
        ),
      )
      );
  }
}
