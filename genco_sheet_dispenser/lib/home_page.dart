import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'coordination_model.dart';
import 'navigator.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final coordinationModel = Provider.of<CoordinationModel>(context);

    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            navigateToNextCoordinatedPage(context, coordinationModel);
          },
          child: Image.asset(
            'assets/images/touch_me.gif',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // child: OutlinedButton(
        //   onPressed: () {
        //     navigateToNextCoordinatedPage(context, coordinationModel);
        //   },
        //   child: Image.asset(
        //     'images/touch_me.gif',
        //     fit: BoxFit.cover,
        //     width: double.infinity,
        //     height: double.infinity,
        //   ),
        // ),
      ),
    );
  }
}
