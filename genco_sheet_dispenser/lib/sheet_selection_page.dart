import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'coordination_model.dart';
import 'flow_restart_timer.dart';
import 'sheet_type.dart';
import 'navigator.dart';

class SheetSelectionPage extends StatefulWidget {
  const SheetSelectionPage({super.key});

  @override
  _SheetSelectionPageState createState() => _SheetSelectionPageState();
}

class _SheetSelectionPageState extends State<SheetSelectionPage> {
  SheetType _sheetSelection = SheetType.unknown;

  void _selectSheet(SheetType selection, coordinationModel) {
    setState(() {
      coordinationModel.update("sheetSelection", selection);
      _sheetSelection = selection;
    });
  }

  @override
  Widget build(BuildContext context) {
    final coordinationModel = Provider.of<CoordinationModel>(context);
    final pageInfo = coordinationModel.getCurrentPageRenderingInfo();
    final timeUntilRestart = pageInfo["timeUntilRestart"];

    List<Widget> children = [
      Text('SELECT YOUR DETERGENT SHEET PREFERENCE',
          style: Theme.of(context).textTheme.titleLarge),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () => _selectSheet(SheetType.scented, coordinationModel),
          child: Text('SCENTED',
              style: getStyleOfSheetOption(
                  context, _sheetSelection, SheetType.scented)),
        ),
        ElevatedButton(
          onPressed: () => _selectSheet(SheetType.unscented, coordinationModel),
          child: Text('UN-SCENTED',
              style: getStyleOfSheetOption(
                  context, _sheetSelection, SheetType.unscented)),
        ),
        const SizedBox(width: 20),
      ]),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: _sheetSelection != SheetType.unknown
                ? () {
                    coordinationModel.update(
                        "selectedSheetType", _sheetSelection);
                    navigateToNextCoordinatedPage(context, coordinationModel);
                  }
                : null,
            style: getDispenseButtonStyle(_sheetSelection),
            child: Text('DISPENSE',
                style: getDispenseButtonTextStyle(context, _sheetSelection)),
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FlowRestartTimer(
              timeUntilRestart: timeUntilRestart,
              coordinationModel: coordinationModel),
        ],
      )
    ];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/background/generic.png'), // Set the background image
            fit: BoxFit
                .cover, // This will make the image cover the entire screen
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

TextStyle? getStyleOfSheetOption(context, sheetSelection, myOption) {
  if (sheetSelection == SheetType.unknown) {
    return Theme.of(context).textTheme.bodyLarge;
  }
  if (sheetSelection == myOption) {
    return Theme.of(context).textTheme.headlineLarge;
  }
  return TextStyle(
    color: Colors.grey,
    fontSize: 48,
    fontWeight: FontWeight.bold,
  );
}

dynamic getDispenseButtonStyle(sheetSelection) {
  return ElevatedButton.styleFrom(
      backgroundColor:
          sheetSelection == SheetType.unknown ? Colors.transparent : Colors.red,
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 50),
      shape: OvalBorder(
          eccentricity: 1, side: BorderSide(color: Colors.red, width: 2)));
}

TextStyle? getDispenseButtonTextStyle(context, sheetSelection) {
  if (sheetSelection == SheetType.unknown) {
    return Theme.of(context).textTheme.bodyLarge;
  }
  return TextStyle(
    color: Colors.white,
    fontSize: 48,
    fontWeight: FontWeight.bold,
  );
}
